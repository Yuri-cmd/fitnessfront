import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';

enum _Phase { ready, resting, finished }

class TrainingSessionScreen extends StatefulWidget {
  final dynamic routine;
  const TrainingSessionScreen({super.key, required this.routine});

  @override
  State<TrainingSessionScreen> createState() => _TrainingSessionScreenState();
}

class _TrainingSessionScreenState extends State<TrainingSessionScreen> {
  // ── Timers ────────────────────────────────────────────────────────────────
  int _elapsed = 0;
  Timer? _timer;

  int _restRemaining = 90;
  int _restTime = 90;
  Timer? _restTimer;

  // ── Estado ────────────────────────────────────────────────────────────────
  _Phase _phase = _Phase.ready;
  int _currentExIdx = 0;
  int _currentSetIdx = 0;
  int _completedSetNum = 0;

  // _sets[exIdx][setIdx] = {'done': bool, 'weight': ''}
  late List<List<Map<String, dynamic>>> _sets;

  // Un controller por set
  late List<List<TextEditingController>> _controllers;

  // ── Init / dispose ────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _buildSets();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed++);
    });
    _autoFillCurrentWeight();
  }

  void _buildSets() {
    final exercises = _exercises;
    _sets = exercises.map((ex) {
      final n = (ex['pivot']['sets'] as num).toInt();
      return List.generate(n, (_) => {'done': false, 'weight': ''});
    }).toList();

    _controllers = exercises.map((ex) {
      final n = (ex['pivot']['sets'] as num).toInt();
      return List.generate(n, (_) => TextEditingController());
    }).toList();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _restTimer?.cancel();
    for (final row in _controllers) {
      for (final c in row) {
        c.dispose();
      }
    }
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  List<dynamic> get _exercises =>
      widget.routine['exercises'] as List<dynamic>? ?? [];

  dynamic get _currentEx => _exercises[_currentExIdx];

  bool get _isLastSet =>
      _currentSetIdx >= ((_currentEx['pivot']['sets'] as num).toInt()) - 1;

  bool get _isLastEx => _currentExIdx >= _exercises.length - 1;

  bool get _isLastOfAll => _isLastEx && _isLastSet;

  bool get _canGoBack => _currentExIdx > 0 || _currentSetIdx > 0;

  int get _exDoneCount =>
      _sets.where((s) => s.every((x) => x['done'] == true)).length;

  double get _progressPct =>
      _exercises.isEmpty ? 0 : _exDoneCount / _exercises.length;

  String get _nextActionLabel {
    if (_isLastSet) return _isLastEx ? 'TERMINAR' : 'SIGUIENTE EJERCICIO';
    return 'SIGUIENTE SERIE';
  }

  double? _exMaxWeight(int idx) {
    final weights = _controllers[idx]
        .map((c) => double.tryParse(c.text.replaceAll(',', '.')) ?? 0.0)
        .where((w) => w > 0)
        .toList();
    return weights.isEmpty ? null : weights.reduce((a, b) => a > b ? a : b);
  }

  String _formatTime(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  List<Map<String, dynamic>> _collectSetData() {
    final result = <Map<String, dynamic>>[];
    for (int i = 0; i < _exercises.length; i++) {
      final ex = _exercises[i];
      for (int j = 0; j < _sets[i].length; j++) {
        result.add({
          'exercise_id': ex['id'],
          'set_number': j + 1,
          'reps_done': (ex['pivot']['reps'] as num).toInt(),
          'weight_kg':
              double.tryParse(_controllers[i][j].text.replaceAll(',', '.')) ??
                  0.0,
        });
      }
    }
    return result;
  }

  // ── Lógica de sesión ──────────────────────────────────────────────────────
  void _completeSet() {
    HapticFeedback.mediumImpact();
    setState(() {
      _sets[_currentExIdx][_currentSetIdx]['done'] = true;
      _completedSetNum = _currentSetIdx + 1;
    });

    if (_isLastOfAll) {
      setState(() => _phase = _Phase.finished);
    } else {
      setState(() {
        _phase = _Phase.resting;
        _restRemaining = _restTime;
      });
      _startRestTimer();
    }
  }

  void _skipSet() {
    if (_isLastOfAll) {
      setState(() => _phase = _Phase.finished);
    } else {
      _advanceSet();
    }
  }

  void _startRestTimer() {
    _restTimer?.cancel();
    _restTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _restRemaining--);
      if (_restRemaining <= 0) {
        _restTimer?.cancel();
        _skipRest();
      }
    });
  }

  void _skipRest() {
    _restTimer?.cancel();
    _restTimer = null;
    setState(() => _phase = _Phase.ready);
    _advanceSet();
  }

  void _adjustRest(int delta) {
    setState(() {
      _restRemaining = (_restRemaining + delta).clamp(5, 300);
      _restTime = (_restTime + delta).clamp(5, 300);
    });
  }

  void _advanceSet() {
    setState(() {
      if (!_isLastSet) {
        _currentSetIdx++;
      } else {
        _currentExIdx++;
        _currentSetIdx = 0;
      }
    });
    _autoFillCurrentWeight();
  }

  void _autoFillCurrentWeight() {
    final ctrl = _controllers[_currentExIdx][_currentSetIdx];
    if (ctrl.text.isNotEmpty) return;
    if (_currentSetIdx > 0) {
      final prev = _controllers[_currentExIdx][_currentSetIdx - 1];
      if (prev.text.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => ctrl.text = prev.text);
        });
      }
    }
  }

  void _goBack() {
    if (!_canGoBack) return;
    if (_phase == _Phase.resting) {
      _restTimer?.cancel();
      _restTimer = null;
      setState(() => _phase = _Phase.ready);
      return;
    }
    setState(() {
      if (_currentSetIdx > 0) {
        _sets[_currentExIdx][_currentSetIdx - 1]['done'] = false;
        _currentSetIdx--;
      } else {
        _currentExIdx--;
        _currentSetIdx = ((_currentEx['pivot']['sets'] as num).toInt()) - 1;
        _sets[_currentExIdx][_currentSetIdx]['done'] = false;
      }
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('¿Abandonar sesión?'),
            content: const Text('No se guardará el progreso.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('CONTINUAR'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('SALIR', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
        if (leave == true && context.mounted) Navigator.pop(context, null);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: _phase == _Phase.finished
              ? _buildFinished()
              : Column(
                  children: [
                    _buildHeader(),
                    _buildProgressBar(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: _phase == _Phase.resting
                            ? _buildResting()
                            : _buildReady(),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.close, size: 18, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              widget.routine['name'].toString().toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('TIEMPO',
                    style: TextStyle(fontSize: 8, color: Colors.grey)),
                Text(
                  _formatTime(_elapsed),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Barra de progreso ────────────────────────────────────────────────────
  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('PROGRESO',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey)),
              Text(
                '$_exDoneCount / ${_exercises.length}',
                style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _progressPct,
              minHeight: 5,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          // Dots por ejercicio
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_exercises.length, (i) {
              final isCurrent = i == _currentExIdx && _phase != _Phase.finished;
              final isDone = _sets[i].every((s) => s['done'] == true);
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                height: 5,
                width: isCurrent ? 18 : 5,
                decoration: BoxDecoration(
                  color: isDone
                      ? AppColors.primary.withValues(alpha: 0.4)
                      : isCurrent
                          ? AppColors.primary
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Fase: ready ───────────────────────────────────────────────────────────
  Widget _buildReady() {
    final ex = _currentEx;
    final numSets = (ex['pivot']['sets'] as num).toInt();
    final reps = (ex['pivot']['reps'] as num).toInt();

    return Column(
      children: [
        // Card ejercicio
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            children: [
              // Info ejercicio
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EJERCICIO ${_currentExIdx + 1} DE ${_exercises.length}',
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ex['name'] ?? '',
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w900),
                    ),
                    if (ex['muscle_group'] != null)
                      Text(ex['muscle_group'],
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF5F5F5)),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  children: [
                    // Dots de series
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(numSets, (i) {
                        final isCurSet = i == _currentSetIdx;
                        final isDoneSet =
                            _sets[_currentExIdx][i]['done'] == true;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          height: 10,
                          width: isCurSet ? 28 : 10,
                          decoration: BoxDecoration(
                            color: isDoneSet || isCurSet
                                ? AppColors.primary
                                : Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'SERIE ${_currentSetIdx + 1} DE $numSets',
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    // Reps objetivo
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$reps',
                          style: const TextStyle(
                              fontSize: 64, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(width: 8),
                        const Text('reps',
                            style: TextStyle(
                                fontSize: 20, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Input de peso
                    Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        TextField(
                          controller: _controllers[_currentExIdx]
                              [_currentSetIdx],
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 36, fontWeight: FontWeight.w900),
                          decoration: InputDecoration(
                            hintText: '0',
                            hintStyle: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 48),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.surfaceContainerHighest, width: 2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                  color: AppColors.primary, width: 2),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(right: 16),
                          child: Text('kg',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text('peso utilizado (opcional)',
                        style: TextStyle(fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 20),
                    // Botón COMPLETAR SERIE
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _completeSet,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          elevation: 0,
                          shadowColor: AppColors.primary.withValues(alpha: 0.4),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check, size: 20),
                            SizedBox(width: 8),
                            Text('COMPLETAR SERIE',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w900)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Anterior / Saltar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: _canGoBack ? _goBack : null,
                          icon: const Icon(Icons.undo, size: 14),
                          label: const Text('Anterior'),
                          style: TextButton.styleFrom(
                            foregroundColor:
                                _canGoBack
                                ? Theme.of(context).colorScheme.onSurfaceVariant
                                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _skipSet,
                          icon: const Icon(Icons.skip_next, size: 14),
                          label: const Text('Saltar'),
                          style: TextButton.styleFrom(
                              foregroundColor: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Ejercicios completados
        if (_exDoneCount > 0) ...[
          const SizedBox(height: 16),
          _buildDoneList(),
        ],
      ],
    );
  }

  // ── Fase: resting ─────────────────────────────────────────────────────────
  Widget _buildResting() {
    final restPct =
        (_restTime - _restRemaining) / _restTime.clamp(1, _restTime);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          // Badge completado
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check, size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  'Serie $_completedSetNum completada',
                  style: const TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('DESCANSANDO',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 2)),
          const SizedBox(height: 8),
          Text(
            _formatTime(_restRemaining),
            style: const TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.w900,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: restPct.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          // Ajustar descanso
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildRestAdjustBtn('-15s', () => _adjustRest(-15)),
              const SizedBox(width: 12),
              const Text('ajustar descanso',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(width: 12),
              _buildRestAdjustBtn('+15s', () => _adjustRest(15)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _skipRest,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_nextActionLabel,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w900)),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestAdjustBtn(String label, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        side: const BorderSide(color: Colors.grey),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }

  // ── Fase: finished ────────────────────────────────────────────────────────
  Widget _buildFinished() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.flag, size: 48, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          const Text('¡ENTRENAMIENTO COMPLETADO!',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  letterSpacing: 1)),
          const SizedBox(height: 8),
          Text(
            widget.routine['name'].toString(),
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            '${_exercises.length} ejercicios  ·  ${_formatTime(_elapsed)}',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 28),
          // Resumen
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10)
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('RESUMEN',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey)),
                const SizedBox(height: 12),
                ...List.generate(_exercises.length, (i) {
                  final ex = _exercises[i];
                  final maxW = _exMaxWeight(i);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.check,
                              size: 12, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(ex['name'] ?? '',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        if (maxW != null)
                          Text(
                            '${maxW.toStringAsFixed(1)} kg',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary),
                          ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, _collectSetData()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save_outlined, size: 20),
                  SizedBox(width: 8),
                  Text('GUARDAR ENTRENAMIENTO',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Descartar y salir',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // ── Lista de completados ──────────────────────────────────────────────────
  Widget _buildDoneList() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('YA COMPLETADOS',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)),
          const SizedBox(height: 10),
          ...List.generate(_exercises.length, (i) {
            if (!_sets[i].every((s) => s['done'] == true)) {
              return const SizedBox();
            }
            final maxW = _exMaxWeight(i);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Icon(Icons.check,
                        size: 10, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(_exercises[i]['name'] ?? '',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                  if (maxW != null)
                    Text(
                      '${maxW.toStringAsFixed(1)} kg máx',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
