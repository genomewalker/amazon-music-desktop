import SwiftUI

struct PlaybackButtonsView: View {
    @EnvironmentObject private var player: WebPlayerController

    var body: some View {
        HStack(spacing: 16) {
            Button(action: { player.previousTrack() }) {
                Image(systemName: "backward.fill")
            }
            Button(action: { player.togglePlayPause() }) {
                Image(systemName: "playpause.fill")
            }
            Button(action: { player.nextTrack() }) {
                Image(systemName: "forward.fill")
            }
        }
        .buttonStyle(.borderless)
    }
}
