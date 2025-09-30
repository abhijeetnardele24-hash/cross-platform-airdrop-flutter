import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var multipeerHandler: MultipeerConnectivityHandler?
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Set up Multipeer Connectivity platform channel
    let controller = window?.rootViewController as! FlutterViewController
    let multipeerChannel = FlutterMethodChannel(
      name: "com.teamnarcos.airdrop/multipeer",
      binaryMessenger: controller.binaryMessenger
    )
    
    multipeerHandler = MultipeerConnectivityHandler(channel: multipeerChannel)
    
    multipeerChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      guard let self = self else { return }
      
      switch call.method {
      case "startAdvertising":
        if let args = call.arguments as? [String: Any],
           let serviceName = args["serviceName"] as? String,
           let displayName = args["displayName"] as? String {
          self.multipeerHandler?.startAdvertising(serviceName: serviceName, displayName: displayName)
          result(nil)
        } else {
          result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
        }
        
      case "startBrowsing":
        if let args = call.arguments as? [String: Any],
           let serviceName = args["serviceName"] as? String {
          self.multipeerHandler?.startBrowsing(serviceName: serviceName)
          result(nil)
        } else {
          result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
        }
        
      case "sendData":
        if let args = call.arguments as? [String: Any],
           let flutterData = args["data"] as? FlutterStandardTypedData {
          self.multipeerHandler?.sendData(flutterData.data)
          result(nil)
        } else {
          result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
        }
        
      case "stopSession":
        self.multipeerHandler?.stopSession()
        result(nil)
        
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
