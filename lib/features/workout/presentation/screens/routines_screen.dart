import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/workout_controller.dart';
import 'create_routine_screen.dart';
import 'training_session_screen.dart';

class RoutinesScreen extends StatefulWidget {
  const RoutinesScreen({super.key});

  @override
  State<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final workout = context.read<WorkoutController>();
      workout.loadRoutines();
      workout.loadWorkoutHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final workout = context.watch<WorkoutController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('RUTINAS'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'MIS PLANES', icon: Icon(Icons.fitness_center)),
            Tab(text: 'HISTORIAL', icon: Icon(Icons.history)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateRoutineScreen()),
        ),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Pestaña 1: Mis Rutinas
          workout.isLoading
              ? const Center(child: CircularProgressIndicator())
              : workout.routines.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: workout.routines.length,
                      itemBuilder: (context, index) {
                        final routine = workout.routines[index];
                        return _buildRoutineCard(routine, workout);
                      },
                    ),

          // Pestaña 2: Historial / Línea de tiempo
          Column(
            children: [
              _buildHorizontalCalendar(),
              const Divider(height: 1),
              Expanded(
                child: workout.workoutLogs.isEmpty
                    ? _buildEmptyHistory()
                    : _buildTimeline(workout.workoutLogs),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalCalendar() {
    // Generar los 7 días de la semana actual
    final now = DateTime.now();
    final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
    
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          final day = firstDayOfWeek.add(Duration(days: index));
          final isSelected = day.day == _selectedDate.day && day.month == _selectedDate.month;
          final isToday = day.day == now.day && day.month == now.month;

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = day),
            child: Container(
              width: 55,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: isToday && !isSelected ? Border.all(color: AppColors.primary, width: 1) : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E', 'es_ES').format(day).substring(0, 3).toLowerCase(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    day.day.toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textTitle,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fitness_center_outlined, size: 80, color: Colors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text('No hay rutinas creadas', style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold)),
          const Text('Empieza creando tu primer plan de entrenamiento'),
        ],
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_month_outlined, size: 80, color: Colors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text('Historial vacío', style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold)),
          const Text('Tus entrenamientos completados aparecerán aquí'),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.read<WorkoutController>().loadWorkoutHistory(),
            child: const Text('REINTENTAR CARGAR'),
          )
        ],
      ),
    );
  }

  Widget _buildTimeline(List<dynamic> logs) {
    // Filtrar logs por la fecha seleccionada
    final filteredLogs = logs.where((log) {
      final logDate = DateTime.parse(log['completed_at']).toLocal();
      return logDate.day == _selectedDate.day && 
             logDate.month == _selectedDate.month && 
             logDate.year == _selectedDate.year;
    }).toList();

    if (filteredLogs.isEmpty) {
      return const Center(child: Text('No entrenaste este día', style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: filteredLogs.length,
      itemBuilder: (context, index) {
        final log = filteredLogs[index];
        final DateTime date = DateTime.parse(log['completed_at']).toLocal();
        final String formattedDate = DateFormat('EEEE, d MMMM', 'es_ES').format(date);
        final String formattedTime = DateFormat('jm', 'es_ES').format(date);
        
        return IntrinsicHeight(
          child: Row(
            children: [
              Column(
                children: [
                  Container(width: 12, height: 12, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                  if (index != filteredLogs.length - 1)
                    Expanded(child: Container(width: 2, color: AppColors.primary.withValues(alpha: 0.3))),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(formattedDate.toUpperCase(), style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(log['routine']?['name'] ?? 'Rutina eliminada', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(formattedTime, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoutineCard(dynamic routine, WorkoutController workout) {
    final isDoneToday = workout.workoutLogs.any((log) {
      if (log['routine_id'] != routine['id']) return false;
      final logDate = DateTime.parse(log['completed_at']).toLocal();
      final now = DateTime.now();
      return logDate.year == now.year && logDate.month == now.month && logDate.day == now.day;
    });

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                routine['name'],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            if (isDoneToday)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text('¡HECHA!', style: TextStyle(color: AppColors.textTitle, fontWeight: FontWeight.bold, fontSize: 10)),
              ),
            IconButton(
              icon: const Icon(Icons.edit_note_outlined, color: AppColors.primary),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateRoutineScreen(routine: routine)),
              ),
            ),
          ],
        ),
        subtitle: Text('${routine['exercises']?.length ?? 0} EJERCICIOS'),
        leading: CircleAvatar(
          backgroundColor: isDoneToday ? AppColors.primary : Colors.grey.shade200,
          child: Icon(isDoneToday ? Icons.check : Icons.flash_on, color: isDoneToday ? Colors.white : Colors.grey),
        ),
        children: [
          ...?routine['exercises']?.map<Widget>((ex) => ListTile(
                title: Text(ex['name'] ?? 'S/N'),
                subtitle: Text('${ex['pivot']['sets']} series x ${ex['pivot']['reps'] ?? 0} reps'),
                trailing: const Icon(Icons.check_circle_outline),
              )),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: isDoneToday ? null : () => _startTraining(routine),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDoneToday ? Colors.grey.shade100 : AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(isDoneToday ? 'YA ENTRENADO HOY' : '¡A ENTRENAR!'),
            ),
          )
        ],
      ),
    );
  }

  void _startTraining(dynamic routine) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TrainingSessionScreen(routine: routine)),
    );

    if (result is List && mounted) {
      await context.read<WorkoutController>().completeRoutine(
            routine['id'],
            List<Map<String, dynamic>>.from(result),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Entrenamiento guardado con éxito!')),
        );
      }
    }
  }
}
