import 'package:flutter_test/flutter_test.dart';
import 'package:adventure_logger/core/services/sensor_service.dart';

void main() {
  group('SensorService.classify', () {
    test('negative lux is dark', () {
      expect(SensorService.classify(-1), LightCondition.dark);
    });

    test('brightness buckets', () {
      expect(SensorService.classify(1500), LightCondition.bright);
      expect(SensorService.classify(500), LightCondition.moderate);
      expect(SensorService.classify(50), LightCondition.dim);
      expect(SensorService.classify(10), LightCondition.dark);
    });
  });
}
