package com.example.privacy_shield

import android.app.Activity
import android.app.Application
import android.graphics.Color
import android.os.Bundle
import android.view.View
import android.view.ViewGroup
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.ImageView
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.UserLeaveHintListener

class PrivacyShieldPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, Application.ActivityLifecycleCallbacks, UserLeaveHintListener {

    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var overlayView: View? = null

    // Options
    private var isEnabled = true
    private var privacyMode = "black"
    private var privacyColor = Color.BLACK
    private var preventScreenshots = false
    private var protectDuringScreenRecording = false

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "privacy_shield")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "initialize" -> {
                val enabled = call.argument<Boolean>("enabled") ?: true
                val mode = call.argument<String>("mode") ?: "black"
                val color = call.argument<Long>("color")?.toInt() ?: Color.BLACK
                val preventScreenshotsArg = call.argument<Boolean>("preventScreenshots") ?: false
                val protectDuringScreenRecordingArg = call.argument<Boolean>("protectDuringScreenRecording") ?: false

                isEnabled = enabled
                privacyMode = mode
                privacyColor = color
                preventScreenshots = preventScreenshotsArg
                protectDuringScreenRecording = protectDuringScreenRecordingArg

                applyScreenshotPolicy()
                result.success(null)
            }
            "enable" -> {
                isEnabled = true
                applyScreenshotPolicy()
                result.success(null)
            }
            "disable" -> {
                isEnabled = false
                removeScreenshotPolicy()
                removeOverlay()
                result.success(null)
            }
            "setMode" -> {
                val mode = call.argument<String>("mode")
                if (mode != null) {
                    privacyMode = mode
                }
                result.success(null)
            }
            "dispose" -> {
                isEnabled = false
                removeScreenshotPolicy()
                removeOverlay()
                result.success(null)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    // ActivityAware implementation
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        activity?.application?.registerActivityLifecycleCallbacks(this)
        binding.addOnUserLeaveHintListener(this)
        applyScreenshotPolicy()
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity?.application?.unregisterActivityLifecycleCallbacks(this)
        activity = null
        // ActivityPluginBinding does not have a remove method for this in older versions, 
        // it auto-clears on detach.
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        activity?.application?.registerActivityLifecycleCallbacks(this)
        binding.addOnUserLeaveHintListener(this)
        applyScreenshotPolicy()
    }

    override fun onDetachedFromActivity() {
        activity?.application?.unregisterActivityLifecycleCallbacks(this)
        activity = null
    }

    override fun onUserLeaveHint() {
        if (isEnabled && activity != null) {
            activity!!.window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
            showOverlay(activity!!)
        }
    }

    // Lifecycle Callbacks
    override fun onActivityCreated(act: Activity, savedInstanceState: Bundle?) {}
    override fun onActivityStarted(act: Activity) {}

    override fun onActivityResumed(act: Activity) {
        if (act == activity) {
            applyScreenshotPolicy() // Restore normal policy
            removeOverlay()
        }
    }

    override fun onActivityPaused(act: Activity) {
        if (act == activity && isEnabled) {
            // Apply FLAG_SECURE unconditionally when paused to hide the Recents preview
            act.window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
            showOverlay(act)
        }
    }

    override fun onActivityStopped(act: Activity) {}
    override fun onActivitySaveInstanceState(act: Activity, outState: Bundle) {}
    override fun onActivityDestroyed(act: Activity) {}

    private fun applyScreenshotPolicy() {
        if (isEnabled && (preventScreenshots || protectDuringScreenRecording)) {
            activity?.window?.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        } else {
            removeScreenshotPolicy()
        }
    }

    private fun removeScreenshotPolicy() {
        activity?.window?.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
    }

    private fun showOverlay(act: Activity) {
        if (overlayView != null) return

        val decorView = act.window.decorView as ViewGroup
        val frameLayout = FrameLayout(act)
        frameLayout.layoutParams = ViewGroup.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT
        )

        when (privacyMode) {
            "black" -> frameLayout.setBackgroundColor(Color.BLACK)
            "color" -> frameLayout.setBackgroundColor(privacyColor)
            "blur", "image" -> {
                // For simplicity in this example, fallback to a solid color if complex blur is not implemented
                frameLayout.setBackgroundColor(Color.DKGRAY)
            }
            else -> frameLayout.setBackgroundColor(Color.BLACK)
        }

        frameLayout.isClickable = true
        overlayView = frameLayout
        decorView.addView(overlayView)
        overlayView?.bringToFront()
        decorView.requestLayout()
        decorView.invalidate()
    }

    private fun removeOverlay() {
        overlayView?.let { view ->
            val decorView = activity?.window?.decorView as? ViewGroup
            decorView?.removeView(view)
            overlayView = null
        }
    }
}
