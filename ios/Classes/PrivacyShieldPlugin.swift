import Flutter
import UIKit

public class PrivacyShieldPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private var isEnabled = true
  private var protectDuringScreenRecording = false
  private var privacyMode = "black"
  private var privacyColor: UIColor = .black
  
  private var overlayView: UIView?
  private var eventSink: FlutterEventSink?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "privacy_shield", binaryMessenger: registrar.messenger())
    let instance = PrivacyShieldPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    
    let eventChannel = FlutterEventChannel(name: "privacy_shield/events", binaryMessenger: registrar.messenger())
    eventChannel.setStreamHandler(instance)
    
    // Register lifecycle observers
    NotificationCenter.default.addObserver(
        instance, 
        selector: #selector(appWillResignActive), 
        name: UIApplication.willResignActiveNotification, 
        object: nil
    )
    NotificationCenter.default.addObserver(
        instance, 
        selector: #selector(appDidBecomeActive), 
        name: UIApplication.didBecomeActiveNotification, 
        object: nil
    )
    
    // Screenshot and screen recording observers
    NotificationCenter.default.addObserver(
        instance, 
        selector: #selector(didTakeScreenshot), 
        name: UIApplication.userDidTakeScreenshotNotification, 
        object: nil
    )
    NotificationCenter.default.addObserver(
        instance, 
        selector: #selector(screenCaptureDidChange), 
        name: UIScreen.capturedDidChangeNotification, 
        object: nil
    )
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "initialize":
      if let args = call.arguments as? [String: Any] {
        isEnabled = args["enabled"] as? Bool ?? true
        privacyMode = args["mode"] as? String ?? "black"
        protectDuringScreenRecording = args["protectDuringScreenRecording"] as? Bool ?? false
        
        if let colorVal = args["color"] as? Int {
            privacyColor = UIColor(
                red: CGFloat((colorVal >> 16) & 0xFF) / 255.0,
                green: CGFloat((colorVal >> 8) & 0xFF) / 255.0,
                blue: CGFloat(colorVal & 0xFF) / 255.0,
                alpha: CGFloat((colorVal >> 24) & 0xFF) / 255.0
            )
        }
        
        // Immediately check screen capture status if protecting
        if protectDuringScreenRecording {
            checkScreenCaptureStatus()
        } else {
            // Remove overlay if recording, but protection disabled
            if UIScreen.main.isCaptured && UIApplication.shared.applicationState == .active {
                removeOverlay()
            }
        }
      }
      result(nil)
    case "enable":
      isEnabled = true
      if protectDuringScreenRecording {
          checkScreenCaptureStatus()
      }
      result(nil)
    case "disable":
      isEnabled = false
      removeOverlay()
      result(nil)
    case "setMode":
      if let args = call.arguments as? [String: Any], let mode = args["mode"] as? String {
          privacyMode = mode
      }
      result(nil)
    case "dispose":
      isEnabled = false
      removeOverlay()
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
      self.eventSink = events
      return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
      self.eventSink = nil
      return nil
  }

  @objc private func didTakeScreenshot() {
      // Notify Flutter that a screenshot was taken
      eventSink?("screenshot_taken")
  }

  @objc private func screenCaptureDidChange() {
      checkScreenCaptureStatus()
  }
  
  private func checkScreenCaptureStatus() {
      guard isEnabled && protectDuringScreenRecording else { return }
      
      if UIScreen.main.isCaptured {
          showOverlay()
      } else {
          // Only remove if we are not in the background
          if UIApplication.shared.applicationState == .active {
              removeOverlay()
          }
      }
  }

  @objc private func appWillResignActive() {
      guard isEnabled else { return }
      showOverlay()
  }

  @objc private func appDidBecomeActive() {
      // Don't remove if screen recording protection is active and currently recording
      if isEnabled && protectDuringScreenRecording && UIScreen.main.isCaptured {
          return
      }
      removeOverlay()
  }
  
  private func showOverlay() {
      if overlayView != nil { return }
      
      let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
      guard let window = keyWindow else { return }
      
      let view = UIView(frame: window.bounds)
      view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      
      switch privacyMode {
      case "black":
          view.backgroundColor = .black
      case "color":
          view.backgroundColor = privacyColor
      case "blur":
          let blurEffect = UIBlurEffect(style: .dark)
          let blurView = UIVisualEffectView(effect: blurEffect)
          blurView.frame = view.bounds
          blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
          view.addSubview(blurView)
      case "image":
          view.backgroundColor = .black
      default:
          view.backgroundColor = .black
      }
      
      overlayView = view
      window.addSubview(view)
  }
  
  private func removeOverlay() {
      overlayView?.removeFromSuperview()
      overlayView = nil
  }
  
  deinit {
      NotificationCenter.default.removeObserver(self)
  }
}
