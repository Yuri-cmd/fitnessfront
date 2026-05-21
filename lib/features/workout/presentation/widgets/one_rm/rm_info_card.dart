import 'package:flutter/material.dart';
import 'package:fit_tracker_app/core/widgets/info_banner.dart';

class RmInfoCard extends StatelessWidget {
  const RmInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoBanner(
      text: 'El 1RM es el peso máximo que puedes levantar en una sola repetición. Calcula con un set reciente.',
    );
  }
}
