import Foundation

struct NowPlayingInfo: Equatable {
    let title: String
    let artist: String
    let artworkURL: String
    let isPlaying: Bool

    static let empty = NowPlayingInfo(title: "", artist: "", artworkURL: "", isPlaying: false)
}
