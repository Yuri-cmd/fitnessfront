import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OneRmController extends GetxController {
  final weightCtrl = TextEditingController();
  final repsCtrl = TextEditingController();
  final results = Rx<Map<String, double>?>(null);

  @override
  void onClose() {
    weightCtrl.dispose();
    repsCtrl.dispose();
    super.onClose();
  }

  double get avgRm {
    final r = results.value;
    if (r == null || r.isEmpty) return 0;
    final vals = r.values.toList();
    return vals.reduce((a, b) => a + b) / vals.length;
  }

  void calculate() {
    FocusManager.instance.primaryFocus?.unfocus();
    final w = double.tryParse(weightCtrl.text.replaceAll(',', '.'));
    final r = int.tryParse(repsCtrl.text);
    if (w == null || r == null || w <= 0 || r <= 0) {
      Get.snackbar(
        'Atención',
        'Ingresa peso y repeticiones válidos.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }
    results.value = {
      'Epley': w * (1 + r / 30),
      'Brzycki': w * (36 / (37 - r)),
      'Lombardi': r == 1 ? w : w * _pow(r.toDouble(), 0.10),
      "O'Conner": w * (1 + r * 0.025),
      'Wathan': 100 * w / (48.8 + 53.8 * _exp(-0.075 * r)),
    };
  }

  static double _pow(double base, double exp) =>
      base <= 0 ? 1 : _exp(exp * _ln(base));

  static double _exp(double x) {
    double result = 1, term = 1;
    for (int i = 1; i < 20; i++) {
      term *= x / i;
      result += term;
    }
    return result;
  }

  static double _ln(double x) {
    if (x <= 0) return 0;
    double y = (x - 1) / (x + 1), sum = 0;
    for (int i = 0; i < 20; i++) {
      sum += _pow(y, (2 * i + 1).toDouble()) / (2 * i + 1);
    }
    return 2 * sum;
  }
}
