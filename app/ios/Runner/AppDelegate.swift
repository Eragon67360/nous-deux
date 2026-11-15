import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Under UIScene, plugins register after launch, so firebase_messaging
    // 15.x misses the launch notification it registers for APNs on, and the
    // app never gets a push token. Ask for it here; Firebase's own app
    // delegate proxy hands the token to FCM. (firebase_messaging 16.6+ does
    // this itself.)
    application.registerForRemoteNotifications()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // UIScene lifecycle (required from iOS 27): plugins register on the engine
  // that FlutterSceneDelegate creates, not on the app delegate.
  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
