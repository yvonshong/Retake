import UIKit

/// Controls which orientations are allowed per-screen.
/// The camera overlay sets `OrientationManager.shared.allowAllOrientations = true`
/// so only the camera page rotates; the home screen stays portrait.
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        if OrientationManager.shared.allowAllOrientations {
            return [.portrait, .landscapeLeft, .landscapeRight]
        }
        return .portrait
    }
}

class OrientationManager: ObservableObject {
    static let shared = OrientationManager()
    @Published var allowAllOrientations = false
}
