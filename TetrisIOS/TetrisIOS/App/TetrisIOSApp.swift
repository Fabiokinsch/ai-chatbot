import SwiftUI

@main
struct TetrisIOSApp: App {
    var body: some Scene {
        WindowGroup {
            GameView()
                .preferredColorScheme(.dark)
                .statusBarHidden()
        }
    }
}
