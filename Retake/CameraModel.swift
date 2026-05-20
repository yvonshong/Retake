import AVFoundation
import UIKit

/// Represents an available camera lens with its native zoom factor.
struct CameraLens: Identifiable, Equatable {
    let id: String
    let device: AVCaptureDevice
    /// The "equivalent" zoom label (e.g. 0.5, 1, 2, 5)
    let equivalentZoom: CGFloat
    /// Display label
    var label: String {
        if equivalentZoom < 1 {
            return String(format: "%.1f", equivalentZoom)
        } else {
            return String(format: "%.0f", equivalentZoom)
        }
    }

    static func == (lhs: CameraLens, rhs: CameraLens) -> Bool {
        lhs.id == rhs.id
    }
}

class CameraModel: NSObject, ObservableObject {
    let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    private var completionHandler: ((UIImage?) -> Void)?
    private var currentInput: AVCaptureDeviceInput?

    /// All available back camera lenses
    @Published var lenses: [CameraLens] = []
    /// Currently active lens
    @Published var activeLens: CameraLens?
    /// Current effective zoom (lens-relative)
    @Published var currentZoom: CGFloat = 1.0
    /// Virtual zoom across all lenses (e.g. 0.5 → 10)
    @Published var virtualZoom: CGFloat = 1.0

    func start() {
        guard !session.isRunning else { return }

        session.beginConfiguration()
        session.sessionPreset = .inputPriority

        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        output.maxPhotoQualityPrioritization = .quality

        // Discover all back cameras
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [
                .builtInUltraWideCamera,
                .builtInWideAngleCamera,
                .builtInTelephotoCamera
            ],
            mediaType: .video,
            position: .back
        )

        var discovered: [CameraLens] = []
        for device in discoverySession.devices {
            let zoom: CGFloat
            switch device.deviceType {
            case .builtInUltraWideCamera: zoom = 0.5
            case .builtInWideAngleCamera: zoom = 1.0
            case .builtInTelephotoCamera:
                // Telephoto zoom varies by device (2x, 3x, 5x)
                // Use the ratio relative to wide angle
                zoom = CGFloat(device.virtualDeviceSwitchOverVideoZoomFactors.last?.doubleValue ?? 2.0)
                    .rounded(.down)
                    let wideMinFocal = discoverySession.devices
                        .first(where: { $0.deviceType == .builtInWideAngleCamera })?
                        .activeFormat.videoFieldOfView ?? 67
                    let teleMinFocal = device.activeFormat.videoFieldOfView
                    let ratio = wideMinFocal > 0 && teleMinFocal > 0 ? tan((wideMinFocal / 2) * .pi / 180) / tan((teleMinFocal / 2) * .pi / 180) : 2.0
                    let _ = ratio // unused for now, rely on standard labels
            default: continue
            }
            discovered.append(CameraLens(id: device.uniqueID, device: device, equivalentZoom: zoom))
        }

        // Sort by zoom factor
        discovered.sort { $0.equivalentZoom < $1.equivalentZoom }

        // Deduplicate by zoom level
        var seen = Set<String>()
        discovered = discovered.filter { lens in
            let key = lens.label
            guard !seen.contains(key) else { return false }
            seen.insert(key)
            return true
        }

        DispatchQueue.main.async {
            self.lenses = discovered
        }

        // Start with the 1x (wide) lens, or the first available
        let startLens = discovered.first(where: { $0.equivalentZoom == 1.0 }) ?? discovered.first
        if let lens = startLens {
            switchToLens(lens, commitSession: false)
        }

        session.commitConfiguration()

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
        }
    }

    func stop() {
        guard session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.stopRunning()
        }
    }

    // MARK: - Lens switching

    func switchToLens(_ lens: CameraLens, commitSession: Bool = true) {
        guard let input = try? AVCaptureDeviceInput(device: lens.device) else { return }

        if commitSession { session.beginConfiguration() }

        // Remove old input
        if let currentInput {
            session.removeInput(currentInput)
        }

        if session.canAddInput(input) {
            session.addInput(input)
            currentInput = input

            // Set best 16:9 format
            configureBestFormat(for: lens.device)

            // Reset zoom to 1x on this device
            do {
                try lens.device.lockForConfiguration()
                lens.device.videoZoomFactor = 1.0
                lens.device.unlockForConfiguration()
            } catch { }

            DispatchQueue.main.async {
                self.activeLens = lens
                self.currentZoom = 1.0
                self.virtualZoom = lens.equivalentZoom
            }
        }

        if commitSession { session.commitConfiguration() }
    }

    /// Set digital zoom within the current lens
    func setZoom(_ factor: CGFloat) {
        guard let device = activeLens?.device else { return }
        let maxZoom = min(device.activeFormat.videoMaxZoomFactor, 10.0)
        let clamped = max(1.0, min(factor, maxZoom))
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = clamped
            device.unlockForConfiguration()
            DispatchQueue.main.async {
                self.currentZoom = clamped
                if let lens = self.activeLens {
                    self.virtualZoom = lens.equivalentZoom * clamped
                }
            }
        } catch { }
    }

    // MARK: - Photo capture

    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        completionHandler = completion
        if let connection = output.connection(with: .video),
           connection.isVideoOrientationSupported {
            connection.videoOrientation = CameraPreviewUIView.currentVideoOrientation()
        }
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }

    // MARK: - Private

    private func configureBestFormat(for device: AVCaptureDevice) {
        let targetRatio: CGFloat = 16.0 / 9.0
        let formats = device.formats.filter { format in
            let dims = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
            let ratio = CGFloat(dims.width) / CGFloat(dims.height)
            return abs(ratio - targetRatio) < 0.02
        }
        if let bestFormat = formats.max(by: {
            let d0 = CMVideoFormatDescriptionGetDimensions($0.formatDescription)
            let d1 = CMVideoFormatDescriptionGetDimensions($1.formatDescription)
            return (d0.width * d0.height) < (d1.width * d1.height)
        }) {
            do {
                try device.lockForConfiguration()
                device.activeFormat = bestFormat
                device.unlockForConfiguration()
            } catch { }
        }
    }
}

extension CameraModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            completionHandler?(nil)
            completionHandler = nil
            return
        }
        DispatchQueue.main.async { [weak self] in
            self?.completionHandler?(image)
            self?.completionHandler = nil
        }
    }
}
