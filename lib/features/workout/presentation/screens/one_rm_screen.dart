import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_tracker_app/features/workout/presentation/controllers/one_rm_controller.dart';
import 'package:fit_tracker_app/features/workout/presentation/widgets/one_rm/rm_info_card.dart';
import 'package:fit_tracker_app/features/workout/presentation/widgets/one_rm/rm_input_card.dart';
import 'package:fit_tracker_app/features/workout/presentation/widgets/one_rm/rm_results_section.dart';

class OneRmScreen extends StatelessWidget {
  const OneRmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(OneRmController());
    return Scaffold(
      appBar: AppBar(title: const Text('CALCULADORA 1RM')),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              RmInfoCard(),
              SizedBox(height: 24),
              RmInputCard(),
              RmResultsSection(),
            ],
          ),
        ),
      ),
    );
  }
}
