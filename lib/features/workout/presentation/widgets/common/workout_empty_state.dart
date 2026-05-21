import 'package:fit_tracker_app/core/widgets/empty_state_view.dart';
export 'package:fit_tracker_app/core/widgets/empty_state_view.dart' show EmptyStateView;

class WorkoutEmptyState extends EmptyStateView {
  const WorkoutEmptyState({
    super.key,
    required super.icon,
    required super.title,
    required super.subtitle,
    super.action,
  });
}
