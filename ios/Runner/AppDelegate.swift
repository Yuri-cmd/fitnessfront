import Flutter
import UIKit
import ActivityKit

// ── Shared attributes (must match WorkoutActivityExtension.swift exactly) ─────

struct WorkoutActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var isResting: Bool
        var restRemaining: Int
        var restTotal: Int
        var elapsedSeconds: Int
        var currentSet: Int
        var totalSets: Int
    }
    var routineName: String
    var exerciseName: String
}

// ── Live Activity manager ─────────────────────────────────────────────────────

@available(iOS 16.2, *)
private class LiveActivityManager {

    private var currentActivity: Activity<WorkoutActivityAttributes>?

    func startActivity(
        routineName: String,
        exerciseName: String,
        currentSet: Int,
        totalSets: Int,
        elapsedSeconds: Int
    ) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let attrs = WorkoutActivityAttributes(routineName: routineName, exerciseName: exerciseName)
        let state = WorkoutActivityAttributes.ContentState(
            isResting: false,
            restRemaining: 0,
            restTotal: 0,
            elapsedSeconds: elapsedSeconds,
            currentSet: currentSet,
            totalSets: totalSets
        )
        do {
            currentActivity = try Activity.request(
                attributes: attrs,
                content: .init(state: state, staleDate: nil),
                pushType: nil
            )
        } catch {
            print("[LiveActivity] start error: \(error)")
        }
    }

    func updateActivity(
        isResting: Bool,
        restRemaining: Int,
        restTotal: Int,
        elapsedSeconds: Int,
        currentSet: Int,
        totalSets: Int
    ) {
        guard let activity = currentActivity else { return }
        let newState = WorkoutActivityAttributes.ContentState(
            isResting: isResting,
            restRemaining: restRemaining,
            restTotal: restTotal,
            elapsedSeconds: elapsedSeconds,
            currentSet: currentSet,
            totalSets: totalSets
        )
        Task { await activity.update(using: newState) }
    }

    func endActivity() {
        guard let activity = currentActivity else { return }
        Task { await activity.end(
            ActivityContent<WorkoutActivityAttributes.ContentState>(state: activity.content.state, staleDate: nil),
            dismissalPolicy: .immediate
        )}
        currentActivity = nil
    }
}

// ── AppDelegate ───────────────────────────────────────────────────────────────

@main
@objc class AppDelegate: FlutterAppDelegate {

    private var liveActivityManager: Any?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        if #available(iOS 16.2, *) {
            setupLiveActivityChannel()
        }
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    @available(iOS 16.2, *)
    private func setupLiveActivityChannel() {
        let manager = LiveActivityManager()
        liveActivityManager = manager

        guard let controller = window?.rootViewController as? FlutterViewController else { return }
        let channel = FlutterMethodChannel(
            name: "com.powerstack.live_activity",
            binaryMessenger: controller.binaryMessenger
        )

        channel.setMethodCallHandler { [weak manager] call, result in
            guard let manager = manager else {
                result(FlutterError(code: "UNAVAILABLE", message: nil, details: nil))
                return
            }
            switch call.method {
            case "startActivity":
                guard let args = call.arguments as? [String: Any] else {
                    result(FlutterError(code: "BAD_ARGS", message: "expected map", details: nil))
                    return
                }
                manager.startActivity(
                    routineName:    args["routineName"]    as? String ?? "",
                    exerciseName:   args["exerciseName"]   as? String ?? "",
                    currentSet:     args["currentSet"]     as? Int    ?? 1,
                    totalSets:      args["totalSets"]      as? Int    ?? 1,
                    elapsedSeconds: args["elapsedSeconds"] as? Int    ?? 0
                )
                result(nil)

            case "updateActivity":
                guard let args = call.arguments as? [String: Any] else {
                    result(FlutterError(code: "BAD_ARGS", message: "expected map", details: nil))
                    return
                }
                manager.updateActivity(
                    isResting:      args["isResting"]      as? Bool ?? false,
                    restRemaining:  args["restRemaining"]  as? Int  ?? 0,
                    restTotal:      args["restTotal"]      as? Int  ?? 0,
                    elapsedSeconds: args["elapsedSeconds"] as? Int  ?? 0,
                    currentSet:     args["currentSet"]     as? Int  ?? 1,
                    totalSets:      args["totalSets"]      as? Int  ?? 1
                )
                result(nil)

            case "endActivity":
                manager.endActivity()
                result(nil)

            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
}
