import AppKit
import Combine
import Foundation
import MediaPlayer
import WebKit

@MainActor
final class WebPlayerController: ObservableObject {
    static let shared = WebPlayerController()

    @Published private(set) var nowPlaying = NowPlayingInfo.empty

    let homeURL = URL(string: "https://music.amazon.com/")!

    private var webView: WKWebView?
    private var updateTimer: Timer?
    private var artworkTask: URLSessionDataTask?
    private var lastArtworkURL: String?

    func attachWebView(_ webView: WKWebView) {
        self.webView = webView
        if webView.url == nil {
            webView.load(URLRequest(url: homeURL))
        }
    }

    func openHome() {
        webView?.load(URLRequest(url: homeURL))
    }

    func goBack() {
        webView?.goBack()
    }

    func goForward() {
        webView?.goForward()
    }

    func reload() {
        webView?.reload()
    }

    func togglePlayPause() {
        runScript(PlaybackScripts.playPause)
    }

    func nextTrack() {
        runScript(PlaybackScripts.next)
    }

    func previousTrack() {
        runScript(PlaybackScripts.previous)
    }

    func configureRemoteCommands() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.isEnabled = true

        commandCenter.playCommand.addTarget { _ in
            self.runScript(PlaybackScripts.play)
            return .success
        }
        commandCenter.pauseCommand.addTarget { _ in
            self.runScript(PlaybackScripts.pause)
            return .success
        }
        commandCenter.togglePlayPauseCommand.addTarget { _ in
            self.togglePlayPause()
            return .success
        }
        commandCenter.nextTrackCommand.addTarget { _ in
            self.nextTrack()
            return .success
        }
        commandCenter.previousTrackCommand.addTarget { _ in
            self.previousTrack()
            return .success
        }
    }

    func startNowPlayingUpdates() {
        guard updateTimer == nil else { return }
        updateTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.fetchNowPlaying()
            }
        }
    }

    private func fetchNowPlaying() {
        runScript(PlaybackScripts.nowPlaying) { [weak self] result in
            guard let self, let json = result as? String else { return }
            guard let data = json.data(using: .utf8) else { return }
            do {
                let payload = try JSONDecoder().decode(NowPlayingPayload.self, from: data)
                let info = NowPlayingInfo(
                    title: payload.title,
                    artist: payload.artist,
                    artworkURL: payload.artworkURL,
                    isPlaying: payload.isPlaying
                )
                DispatchQueue.main.async {
                    self.nowPlaying = info
                    self.updateNowPlayingCenter(with: info)
                }
            } catch {
                return
            }
        }
    }

    private func updateNowPlayingCenter(with info: NowPlayingInfo) {
        var nowPlayingInfo: [String: Any] = [:]
        if !info.title.isEmpty {
            nowPlayingInfo[MPMediaItemPropertyTitle] = info.title
        }
        if !info.artist.isEmpty {
            nowPlayingInfo[MPMediaItemPropertyArtist] = info.artist
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        MPNowPlayingInfoCenter.default().playbackState = info.isPlaying ? .playing : .paused
        updateArtwork(for: info)
    }

    private func updateArtwork(for info: NowPlayingInfo) {
        let urlString = info.artworkURL
        guard !urlString.isEmpty, urlString != lastArtworkURL, let url = URL(string: urlString) else { return }
        lastArtworkURL = urlString
        artworkTask?.cancel()
        artworkTask = URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data, let image = NSImage(data: data) else { return }
            let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
            DispatchQueue.main.async {
                var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]
                nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
                MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
            }
        }
        artworkTask?.resume()
    }

    private func runScript(_ script: String, completion: ((Any?) -> Void)? = nil) {
        webView?.evaluateJavaScript(script) { result, _ in
            completion?(result)
        }
    }
}

private struct NowPlayingPayload: Decodable {
    let title: String
    let artist: String
    let artworkURL: String
    let isPlaying: Bool
}

private enum PlaybackScripts {
    static let playPause = baseClickScript(labels: ["play", "pause"])
    static let play = baseClickScript(labels: ["play"])
    static let pause = baseClickScript(labels: ["pause"])
    static let next = baseClickScript(labels: ["next", "skip"])
    static let previous = baseClickScript(labels: ["previous", "back"])

    static let nowPlaying = """
    (function() {
        const textFrom = (selectors) => {
            for (const selector of selectors) {
                const element = document.querySelector(selector);
                if (element && element.textContent) {
                    const value = element.textContent.trim();
                    if (value.length > 0) {
                        return value;
                    }
                }
            }
            return "";
        };

        let title = "";
        let artist = "";
        let artworkURL = "";
        let isPlaying = false;

        if (navigator.mediaSession && navigator.mediaSession.metadata) {
            const metadata = navigator.mediaSession.metadata;
            title = metadata.title || "";
            artist = metadata.artist || "";
            if (metadata.artwork && metadata.artwork.length > 0) {
                const artwork = metadata.artwork[metadata.artwork.length - 1];
                artworkURL = artwork.src || "";
            }
            isPlaying = navigator.mediaSession.playbackState === 'playing';
        }

        if (!title) {
            title = textFrom([
                '[data-testid="player-track-title"]',
                '[data-testid="track-title"]',
                '[data-testid="trackTitle"]',
                '.playerControls__trackTitle',
                '.musicPlayer__trackTitle'
            ]);
        }
        if (!artist) {
            artist = textFrom([
                '[data-testid="player-track-artist"]',
                '[data-testid="track-artist"]',
                '[data-testid="trackArtist"]',
                '.playerControls__trackArtist',
                '.musicPlayer__trackArtist'
            ]);
        }
        if (!artworkURL) {
            const artworkElement = document.querySelector('[data-testid="player-artwork"] img')
                || document.querySelector('[data-testid="track-artwork"] img')
                || document.querySelector('.playerControls__artwork img')
                || document.querySelector('img[alt*="cover"]');
            artworkURL = artworkElement && artworkElement.src ? artworkElement.src : "";
        }
        if (!isPlaying) {
            const buttons = Array.from(document.querySelectorAll('button'));
            isPlaying = buttons.some((button) => {
                const label = (button.getAttribute('aria-label') || "").toLowerCase();
                return label.includes('pause');
            });
        }
        return JSON.stringify({
            title: title,
            artist: artist,
            artworkURL: artworkURL,
            isPlaying: isPlaying
        });
    })();
    """

    private static func baseClickScript(labels: [String]) -> String {
        let labelList = labels.map { "\"\($0)\"" }.joined(separator: ",")
        return """
        (function() {
            const labels = [\(labelList)];
            const buttons = Array.from(document.querySelectorAll('button'));
            for (const button of buttons) {
                const label = (button.getAttribute('aria-label') || '').toLowerCase();
                if (labels.some((match) => label.includes(match))) {
                    button.click();
                    return true;
                }
            }
            return false;
        })();
        """
    }
}
