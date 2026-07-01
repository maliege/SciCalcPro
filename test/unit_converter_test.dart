import 'package:flutter_test/flutter_test.dart';
import 'package:sci_calc_pro/models/unit_converter.dart';

UnitCategory _cat(String id) =>
    UnitConverter.categories.firstWhere((c) => c.id == id);

UnitOption _unit(UnitCategory c, String id) =>
    c.units.firstWhere((u) => u.id == id);

double _convert(String catId, String from, String to, double value) {
  final c = _cat(catId);
  return UnitConverter.convert(
    value: value,
    from: _unit(c, from),
    to: _unit(c, to),
    category: c,
  );
}

void main() {
  group('UnitConverter — linear categories', () {
    test('length: 1 km = 1000 m', () {
      expect(_convert('length', 'km', 'm', 1), closeTo(1000, 1e-9));
    });

    test('length: 1 inch = 2.54 cm', () {
      expect(_convert('length', 'in', 'cm', 1), closeTo(2.54, 1e-9));
    });

    test('mass: 1 kg = 1000 g', () {
      expect(_convert('mass', 'kg', 'g', 1), closeTo(1000, 1e-9));
    });

    test('time: 1 h = 3600 s', () {
      expect(_convert('time', 'h', 's', 1), closeTo(3600, 1e-9));
    });

    test('area: 1 hectare = 10000 m2', () {
      expect(_convert('area', 'ha', 'm2', 1), closeTo(10000, 1e-6));
    });

    test('volume: 1 litre = 1000 ml', () {
      expect(_convert('volume', 'l', 'ml', 1), closeTo(1000, 1e-6));
    });

    test('speed: 36 km/h = 10 m/s', () {
      expect(_convert('speed', 'kmh', 'mps', 36), closeTo(10, 1e-9));
    });

    test('data: 1 KB = 1024 B', () {
      expect(_convert('data', 'KB', 'B', 1), closeTo(1024, 1e-9));
    });

    test('same unit conversion is identity', () {
      expect(_convert('length', 'm', 'm', 42.5), closeTo(42.5, 1e-12));
    });
  });

  group('UnitConverter — temperature', () {
    test('0 °C = 32 °F', () {
      expect(_convert('temperature', 'C', 'F', 0), closeTo(32, 1e-9));
    });

    test('100 °C = 212 °F', () {
      expect(_convert('temperature', 'C', 'F', 100), closeTo(212, 1e-9));
    });

    test('0 °C = 273.15 K', () {
      expect(_convert('temperature', 'C', 'K', 0), closeTo(273.15, 1e-9));
    });

    test('32 °F = 0 °C', () {
      expect(_convert('temperature', 'F', 'C', 32), closeTo(0, 1e-9));
    });

    test('300 K = 26.85 °C', () {
      expect(_convert('temperature', 'K', 'C', 300), closeTo(26.85, 1e-9));
    });
  });

  test('all categories expose at least two units', () {
    for (final c in UnitConverter.categories) {
      expect(c.units.length, greaterThanOrEqualTo(2), reason: c.id);
    }
  });
}
