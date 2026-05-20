import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

/// Custom Transferable that properly handles image data from PhotosPicker
struct PickableImage: Transferable {
    let image: UIImage

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            guard let image = UIImage(data: data) else {
                throw ImageLoadError.invalidData
            }
            return PickableImage(image: image)
        }
    }

    enum ImageLoadError: Error {
        case invalidData
    }
}

struct ContentView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var overlayImage: UIImage?
    @State private var showCamera = false
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Spacer()

                VStack(spacing: 12) {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 80))
                        .foregroundColor(.accentColor)

                    Text("Retake")
                        .font(.system(size: 42, weight: .bold, design: .rounded))

                    Text("圣地巡礼拍照")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Label("选择参考图片", systemImage: "photo.on.rectangle")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 40)

                if isLoading {
                    ProgressView("加载中...")
                }

                Spacer()
                Spacer()
            }
            .onChange(of: selectedItem) { newItem in
                guard let newItem else { return }
                isLoading = true
                Task {
                    if let picked = try? await newItem.loadTransferable(type: PickableImage.self) {
                        overlayImage = picked.image
                        showCamera = true
                    }
                    isLoading = false
                }
            }
            .fullScreenCover(isPresented: $showCamera) {
                if let overlayImage {
                    CameraOverlayView(overlayImage: overlayImage) {
                        showCamera = false
                        selectedItem = nil
                        self.overlayImage = nil
                    }
                }
            }
        }
    }
}
