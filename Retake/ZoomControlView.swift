import SwiftUI

/// Native camera-style zoom lens selector (0.5x, 1x, 2x, etc.)
struct ZoomControlView: View {
    @ObservedObject var cameraModel: CameraModel

    var body: some View {
        HStack(spacing: 4) {
            ForEach(cameraModel.lenses) { lens in
                let isActive = cameraModel.activeLens == lens && cameraModel.currentZoom <= 1.05
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        cameraModel.switchToLens(lens)
                    }
                } label: {
                    Text(displayText(for: lens))
                        .font(.system(size: 12, weight: isActive ? .bold : .medium, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(isActive ? .yellow : .white)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(isActive ? Color.black.opacity(0.6) : Color.black.opacity(0.3))
                        )
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Capsule().fill(.black.opacity(0.25)))
    }

    private func displayText(for lens: CameraLens) -> String {
        if cameraModel.activeLens == lens && cameraModel.currentZoom > 1.05 {
            // Show actual virtual zoom when digitally zoomed on this lens
            let vz = lens.equivalentZoom * cameraModel.currentZoom
            if vz < 10 {
                return String(format: "%.1f", vz)
            } else {
                return String(format: "%.0f", vz)
            }
        }
        return lens.label
    }
}
