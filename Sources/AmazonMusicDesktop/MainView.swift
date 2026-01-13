import SwiftUI

struct MainView: View {
    @EnvironmentObject private var player: WebPlayerController
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        WebView()
            .toolbar {
                ToolbarItemGroup {
                    Button(action: { player.goBack() }) {
                        Image(systemName: "chevron.left")
                    }
                    Button(action: { player.goForward() }) {
                        Image(systemName: "chevron.right")
                    }
                    Button(action: { player.reload() }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    Button(action: { player.openHome() }) {
                        Image(systemName: "house")
                    }
                    Divider()
                    Button(action: { player.previousTrack() }) {
                        Image(systemName: "backward.fill")
                    }
                    Button(action: { player.togglePlayPause() }) {
                        Image(systemName: "playpause.fill")
                    }
                    Button(action: { player.nextTrack() }) {
                        Image(systemName: "forward.fill")
                    }
                    Divider()
                    Button(action: { openWindow(id: "mini-player") }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
    }
}
