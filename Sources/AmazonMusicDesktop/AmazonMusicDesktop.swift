import SwiftUI

@main
struct AmazonMusicDesktopApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var player = WebPlayerController.shared

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(player)
        }
        .defaultSize(width: 1200, height: 800)

        WindowGroup("Mini Player", id: "mini-player") {
            MiniPlayerView()
                .environmentObject(player)
        }
        .defaultSize(width: 360, height: 260)
        .windowStyle(.hiddenTitleBar)

        MenuBarExtra("Amazon Music", systemImage: "music.note") {
            MenuBarControlsView()
                .environmentObject(player)
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        WebPlayerController.shared.configureRemoteCommands()
        WebPlayerController.shared.startNowPlayingUpdates()
    }
}
