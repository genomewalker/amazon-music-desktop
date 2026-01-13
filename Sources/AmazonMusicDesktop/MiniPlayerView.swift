import SwiftUI

struct MiniPlayerView: View {
    @EnvironmentObject private var player: WebPlayerController

    var body: some View {
        VStack(spacing: 12) {
            artworkView
            VStack(spacing: 4) {
                Text(player.nowPlaying.title.isEmpty ? "Amazon Music" : player.nowPlaying.title)
                    .font(.headline)
                    .lineLimit(1)
                Text(player.nowPlaying.artist.isEmpty ? "" : player.nowPlaying.artist)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            PlaybackButtonsView()
                .environmentObject(player)
        }
        .padding(16)
        .background(WindowAccessor { window in
            window.level = .floating
            window.isMovableByWindowBackground = true
            window.titleVisibility = .hidden
            window.standardWindowButton(.miniaturizeButton)?.isHidden = true
            window.standardWindowButton(.zoomButton)?.isHidden = true
        })
    }

    @ViewBuilder
    private var artworkView: some View {
        if let url = URL(string: player.nowPlaying.artworkURL), !player.nowPlaying.artworkURL.isEmpty {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(8)
            } placeholder: {
                placeholderArtwork
            }
            .frame(width: 160, height: 160)
        } else {
            placeholderArtwork
                .frame(width: 160, height: 160)
        }
    }

    private var placeholderArtwork: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.2))
            Image(systemName: "music.note")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
        }
    }
}
