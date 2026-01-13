import SwiftUI

struct MenuBarControlsView: View {
    @EnvironmentObject private var player: WebPlayerController
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(player.nowPlaying.title.isEmpty ? "Amazon Music" : player.nowPlaying.title)
                    .font(.headline)
                if !player.nowPlaying.artist.isEmpty {
                    Text(player.nowPlaying.artist)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            PlaybackButtonsView()
                .environmentObject(player)
            Divider()
            Button("Open Mini Player") {
                openWindow(id: "mini-player")
            }
            Button("Close Mini Player") {
                closeMiniPlayer()
            }
            Button("Show Main Window") {
                focusMainWindow()
            }
            Button("Quit Amazon Music") {
                NSApp.terminate(nil)
            }
        }
        .padding(12)
        .frame(minWidth: 220)
    }

    private func focusMainWindow() {
        NSApp.activate(ignoringOtherApps: true)
        for window in NSApp.windows {
            window.makeKeyAndOrderFront(nil)
        }
    }

    private func closeMiniPlayer() {
        for window in NSApp.windows where window.title == "Mini Player" {
            window.performClose(nil)
        }
    }
}
