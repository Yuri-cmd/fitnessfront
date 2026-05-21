import ActivityKit
import WidgetKit
import SwiftUI

// ── Atributos compartidos con Runner ─────────────────────────────────────────

struct WorkoutActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var isResting: Bool
        var restEndDate: Date?      // nil cuando no está descansando
        var sessionStartDate: Date  // para calcular el tiempo transcurrido
        var currentSet: Int
        var totalSets: Int
    }

    var routineName: String
    var exerciseName: String
}

// ── Colores ───────────────────────────────────────────────────────────────────

private let primary = Color(red: 0.56, green: 0.73, blue: 0.18)

// ── Lock Screen / Notification view ──────────────────────────────────────────

struct LockScreenView: View {
    let state: WorkoutActivityAttributes.ContentState
    let attrs: WorkoutActivityAttributes

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "dumbbell.fill")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(primary)

            VStack(alignment: .leading, spacing: 3) {
                Text(attrs.routineName)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                Text(attrs.exerciseName)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                Text("Serie \(state.currentSet)/\(state.totalSets)")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }

            Spacer()

            if state.isResting, let restEnd = state.restEndDate {
                VStack(spacing: 0) {
                    // SwiftUI cuenta hacia atrás automáticamente — no necesita updates
                    Text(timerInterval: Date.now...restEnd, countsDown: true)
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(primary)
                        .monospacedDigit()
                    Text("descanso")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(spacing: 0) {
                    // SwiftUI cuenta hacia arriba automáticamente
                    Text(state.sessionStartDate, style: .timer)
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(primary)
                        .monospacedDigit()
                    Text("sesión")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// ── Widget entry point ────────────────────────────────────────────────────────

@available(iOS 16.2, *)
struct WorkoutActivityExtension: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WorkoutActivityAttributes.self) { context in
            LockScreenView(state: context.state, attrs: context.attributes)
                .background(Color(UIColor.systemBackground))

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label(context.attributes.exerciseName, systemImage: "dumbbell.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(primary)
                        .lineLimit(1)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Serie \(context.state.currentSet)/\(context.state.totalSets)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.secondary)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    if context.state.isResting, let restEnd = context.state.restEndDate {
                        HStack {
                            Image(systemName: "timer").foregroundColor(primary)
                            Text("Descansando")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(timerInterval: Date.now...restEnd, countsDown: true)
                                .font(.system(size: 18, weight: .bold, design: .monospaced))
                                .foregroundColor(primary)
                                .monospacedDigit()
                        }
                        .padding(.horizontal, 4)
                    } else {
                        HStack {
                            Image(systemName: "bolt.fill").foregroundColor(primary)
                            Text("¡A entrenar!")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(context.state.sessionStartDate, style: .timer)
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(.secondary)
                                .monospacedDigit()
                        }
                        .padding(.horizontal, 4)
                    }
                }
            } compactLeading: {
                Image(systemName: "dumbbell.fill")
                    .foregroundColor(primary)
                    .font(.system(size: 12))
            } compactTrailing: {
                if context.state.isResting, let restEnd = context.state.restEndDate {
                    Text(timerInterval: Date.now...restEnd, countsDown: true)
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(primary)
                        .monospacedDigit()
                        .frame(maxWidth: 44)
                } else {
                    Image(systemName: "bolt.fill")
                        .foregroundColor(primary)
                        .font(.system(size: 12))
                }
            } minimal: {
                Image(systemName: context.state.isResting ? "timer" : "dumbbell.fill")
                    .foregroundColor(primary)
            }
        }
    }
}
