import 'dart:math' as math;

const _g      = 6.674e-11; // m³ kg⁻¹ s⁻²
const _c      = 2.998e8;   // m/s
const _au     = 1.496e11;  // m
const _mEarth = 5.972e24;  // kg  (Dünya kütlesi = 1 M⊕)

// ── Kepler 3. Yasa ────────────────────────────────────────────────────────────

class KeplerResult {
  final double years, days, seconds;
  KeplerResult({required this.years, required this.days, required this.seconds});
}

KeplerResult calcKeplerPeriod({
  required double aMajorAU,
  required double centralMassEarth,
}) {
  final a = aMajorAU * _au;
  final m = centralMassEarth * _mEarth;
  final T = 2 * math.pi * math.sqrt(math.pow(a, 3).toDouble() / (_g * m));
  return KeplerResult(seconds: T, days: T / 86400.0, years: T / (365.25 * 86400.0));
}

// ── Kaçış Hızı ───────────────────────────────────────────────────────────────

class EscapeVelResult {
  final double ms, kms;
  EscapeVelResult({required this.ms, required this.kms});
}

EscapeVelResult calcEscapeVelocity({
  required double massKg,
  required double radiusM,
}) {
  if (radiusM <= 0 || massKg <= 0) return EscapeVelResult(ms: 0, kms: 0);
  final ve = math.sqrt(2 * _g * massKg / radiusM);
  return EscapeVelResult(ms: ve, kms: ve / 1000.0);
}

// ── Newton Çekim Kuvveti ──────────────────────────────────────────────────────

double calcGravForce({
  required double m1Kg,
  required double m2Kg,
  required double distM,
}) {
  if (distM <= 0) return 0;
  return _g * m1Kg * m2Kg / (distM * distM);
}

// ── Schwarzschild Yarıçapı ────────────────────────────────────────────────────

class SchwarzschildResult {
  final double meters, km;
  SchwarzschildResult({required this.meters, required this.km});
}

SchwarzschildResult calcSchwarzschildRadius({required double massKg}) {
  final rs = 2.0 * _g * massKg / (_c * _c);
  return SchwarzschildResult(meters: rs, km: rs / 1000.0);
}

// ── Hubble Yasası ─────────────────────────────────────────────────────────────

class HubbleResult {
  final double kms;        // km/s
  final double redshiftZ;  // yaklaşık z = v/c
  HubbleResult({required this.kms, required this.redshiftZ});
}

HubbleResult calcHubble({
  required double distanceMpc,
  required double h0KmsMpc,
}) {
  final v = h0KmsMpc * distanceMpc;
  final z = (v * 1000.0) / _c;
  return HubbleResult(kms: v, redshiftZ: z);
}

// ── Yıldız Parlaklığı (Ters Kare Yasası) ─────────────────────────────────────

class LuminosityResult {
  final double flux;            // W/m²
  final double apparentMag;     // mag farkı (Δm) referansa göre
  LuminosityResult({required this.flux, required this.apparentMag});
}

/// [luminosityW] W cinsinden ışıklılık (Güneş = 3.828e26 W)
/// [distanceLy]  ışık yılı cinsinden mesafe
LuminosityResult calcLuminosity({
  required double luminosityW,
  required double distanceLy,
}) {
  const lyToM = 9.461e15;
  final d = distanceLy * lyToM;
  final flux = d > 0 ? luminosityW / (4 * math.pi * d * d) : 0.0;
  // Δm = -2.5 × log10(flux / flux_sun_at_10pc)
  // flux_sun_at_10pc = L_sun / (4π × (10×3.086e16)²) ≈ 1.359 W/m² reference skipped
  // Just return flux; magnitude difference shown if reference provided
  return LuminosityResult(flux: flux, apparentMag: 0);
}
