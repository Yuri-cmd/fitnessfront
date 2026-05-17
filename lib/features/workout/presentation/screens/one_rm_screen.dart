import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';

class OneRmScreen extends StatefulWidget {
  const OneRmScreen({super.key});

  @override
  State<OneRmScreen> createState() => _OneRmScreenState();
}

class _OneRmScreenState extends State<OneRmScreen> {
  final _weightCtrl = TextEditingController();
  final _repsCtrl = TextEditingController();
  Map<String, double>? _results;

  @override
  void dispose() {
    _weightCtrl.dispose();
    _repsCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    FocusScope.of(context).unfocus();
    final w = double.tryParse(_weightCtrl.text.replaceAll(',', '.'));
    final r = int.tryParse(_repsCtrl.text);
    if (w == null || r == null || w <= 0 || r <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Ingresa peso y repeticiones válidos.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }
    setState(() {
      _results = {
        'Epley': w * (1 + r / 30),
        'Brzycki': w * (36 / (37 - r)),
        'Lombardi': w * (r.toDouble()).abs().clamp(1, 30).toDouble() == 1
            ? w
            : w * _pow(r.toDouble(), 0.10),
        'O\'Conner': w * (1 + r * 0.025),
        'Wathan': 100 * w / (48.8 + 53.8 * _exp(-0.075 * r)),
      };
    });
  }

  double _pow(double base, double exp) =>
      base <= 0 ? 1 : _exp(exp * _ln(base));

  double _exp(double x) {
    double result = 1, term = 1;
    for (int i = 1; i < 20; i++) {
      term *= x / i;
      result += term;
    }
    return result;
  }

  double _ln(double x) {
    if (x <= 0) return 0;
    double y = (x - 1) / (x + 1), sum = 0;
    for (int i = 0; i < 20; i++) {
      sum += _pow(y, (2 * i + 1).toDouble()) / (2 * i + 1);
    }
    return 2 * sum;
  }

  double get _avgRm {
    if (_results == null) return 0;
    final vals = _results!.values.toList();
    return vals.reduce((a, b) => a + b) / vals.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CALCULADORA 1RM')),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.info_outline,
                            color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'El 1RM es el peso máximo que puedes levantar en una sola repetición. Calcula con un set reciente.',
                          style: TextStyle(fontSize: 13, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Inputs
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('PESO LEVANTADO'),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _weightCtrl,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9.,]'))
                                  ],
                                  textInputAction: TextInputAction.next,
                                  decoration: const InputDecoration(
                                    hintText: '100',
                                    suffixText: 'kg',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label('REPETICIONES'),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _repsCtrl,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (_) => _calculate(),
                                  decoration: const InputDecoration(
                                    hintText: '5',
                                    suffixText: 'reps',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _calculate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text(
                            'CALCULAR',
                            style: TextStyle(
                                fontWeight: FontWeight.w900, letterSpacing: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Resultados
              if (_results != null) ...[
                const SizedBox(height: 24),

                // Promedio destacado
                Card(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        const Icon(Icons.emoji_events,
                            color: AppColors.primary, size: 32),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'PROMEDIO ESTIMADO',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  letterSpacing: 1.5),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_avgRm.toStringAsFixed(1)} kg',
                              style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Por fórmula
                _label('DESGLOSE POR FÓRMULA'),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: _results!.entries.toList().asMap().entries.map((e) {
                      final isLast = e.key == _results!.length - 1;
                      final name = e.value.key;
                      final val = e.value.value;
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 14),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                ),
                                Text(
                                  '${val.toStringAsFixed(1)} kg',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                          if (!isLast) const Divider(height: 1, indent: 20),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),

                // Tabla de porcentajes
                _label('TABLA DE CARGA'),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      _pctHeader(),
                      ...[100, 95, 90, 85, 80, 75, 70, 65, 60].asMap().entries.map((e) {
                        final pct = e.value;
                        final isEven = e.key.isEven;
                        return _pctRow(pct, _avgRm * pct / 100, isEven);
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          letterSpacing: 1.5,
        ),
      );

  Widget _pctHeader() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: const Row(
          children: [
            Expanded(
                child: Text('%',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12))),
            Expanded(
                child: Text('Peso',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12))),
            Expanded(
                child: Text('Reps aprox.',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12))),
          ],
        ),
      );

  Widget _pctRow(int pct, double weight, bool isEven) {
    final repsMap = {
      100: 1,
      95: 2,
      90: 3,
      85: 4,
      80: 5,
      75: 6,
      70: 8,
      65: 10,
      60: 12
    };
    return Container(
      color: isEven
          ? Colors.transparent
          : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
              child: Text('$pct%',
                  style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(
              child: Text('${weight.toStringAsFixed(1)} kg',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.bold))),
          Expanded(
              child: Text('~${repsMap[pct]} reps',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12))),
        ],
      ),
    );
  }
}
