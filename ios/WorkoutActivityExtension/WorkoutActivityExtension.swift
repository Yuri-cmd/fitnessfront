import ActivityKit
import WidgetKit
import SwiftUI

// ── Atributos compartidos con Runner ─────────────────────────────────────────

struct WorkoutActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var isResting: Bool
        var restRemaining: Int   // segundos
        var restTotal: Int
        var elapsedSeconds: Int
        var currentSet: Int
        var totalSets: Int
    }

    var routineName: String
    var exerciseName: String
}

// ── Colores ───────────────────────────────────────────────────────────────────

private let primary = Color(red: 0.56, green: 0.73, blue: 0.18)   // AppColors.primary

// ── Vistas ────────────────────────────────────────────────────────────────────

struct RestTimerArc: View {
    let remaining: Int
    let total: Int

    private var progress: Double {
        guard total > 0 else { return 1 }
        return Double(remaining) / Double(total)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(primary.opacity(0.2), lineWidth: 3)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(primary, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: remaining)
        }
    }
}

// Lock Screen / Notification view
struct LockScreenView: View {
    let state: WorkoutActivityAttributes.ContentState
    let attrs: WorkoutActivityAttributes

    var timerText: String {
        let m = state.restRemaining / 60
        let s = state.restRemaining % 60
        return String(format: "%02d:%02d", m, s)
    }

    var elapsedText: String {
        let m = state.elapsedSeconds / 60
        let s = state.elapsedSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    var body: some View {
        HStack(spacing: 16) {
            // Icono
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

            if state.isResting {
                ZStack {
                    RestTimerArc(remaining: state.restRemaining, total: state.restTotal)
                        .frame(width: 52, height: 52)
                    VStack(spacing: 0) {
                        Text(timerText)
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundColor(primary)
                        Text("descanso")
                            .font(.system(size: 8))
                            .foregroundColor(.secondary)
                    }
                }
            } else {
                VStack(spacing: 2) {
                    Text(elapsedText)
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(primary)
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
            // Lock Screen / banner
            LockScreenView(state: context.state, attrs: context.attributes)
                .background(Color(UIColor.systemBackground))

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded
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
                    if context.state.isResting {
                        HStack {
                            Image(systemName: "timer")
                                .foregroundColor(primary)
                            Text("Descansando")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            Spacer()
                            let m = context.state.restRemaining / 60
                            let s = context.state.restRemaining % 60
                            Text(String(format: "%02d:%02d", m, s))
                                .font(.system(size: 18, weight: .bold, design: .monospaced))
                                .foregroundColor(primary)
                        }
                        .padding(.horizontal, 4)
                    } else {
                        HStack {
                            Image(systemName: "bolt.fill")
                                .foregroundColor(primary)
                            Text("¡A entrenar!")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            Spacer()
                            let m = context.state.elapsedSeconds / 60
                            let s = context.state.elapsedSeconds % 60
                            Text(String(format: "%02d:%02d", m, s))
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 4)
                    }
                }
            } compactLeading: {
                Image(systemName: "dumbbell.fill")
                    .foregroundColor(primary)
                    .font(.system(size: 12))
            } compactTrailing: {
                if context.state.isResting {
                    let m = context.state.restRemaining / 60
                    let s = context.state.restRemaining % 60
                    Text(String(format: "%d:%02d", m, s))
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(primary)
                } else {
                    Image(systemName: "bolt.fill")
                        .foregroundColor(primary)
                        .font(.system(size: 12))
                }
            } minimal: {
                if context.state.isResting {
                    Image(systemName: "timer")
                        .foregroundColor(primary)
                } else {
                    Image(systemName: "dumbbell.fill")
                        .foregroundColor(primary)
                }
            }
        }
    }
}
