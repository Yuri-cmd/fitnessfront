import Flutter
import UIKit
import ActivityKit
import UserNotifications

// ── Shared attributes (must match WorkoutActivityExtension.swift exactly) ─────

struct WorkoutActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var exerciseName: String       // moved here so updates reflect the current exercise
        var isResting: Bool
        var restEndDate: Date?
        var sessionStartDate: Date
        var currentSet: Int
        var totalSets: Int
    }
    var routineName: String
}

// ── Live Activity manager ─────────────────────────────────────────────────────

@available(iOS 16.1, *)
private class LiveActivityManager {

    private var currentActivity: Activity<WorkoutActivityAttributes>?
    private let restNotificationID = "com.powerstack.rest_end"

    func startActivity(
        routineName: String,
        exerciseName: String,
        currentSet: Int,
        totalSets: Int,
        sessionStartMillis: Double
    ) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let attrs = WorkoutActivityAttributes(routineName: routineName)
        let sessionStart = Date(timeIntervalSince1970: sessionStartMillis / 1000)
        let state = WorkoutActivityAttributes.ContentState(
            exerciseName: exerciseName,
            isResting: false,
            restEndDate: nil,
            sessionStartDate: sessionStart,
            currentSet: currentSet,
            totalSets: totalSets
        )
        do {
            if #available(iOS 16.2, *) {
                currentActivity = try Activity.request(
                    attributes: attrs,
                    content: .init(state: state, staleDate: nil),
                    pushType: nil
                )
            } else {
                currentActivity = try Activity.request(
                    attributes: attrs,
                    contentState: state,
                    pushType: nil
                )
            }
        } catch {
            print("[LiveActivity] start error: \(error)")
        }
    }

    func updateActivity(
        exerciseName: String,
        isResting: Bool,
        restEndMillis: Double?,
        sessionStartMillis: Double,
        currentSet: Int,
        totalSets: Int
    ) {
        guard let activity = currentActivity else { return }
        let sessionStart = Date(timeIntervalSince1970: sessionStartMillis / 1000)
        let restEnd: Date? = restEndMillis.map { Date(timeIntervalSince1970: $0 / 1000) }
        let newState = WorkoutActivityAttributes.ContentState(
            exerciseName: exerciseName,
            isResting: isResting,
            restEndDate: restEnd,
            sessionStartDate: sessionStart,
            currentSet: currentSet,
            totalSets: totalSets
        )

        if #available(iOS 16.2, *) {
            Task { await activity.update(ActivityContent(state: newState, staleDate: nil)) }
        } else {
            Task { await activity.update(using: newState) }
        }

        // Schedule/cancel background notification for rest-end sound
        if isResting, let restEnd = restEnd {
            scheduleRestNotification(at: restEnd)
        } else {
            cancelRestNotification()
        }
    }

    func endActivity() {
        cancelRestNotification()
        guard let activity = currentActivity else { return }
        currentActivity = nil
        if #available(iOS 16.2, *) {
            Task { await activity.end(
                ActivityContent(state: activity.content.state, staleDate: nil),
                dismissalPolicy: .immediate
            )}
        } else {
            Task { await activity.end(using: nil, dismissalPolicy: .immediate) }
        }
    }

    // ── Background rest-end notification ──────────────────────────────────────

    private func scheduleRestNotification(at date: Date) {
        cancelRestNotification()
        let interval = date.timeIntervalSinceNow
        guard interval > 0 else { return }

        let content = UNMutableNotificationContent()
        content.title = "¡Descanso terminado!"
        content.body = "Es hora de tu siguiente serie 💪"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let request = UNNotificationRequest(identifier: restNotificationID, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("[LiveActivity] notification error: \(error)")
            }
        }
    }

    private func cancelRestNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [restNotificationID])
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

        // Request notification permission for background rest-end alerts
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }

        if #available(iOS 16.1, *) {
            setupLiveActivityChannel()
        }
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    @available(iOS 16.1, *)
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
                    routineName:        args["routineName"]        as? String ?? "",
                    exerciseName:       args["exerciseName"]       as? String ?? "",
                    currentSet:         args["currentSet"]         as? Int    ?? 1,
                    totalSets:          args["totalSets"]          as? Int    ?? 1,
                    sessionStartMillis: args["sessionStartMillis"] as? Double ?? 0
                )
                result(nil)

            case "updateActivity":
                guard let args = call.arguments as? [String: Any] else {
                    result(FlutterError(code: "BAD_ARGS", message: "expected map", details: nil))
                    return
                }
                manager.updateActivity(
                    exerciseName:       args["exerciseName"]       as? String ?? "",
                    isResting:          args["isResting"]          as? Bool   ?? false,
                    restEndMillis:      args["restEndMillis"]      as? Double,
                    sessionStartMillis: args["sessionStartMillis"] as? Double ?? 0,
                    currentSet:         args["currentSet"]         as? Int    ?? 1,
                    totalSets:          args["totalSets"]          as? Int    ?? 1
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
