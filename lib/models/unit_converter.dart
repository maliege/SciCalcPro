// Unit converter — categories, units and conversion logic.
//
// Pure Dart (no Flutter dependency) so it stays easy to unit-test.
// Linear categories convert through an SI base value:
//   baseValue = value * fromFactor;  result = baseValue / toFactor.
// Temperature is non-linear and handled separately via Celsius as the base.

class UnitOption {
  final String id; // short symbol, e.g. 'km'
  final String name; // localized display name, e.g. 'Kilometre'
  final double factor; // multiplier to the category's SI base unit
  const UnitOption(this.id, this.name, this.factor);
}

class UnitCategory {
  final String id;
  final String name; // localized category name
  final List<UnitOption> units;
  final bool isTemperature;
  const UnitCategory({
    required this.id,
    required this.name,
    required this.units,
    this.isTemperature = false,
  });
}

class UnitConverter {
  const UnitConverter._();

  /// Converts [value] from [from] to [to] within [category].
  static double convert({
    required double value,
    required UnitOption from,
    required UnitOption to,
    required UnitCategory category,
  }) {
    if (category.isTemperature) {
      return _convertTemperature(value, from.id, to.id);
    }
    return value * from.factor / to.factor;
  }

  /// Temperature conversion through Celsius as the base unit.
  static double _convertTemperature(double value, String from, String to) {
    // Step 1: any unit -> Celsius
    double c;
    switch (from) {
      case 'C':
        c = value;
        break;
      case 'F':
        c = (value - 32) * 5 / 9;
        break;
      case 'K':
        c = value - 273.15;
        break;
      default:
        throw ArgumentError('Unknown temperature unit: $from');
    }
    // Step 2: Celsius -> target unit
    switch (to) {
      case 'C':
        return c;
      case 'F':
        return c * 9 / 5 + 32;
      case 'K':
        return c + 273.15;
      default:
        throw ArgumentError('Unknown temperature unit: $to');
    }
  }

  /// All available categories, in display order.
  static const List<UnitCategory> categories = [
    UnitCategory(id: 'length', name: 'Uzunluk', units: [
      UnitOption('mm', 'Milimetre', 1e-3),
      UnitOption('cm', 'Santimetre', 1e-2),
      UnitOption('m', 'Metre', 1),
      UnitOption('km', 'Kilometre', 1e3),
      UnitOption('in', 'İnç', 0.0254),
      UnitOption('ft', 'Fit', 0.3048),
      UnitOption('yd', 'Yarda', 0.9144),
      UnitOption('mi', 'Mil', 1609.344),
      UnitOption('nmi', 'Deniz mili', 1852),
      UnitOption('AU', 'Astronomik birim', 1.495978707e11),
      UnitOption('ly', 'Işık yılı', 9.4607304725808e15),
      UnitOption('pc', 'Parsek', 3.085677581e16),
    ]),
    UnitCategory(id: 'mass', name: 'Kütle', units: [
      UnitOption('mg', 'Miligram', 1e-6),
      UnitOption('g', 'Gram', 1e-3),
      UnitOption('kg', 'Kilogram', 1),
      UnitOption('t', 'Ton', 1e3),
      UnitOption('oz', 'Ons', 0.028349523125),
      UnitOption('lb', 'Libre', 0.45359237),
    ]),
    UnitCategory(id: 'time', name: 'Zaman', units: [
      UnitOption('ms', 'Milisaniye', 1e-3),
      UnitOption('s', 'Saniye', 1),
      UnitOption('min', 'Dakika', 60),
      UnitOption('h', 'Saat', 3600),
      UnitOption('day', 'Gün', 86400),
      UnitOption('week', 'Hafta', 604800),
    ]),
    UnitCategory(id: 'area', name: 'Alan', units: [
      UnitOption('mm2', 'Milimetrekare', 1e-6),
      UnitOption('cm2', 'Santimetrekare', 1e-4),
      UnitOption('m2', 'Metrekare', 1),
      UnitOption('km2', 'Kilometrekare', 1e6),
      UnitOption('ha', 'Hektar', 1e4),
      UnitOption('donum', 'Dönüm', 1000),
      UnitOption('ac', 'Akre', 4046.8564224),
      UnitOption('ft2', 'Fitkare', 0.09290304),
    ]),
    UnitCategory(id: 'volume', name: 'Hacim', units: [
      UnitOption('ml', 'Mililitre', 1e-6),
      UnitOption('cl', 'Santilitre', 1e-5),
      UnitOption('l', 'Litre', 1e-3),
      UnitOption('m3', 'Metreküp', 1),
      UnitOption('gal', 'Galon (ABD)', 3.785411784e-3),
      UnitOption('ft3', 'Fitküp', 0.028316846592),
    ]),
    UnitCategory(id: 'speed', name: 'Hız', units: [
      UnitOption('mps', 'Metre/saniye', 1),
      UnitOption('kmh', 'Kilometre/saat', 0.2777777777777778),
      UnitOption('mph', 'Mil/saat', 0.44704),
      UnitOption('kn', 'Knot', 0.5144444444444445),
      UnitOption('fps', 'Fit/saniye', 0.3048),
    ]),
    UnitCategory(
      id: 'temperature',
      name: 'Sıcaklık',
      isTemperature: true,
      units: [
        UnitOption('C', 'Santigrat (°C)', 1),
        UnitOption('F', 'Fahrenheit (°F)', 1),
        UnitOption('K', 'Kelvin (K)', 1),
      ],
    ),
    UnitCategory(id: 'energy', name: 'Enerji', units: [
      UnitOption('J', 'Joule', 1),
      UnitOption('kJ', 'Kilojoule', 1e3),
      UnitOption('cal', 'Kalori', 4.184),
      UnitOption('kcal', 'Kilokalori', 4184),
      UnitOption('Wh', 'Watt-saat', 3600),
      UnitOption('kWh', 'Kilowatt-saat', 3.6e6),
      UnitOption('eV', 'Elektronvolt', 1.602176634e-19),
    ]),
    UnitCategory(id: 'data', name: 'Veri', units: [
      UnitOption('bit', 'Bit', 0.125),
      UnitOption('B', 'Byte', 1),
      UnitOption('KB', 'Kilobyte', 1024),
      UnitOption('MB', 'Megabyte', 1048576),
      UnitOption('GB', 'Gigabyte', 1073741824),
      UnitOption('TB', 'Terabyte', 1099511627776),
    ]),
    UnitCategory(id: 'angle', name: 'Açı', units: [
      UnitOption('rad', 'Radyan', 1),
      UnitOption('deg', 'Derece', 0.017453292519943295),
      UnitOption('grad', 'Grad', 0.015707963267948967),
      UnitOption('arcmin', 'Yay dakikası', 0.0002908882086657216),
      UnitOption('arcsec', 'Yay saniyesi', 4.84813681109536e-6),
      UnitOption('turn', 'Tam tur', 6.283185307179586),
    ]),
  ];
}
