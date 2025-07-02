// volume_set_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../presentation/domain/entities/set_entry.dart';

class VolumeSetState {
  final double totalVolume;
  final int totalSets;
  final Map<String, double> exerciseVolumes; // Exercise ID to volume

  const VolumeSetState({
    this.totalVolume = 0,
    this.totalSets = 0,
    this.exerciseVolumes = const {},
  });

  VolumeSetState copyWith({
    double? totalVolume,
    int? totalSets,
    Map<String, double>? exerciseVolumes,
  }) {
    return VolumeSetState(
      totalVolume: totalVolume ?? this.totalVolume,
      totalSets: totalSets ?? this.totalSets,
      exerciseVolumes: exerciseVolumes ?? this.exerciseVolumes,
    );
  }
}

class VolumeSetNotifier extends StateNotifier<VolumeSetState> {
  VolumeSetNotifier() : super(const VolumeSetState());

  void updateVolume(String exerciseId, List<SetEntry> sets) {
    final exerciseVolume = sets.fold(
      0.0,
      (sum, set) => sum + (set.kg * set.reps),
    );

    final newExerciseVolumes = Map<String, double>.from(state.exerciseVolumes)
      ..[exerciseId] = exerciseVolume;

    state = state.copyWith(
      exerciseVolumes: newExerciseVolumes,
      totalVolume: newExerciseVolumes.values.fold(
        0.0,
        (sum, volume) => sum! + volume,
      ),
      totalSets: newExerciseVolumes.values.fold(
        0,
        (sum, _) => sum! + sets.length,
      ),
    );
  }

  void reset() {
    state = const VolumeSetState();
  }
}

final volumeSetProvider =
    StateNotifierProvider<VolumeSetNotifier, VolumeSetState>(
      (ref) => VolumeSetNotifier(),
    );
