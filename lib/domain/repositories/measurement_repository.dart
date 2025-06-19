import '../entities/measurement.dart';

abstract class MeasurementRepository {
  Future<void> addMeasurement(Measurement measurement);
  Stream<void> fetchMeasurements(String userId);
}
