import SwiftUI
import AVFoundation

struct CameraOverlayView: View {
    let overlayImage: UIImage
    let onDismiss: () -> Void

    @StateObject private var cameraModel = CameraModel()
    @State private var opacity: Double = 0.37
    @State private var showSavedAlert = false

    var body: some View {
        ZStack {
            // Camera preview layer
            CameraPreviewView(session: cameraModel.session)
                .ignoresSafeArea()

            // Overlay reference image — match camera preview's fill behavior
            GeometryReader { geo in
                Image(uiImage: overlayImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .opacity(opacity)
                    .allowsHitTesting(false)
            }
            .ignoresSafeArea()

            // UI Controls
            VStack {
                // Top bar: back button + slider
                HStack(spacing: 12) {
                    Button {
                        cameraModel.stop()
                        dismissCamera()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(10)
                            .background(.ultraThinMaterial, in: Circle())
                    }

                    Image(systemName: "eye.slash")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))

                    Slider(value: $opacity, in: 0...1)
                        .tint(.white)

                    Image(systemName: "eye")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))

                    Text("\(Int(opacity * 100))%")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.white)
                        .frame(width: 40)
                }
                .padding(.horizontal)
                .padding(.top, 8)

                Spacer()

                // Lens selector (0.5x, 1x, 2x, etc.)
                ZoomControlView(cameraModel: cameraModel)
                    .padding(.bottom, 16)

                // Bottom: capture button
                HStack {
                    Spacer()

                    Button {
                        cameraModel.capturePhoto { image in
                            if let image {
                                saveToPhotoLibrary(image)
                            }
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(.white)
                                .frame(width: 72, height: 72)
                            Circle()
                                .stroke(.white, lineWidth: 4)
                                .frame(width: 82, height: 82)
                        }
                    }

                    Spacer()
                }
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            OrientationManager.shared.allowAllOrientations = true
            cameraModel.start()
        }
        .onDisappear {
            OrientationManager.shared.allowAllOrientations = false
            // Force back to portrait when leaving camera
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        }
        .alert("照片已保存", isPresented: $showSavedAlert) {
            Button("继续拍照", role: .cancel) { }
            Button("返回首页") {
                cameraModel.stop()
                dismissCamera()
            }
        }
        .statusBarHidden()
    }

    private func dismissCamera() {
        OrientationManager.shared.allowAllOrientations = false
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        onDismiss()
    }

    private func saveToPhotoLibrary(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        showSavedAlert = true
    }
}
