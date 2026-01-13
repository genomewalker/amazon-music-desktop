import SwiftUI
import WebKit

struct WebView: NSViewRepresentable {
    @EnvironmentObject private var player: WebPlayerController

    func makeCoordinator() -> Coordinator {
        Coordinator(player: player)
    }

    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        player.attachWebView(webView)
        return webView
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        return
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        private let player: WebPlayerController

        init(player: WebPlayerController) {
            self.player = player
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            player.startNowPlayingUpdates()
        }
    }
}
