import SwiftUI

@main
struct SlideTimerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @State private var timerModel  = TimerModel()
    @State private var appearance  = AppearanceSettings()

    var body: some Scene {
        WindowGroup("SlideTimer") {
            ControlWindow()
                .environment(timerModel)
                .environment(appearance)
        }
        .defaultSize(width: 400, height: 650)
        .windowResizability(.contentMinSize)
    }
}
