import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class _GuideSection {
  final IconData icon;
  final Color accent;
  final String title;
  final List<String> lines;
  const _GuideSection(this.icon, this.accent, this.title, this.lines);
}

const _sections = <_GuideSection>[
  _GuideSection(Icons.calculate, Color(0xFF4FC3F7), 'Hesap Makinesi', [
    'SHIFT tuşu, tuşların üzerinde sarı ile yazan ikinci işlevi etkinleştirir (ör. sin → sin⁻¹).',
    'DEG/RAD tuşu ile açı modunu değiştir; ekranın üstündeki Rad/Deg göstergesini takip et.',
    'MC, MR, M+, M- tuşları hafıza işlemleri içindir; hafıza doluyken ekranda M görünür.',
    'nPr / nCr ile permütasyon ve kombinasyon, x! ile faktöriyel hesaplanır.',
    '⌫ son basamağı siler, AC tüm işlemi temizler.',
  ]),
  _GuideSection(Icons.auto_awesome, Color(0xFF9C6FD6), 'Astronomi', [
    'Üstteki menüden bir formül seç: Kepler 3. Yasası, Kaçış Hızı, Newton Çekim Kuvveti, Schwarzschild Yarıçapı, Hubble Yasası.',
    'Alanları doldur ve HESAPLA’ya bas; sonuçlar kart içinde listelenir.',
    '“Formül Hakkında” bölümünü açarak formülün açıklamasını ve kaynakları görebilirsin.',
  ]),
  _GuideSection(Icons.electrical_services, Color(0xFF66BB6A), 'Elektronik', [
    'Ohm Kanunu, Elektrik Gücü, RC Devresi, LC Rezonansı ve Gerilim Bölücü hesaplayabilirsin.',
    'Bazı modüllerde hangi büyüklüğü çözeceğini (ör. V, I, R) seçebilirsin.',
    'Akım gibi değerler mA cinsinden girilir; sonuç kartı birimleri gösterir.',
  ]),
  _GuideSection(Icons.swap_horiz, Color(0xFF4DB6AC), 'Birim Dönüştürücü', [
    'Üstteki şeritten kategori seç: Uzunluk, Kütle, Zaman, Alan, Hacim, Hız, Sıcaklık, Enerji, Veri, Açı.',
    'Değeri yaz; dönüşüm anında hesaplanır.',
    'Ortadaki ⇅ düğmesi kaynak ve hedef birimi yer değiştirir.',
  ]),
  _GuideSection(Icons.settings, Color(0xFF4FC3F7), 'Ayarlar', [
    'Görünüm bölümünden Sistem, Açık veya Koyu temayı seçebilirsin.',
    '“Uygulamayı Değerlendir” ile Google Play üzerinden puan verebilirsin.',
  ]),
];

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.scaffoldBg,
      appBar: AppBar(
        title: const Text('Kullanım Rehberi',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Text(
            'SciCalc Pro’yu en verimli şekilde kullanmak için kısa rehber.',
            style: TextStyle(color: colors.label, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 16),
          ..._sections.map((s) => _SectionCard(section: s)),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final _GuideSection section;
  const _SectionCard({required this.section});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.card,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(section.icon, size: 20, color: section.accent),
              const SizedBox(width: 10),
              Text(section.title,
                  style: TextStyle(
                      color: colors.primaryText,
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          ...section.lines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6, right: 8),
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: section.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(line,
                        style: TextStyle(
                            color: colors.label, fontSize: 13, height: 1.5)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
