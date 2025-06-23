import 'package:workout_tracker_repo/data/errors/custom_error_exception.dart';
import 'package:workout_tracker_repo/data/services/measurement_service.dart';
import 'package:workout_tracker_repo/domain/entities/measurement.dart';
import '../models/measurement_model.dart';
import '../../domain/repositories/measurement_repository.dart';

class MeasurementRepositoryImpl implements MeasurementRepository {
  final MeasurementService _service;

  MeasurementRepositoryImpl(this._service);

  @override
  Future<void> addMeasurement(Measurement measurement) async {
    try {
      final model = MeasurementModel(
        id: '',
        userId: measurement.userId,
        height: measurement.height,
        weight: measurement.weight,
        date: measurement.date,
        imageUrl: measurement.imageUrl,
      );
      await _service.add(model.toMap());
    } on CustomErrorException catch (_) {
      throw CustomErrorException.fromCode(400);
    } catch (e) {
      throw CustomErrorException.fromCode(500);
    }
  }

  @override
  Stream<List<Measurement>> fetchMeasurements(String userId) {
    try {
      return _service.getByUserId(userId).map((snapshot) {
        final list =
            snapshot.docs
                .map((doc) => MeasurementModel.fromMap(doc.data(), doc.id))
                .toList()
              ..sort((b, a) => b.date.compareTo(a.date));
        return list.toList();
      });
    } on CustomErrorException catch (_) {
      throw CustomErrorException.fromCode(400);
    } catch (e) {
      throw CustomErrorException.fromCode(500);
    }
  }
}
