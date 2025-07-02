// lib/presentation/providers/persistent_duration_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimerState {
  final bool isTimerSelected;
  final Duration timerDuration;
  final Duration stopwatchDuration;
  final bool isRunning;

  const TimerState({
    this.isTimerSelected = true,
    this.timerDuration = const Duration(minutes: 1),
    this.stopwatchDuration = Duration.zero,
    this.isRunning = false,
  });

  TimerState copyWith({
    bool? isTimerSelected,
    Duration? timerDuration,
    Duration? stopwatchDuration,
    bool? isRunning,
  }) {
    return TimerState(
      isTimerSelected: isTimerSelected ?? this.isTimerSelected,
      timerDuration: timerDuration ?? this.timerDuration,
      stopwatchDuration: stopwatchDuration ?? this.stopwatchDuration,
      isRunning: isRunning ?? this.isRunning,
    );
  }
}

class PersistentTimerNotifier extends StateNotifier<TimerState> {
  PersistentTimerNotifier() : super(const TimerState()) {
    _loadTimerState();
  }

  Future<void> _loadTimerState() async {
    final prefs = await SharedPreferences.getInstance();

    final isTimerSelected = prefs.getBool('timer_is_timer_selected') ?? true;
    final timerMinutes = prefs.getInt('timer_duration_minutes') ?? 1;
    final stopwatchSeconds = prefs.getInt('stopwatch_duration_seconds') ?? 0;

    state = TimerState(
      isTimerSelected: isTimerSelected,
      timerDuration: Duration(minutes: timerMinutes),
      stopwatchDuration: Duration(seconds: stopwatchSeconds),
      isRunning: false, // Never restore running state
    );
  }

  Future<void> _saveTimerState() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('timer_is_timer_selected', state.isTimerSelected);
    await prefs.setInt('timer_duration_minutes', state.timerDuration.inMinutes);
    await prefs.setInt(
      'stopwatch_duration_seconds',
      state.stopwatchDuration.inSeconds,
    );
  }

  Future<void> setTimerSelected(bool isTimer) async {
    state = state.copyWith(
      isTimerSelected: isTimer,
      isRunning: false, // Stop when switching modes
    );
    await _saveTimerState();
  }

  Future<void> setTimerDuration(Duration duration) async {
    state = state.copyWith(timerDuration: duration);
    await _saveTimerState();
  }

  Future<void> addTimerSeconds(int seconds) async {
    final newDuration = Duration(
      seconds: state.timerDuration.inSeconds + seconds,
    );
    if (!newDuration.isNegative) {
      await setTimerDuration(newDuration);
    }
  }

  Future<void> setStopwatchDuration(Duration duration) async {
    state = state.copyWith(stopwatchDuration: duration);
    await _saveTimerState();
  }

  Future<void> addStopwatchSecond() async {
    final newDuration = Duration(
      seconds: state.stopwatchDuration.inSeconds + 1,
    );
    await setStopwatchDuration(newDuration);
  }

  void setRunning(bool isRunning) {
    state = state.copyWith(isRunning: isRunning);
    // Don't save running state - it should always start as false
  }

  Future<void> resetTimer() async {
    if (state.isTimerSelected) {
      await setTimerDuration(const Duration(minutes: 1));
    } else {
      await setStopwatchDuration(Duration.zero);
    }
    setRunning(false);
  }

  Future<void> resetAll() async {
    state = const TimerState();
    await _saveTimerState();
  }
}

final timerProvider =
    StateNotifierProvider<PersistentTimerNotifier, TimerState>((ref) {
      return PersistentTimerNotifier();
    });

// Separate provider for workout elapsed duration (this one doesn't need persistence)
final workoutElapsedDurationProvider = StateProvider<Duration>(
  (ref) => Duration.zero,
);

final workoutTimerActiveProvider = StateProvider<bool>((ref) => false);
