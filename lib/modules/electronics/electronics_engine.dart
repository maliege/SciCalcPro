import 'dart:math' as math;

// ── RC Devresi ────────────────────────────────────────────────────────────────

class RcResult {
  final double tau;          // s
  final double vCharge;      // V  (t anında şarj gerilimi)
  final double vDischarge;   // V  (t anında deşarj gerilimi)
  final double charge;       // C  (tam şarjdaki yük Q = C×V₀)
  final double energy;       // J  (tam şarjdaki enerji E = ½CV₀²)

  RcResult({
    required this.tau,
    required this.vCharge,
    required this.vDischarge,
    required this.charge,
    required this.energy,
  });
}

/// [resistanceOhm] Ω · [capacitanceF] F · [v0] V · [tSec] s
RcResult calcRC({
  required double resistanceOhm,
  required double capacitanceF,
  required double v0,
  required double tSec,
}) {
  final tau        = resistanceOhm * capacitanceF;
  final vCharge    = v0 * (1 - math.exp(-tSec / tau));
  final vDischarge = v0 * math.exp(-tSec / tau);
  final charge     = capacitanceF * v0;
  final energy     = 0.5 * capacitanceF * v0 * v0;
  return RcResult(
      tau: tau,
      vCharge: vCharge,
      vDischarge: vDischarge,
      charge: charge,
      energy: energy);
}

// ── LC Rezonans ───────────────────────────────────────────────────────────────

class LcResult {
  final double freqHz;       // Hz
  final double periodS;      // s
  final double omega;        // rad/s
  final double impedance;    // Ω  (karakteristik empedans √(L/C))

  LcResult({
    required this.freqHz,
    required this.periodS,
    required this.omega,
    required this.impedance,
  });
}

/// [inductanceH] H · [capacitanceF] F
LcResult calcLCResonance({
  required double inductanceH,
  required double capacitanceF,
}) {
  if (inductanceH <= 0 || capacitanceF <= 0) {
    return LcResult(freqHz: 0, periodS: 0, omega: 0, impedance: 0);
  }
  final omega = 1.0 / math.sqrt(inductanceH * capacitanceF);
  final f     = omega / (2 * math.pi);
  final t     = 1.0 / f;
  final z     = math.sqrt(inductanceH / capacitanceF);
  return LcResult(freqHz: f, periodS: t, omega: omega, impedance: z);
}

// ── Gerilim Bölücü ────────────────────────────────────────────────────────────

class VDividerResult {
  final double vout;     // V
  final double vDrop1;   // V  (R₁ üzerindeki gerilim düşümü)
  final double current;  // A
  final double power;    // W  (toplam güç)

  VDividerResult({
    required this.vout,
    required this.vDrop1,
    required this.current,
    required this.power,
  });
}

VDividerResult calcVoltageDivider({
  required double vin,
  required double r1,
  required double r2,
}) {
  final rTotal = r1 + r2;
  if (rTotal <= 0) return VDividerResult(vout: 0, vDrop1: 0, current: 0, power: 0);
  final i      = vin / rTotal;
  final vout   = vin * r2 / rTotal;
  final vDrop1 = vin * r1 / rTotal;
  final p      = vin * i;
  return VDividerResult(vout: vout, vDrop1: vDrop1, current: i, power: p);
}
