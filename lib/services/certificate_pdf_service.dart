import 'dart:math' as math;
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/certificate_model.dart';

class CertificatePdfService {
  static PdfColor _getThemePdfColor(CertificateTheme theme) {
    switch (theme) {
      case CertificateTheme.bronze:
        return PdfColor.fromInt(0xFFB45309); // Rich Burnished Bronze
      case CertificateTheme.silver:
        return PdfColor.fromInt(0xFF475569); // Regal Sterling Slate
      case CertificateTheme.gold:
        return PdfColor.fromInt(0xFFD97706); // Classic Imperial Gold
      case CertificateTheme.platinum:
        return PdfColor.fromInt(0xFF0D9488); // Deep Platinum Teal
      case CertificateTheme.diamond:
        return PdfColor.fromInt(0xFF4338CA); // Royal Sapphire Indigo
      case CertificateTheme.celestial:
        return PdfColor.fromInt(0xFF7E22CE); // Sovereign Royal Amethyst
    }
  }

  static String _getThemeHex(CertificateTheme theme) {
    switch (theme) {
      case CertificateTheme.bronze:
        return '#B45309';
      case CertificateTheme.silver:
        return '#475569';
      case CertificateTheme.gold:
        return '#D97706';
      case CertificateTheme.platinum:
        return '#0D9488';
      case CertificateTheme.diamond:
        return '#4338CA';
      case CertificateTheme.celestial:
        return '#7E22CE';
    }
  }

  static String _getGoldFoilHex(int level) {
    if (level >= 5) return '#D97706'; // Sovereign 24K Gold
    if (level >= 4) return '#EAB308'; // Grandmaster Bright Gold
    if (level >= 3) return '#F59E0B'; // High Performance Gold
    if (level >= 2) return '#94A3B8'; // Vanguard Silver / Gold
    return '#CD7F32'; // Foundational Bronze Gold
  }

  // ══════════════════════════════════════════════════════════════════════════
  // VECTOR ORNAMENTS: Master Architectural Frame with Guilloché & Filigree
  // ══════════════════════════════════════════════════════════════════════════
  static String _buildMasterFrameSvg({
    required String primaryHex,
    required String goldHex,
    required int level,
  }) {
    // Diamond lattice chain border (top and bottom)
    final topDiamonds = StringBuffer();
    final bottomDiamonds = StringBuffer();
    for (double x = 70; x <= 740; x += 12) {
      final xStr = x.toStringAsFixed(1);
      final xMid = (x + 6).toStringAsFixed(1);
      final xEnd = (x + 12).toStringAsFixed(1);
      topDiamonds.write('<polygon points="$xStr,16 $xMid,13 $xEnd,16 $xMid,19" fill="$goldHex" opacity="0.85"/>');
      bottomDiamonds.write('<polygon points="$xStr,551 $xMid,548 $xEnd,551 $xMid,554" fill="$goldHex" opacity="0.85"/>');
    }

    // Diamond lattice chain border (left and right)
    final leftDiamonds = StringBuffer();
    final rightDiamonds = StringBuffer();
    for (double y = 70; y <= 490; y += 12) {
      final yStr = y.toStringAsFixed(1);
      final yMid = (y + 6).toStringAsFixed(1);
      final yEnd = (y + 12).toStringAsFixed(1);
      leftDiamonds.write('<polygon points="16,$yStr 13,$yMid 16,$yEnd 19,$yMid" fill="$goldHex" opacity="0.85"/>');
      rightDiamonds.write('<polygon points="798,$yStr 795,$yMid 798,$yEnd 801,$yMid" fill="$goldHex" opacity="0.85"/>');
    }

    // Refined Victorian / Baroque Corner Art Unit
    final cornerArt = '''
      <g>
        <!-- Corner Double Frame Bracket -->
        <path d="M 6,6 L 6,62 M 6,6 L 62,6" fill="none" stroke="$goldHex" stroke-width="1.8"/>
        <path d="M 10,10 L 10,52 M 10,10 L 52,10" fill="none" stroke="$primaryHex" stroke-width="0.9"/>
        <path d="M 14,14 L 14,42 M 14,14 L 42,14" fill="none" stroke="$goldHex" stroke-width="0.5" stroke-dasharray="2,2"/>

        <!-- Graceful C-Scroll Volute 1 -->
        <path d="M 10,10 C 26,10 40,18 40,30 C 40,40 32,46 22,46 C 14,46 9,38 12,30 C 14,24 20,22 26,26 C 29,28 29,32 26,34" fill="none" stroke="$primaryHex" stroke-width="0.9"/>

        <!-- Graceful C-Scroll Volute 2 (Mirrored) -->
        <path d="M 10,10 C 10,26 18,40 30,40 C 40,40 46,32 46,22 C 46,14 38,9 30,12 C 24,14 22,20 26,26 C 28,29 32,29 34,26" fill="none" stroke="$primaryHex" stroke-width="0.9"/>

        <!-- Diagonal Acanthus Leaf Spine -->
        <path d="M 10,10 Q 32,32 54,54" fill="none" stroke="$goldHex" stroke-width="1.1"/>
        
        <!-- Delicate Leaf Lobes -->
        <path d="M 18,18 Q 32,14 40,20 Q 30,24 22,21 Z" fill="$goldHex" opacity="0.9"/>
        <path d="M 18,18 Q 14,32 20,40 Q 24,30 21,22 Z" fill="$goldHex" opacity="0.9"/>
        
        <path d="M 28,28 Q 42,24 48,30 Q 38,34 32,30 Z" fill="$goldHex" opacity="0.8"/>
        <path d="M 28,28 Q 24,42 30,48 Q 34,38 30,32 Z" fill="$goldHex" opacity="0.8"/>
        
        <path d="M 36,36 Q 48,46 54,54 Q 46,48 36,36 Z" fill="$primaryHex" opacity="0.85"/>

        <!-- Delicate Swirling Tendril Endings -->
        <path d="M 40,20 C 46,16 52,20 50,25 C 48,28 45,27 45,24" fill="none" stroke="$goldHex" stroke-width="0.7"/>
        <path d="M 20,40 C 16,46 20,52 25,50 C 28,48 27,45 24,45" fill="none" stroke="$goldHex" stroke-width="0.7"/>

        <!-- Corner Floral Rosette at Apex -->
        <circle cx="10" cy="10" r="4.2" fill="$goldHex"/>
        <circle cx="10" cy="10" r="1.8" fill="#FFFFFF"/>
        <circle cx="6" cy="6" r="1.5" fill="$goldHex"/>
      </g>
    ''';

    return '''<svg viewBox="0 0 814 567" xmlns="http://www.w3.org/2000/svg">
      <g>
        <!-- 1. Outer Primary Frame -->
        <rect x="6" y="6" width="802" height="555" rx="8" fill="none" stroke="$primaryHex" stroke-width="${level >= 4 ? 3.2 : (level >= 3 ? 2.8 : 2.2)}"/>

        <!-- 2. Gold Foil Inset Line -->
        <rect x="9.5" y="9.5" width="795" height="548" rx="6" fill="none" stroke="$goldHex" stroke-width="0.9"/>

        <!-- 3. Diamond Lattice Chain Borders -->
        $topDiamonds
        $bottomDiamonds
        $leftDiamonds
        $rightDiamonds

        <!-- 4. Inner Accent Frame -->
        <rect x="22" y="22" width="770" height="523" rx="4" fill="none" stroke="$primaryHex" stroke-width="1.1"/>
        <rect x="25" y="25" width="764" height="517" rx="3" fill="none" stroke="$goldHex" stroke-width="0.6"/>

        <!-- 5. Edge Center Cartouche Rosettes -->
        <!-- Top Center -->
        <polygon points="407,11 412,16 407,21 402,16" fill="$goldHex"/>
        <circle cx="407" cy="16" r="1.5" fill="#FFFFFF"/>
        <!-- Bottom Center -->
        <polygon points="407,546 412,551 407,556 402,551" fill="$goldHex"/>
        <circle cx="407" cy="551" r="1.5" fill="#FFFFFF"/>
        <!-- Left Center -->
        <polygon points="16,278 21,283 16,288 11,283" fill="$goldHex"/>
        <circle cx="16" cy="283" r="1.5" fill="#FFFFFF"/>
        <!-- Right Center -->
        <polygon points="798,278 803,283 798,288 793,283" fill="$goldHex"/>
        <circle cx="798" cy="283" r="1.5" fill="#FFFFFF"/>

        <!-- 6. Four Corner Filigrees -->
        <!-- Top-Left -->
        $cornerArt
        <!-- Top-Right -->
        <g transform="translate(814, 0)"><g transform="scale(-1, 1)">$cornerArt</g></g>
        <!-- Bottom-Left -->
        <g transform="translate(0, 567)"><g transform="scale(1, -1)">$cornerArt</g></g>
        <!-- Bottom-Right -->
        <g transform="translate(814, 567)"><g transform="scale(-1, -1)">$cornerArt</g></g>
      </g>
    </svg>''';
  }

  // ══════════════════════════════════════════════════════════════════════════
  // VECTOR ORNAMENTS: Background Security Watermark
  // ══════════════════════════════════════════════════════════════════════════
  static String _buildWatermarkSvg(String primaryHex, String goldHex) {
    // 36 radial rays
    final rays = StringBuffer();
    for (int i = 0; i < 36; i++) {
      final rad = i * (2 * math.pi / 36);
      final x1 = (200 + 118 * math.cos(rad)).toStringAsFixed(1);
      final y1 = (200 + 118 * math.sin(rad)).toStringAsFixed(1);
      final x2 = (200 + 185 * math.cos(rad)).toStringAsFixed(1);
      final y2 = (200 + 185 * math.sin(rad)).toStringAsFixed(1);
      rays.write('<line x1="$x1" y1="$y1" x2="$x2" y2="$y2" stroke="$goldHex" stroke-width="0.8"/>');
    }

    return '''<svg viewBox="0 0 400 400" xmlns="http://www.w3.org/2000/svg" opacity="0.055">
      <g>
        $rays
        <!-- Concentric Security Guilloché Rings -->
        <circle cx="200" cy="200" r="185" fill="none" stroke="$goldHex" stroke-width="1.2" stroke-dasharray="4,4"/>
        <circle cx="200" cy="200" r="172" fill="none" stroke="$primaryHex" stroke-width="0.8"/>
        <circle cx="200" cy="200" r="165" fill="none" stroke="$goldHex" stroke-width="0.6"/>
        <circle cx="200" cy="200" r="120" fill="none" stroke="$primaryHex" stroke-width="0.8"/>
        <circle cx="200" cy="200" r="114" fill="none" stroke="$goldHex" stroke-width="0.6"/>

        <!-- Laurel Wreath Left -->
        <path d="M 190,305 C 160,295 130,265 125,225 C 120,185 145,145 185,120" fill="none" stroke="$goldHex" stroke-width="1.5"/>
        <path d="M 185,295 Q 165,285 155,270 Q 170,270 185,295 Z" fill="$goldHex"/>
        <path d="M 165,275 Q 145,260 140,240 Q 155,245 165,275 Z" fill="$goldHex"/>
        <path d="M 150,245 Q 130,225 130,205 Q 145,212 150,245 Z" fill="$goldHex"/>
        <path d="M 142,215 Q 125,190 132,170 Q 145,182 142,215 Z" fill="$goldHex"/>
        <path d="M 145,180 Q 135,155 150,140 Q 158,155 145,180 Z" fill="$goldHex"/>
        <path d="M 160,150 Q 155,130 175,120 Q 178,135 160,150 Z" fill="$goldHex"/>

        <!-- Laurel Wreath Right (Mirrored) -->
        <path d="M 210,305 C 240,295 270,265 275,225 C 280,185 255,145 215,120" fill="none" stroke="$goldHex" stroke-width="1.5"/>
        <path d="M 215,295 Q 235,285 245,270 Q 230,270 215,295 Z" fill="$goldHex"/>
        <path d="M 235,275 Q 255,260 260,240 Q 245,245 235,275 Z" fill="$goldHex"/>
        <path d="M 250,245 Q 270,225 270,205 Q 255,212 250,245 Z" fill="$goldHex"/>
        <path d="M 258,215 Q 275,190 268,170 Q 255,182 258,215 Z" fill="$goldHex"/>
        <path d="M 255,180 Q 265,155 250,140 Q 242,155 255,180 Z" fill="$goldHex"/>
        <path d="M 240,150 Q 245,130 225,120 Q 222,135 240,150 Z" fill="$goldHex"/>

        <!-- Center Heraldic Shield -->
        <path d="M 175,170 L 225,170 L 225,205 Q 225,238 200,250 Q 175,238 175,205 Z" fill="none" stroke="$primaryHex" stroke-width="1.8"/>
        <!-- 8-Pointed Starburst in Center of Shield -->
        <polygon points="200,185 204,196 215,196 206,202 210,213 200,207 190,213 194,202 185,196 196,196" fill="$goldHex"/>
      </g>
    </svg>''';
  }

  // ══════════════════════════════════════════════════════════════════════════
  // VECTOR ORNAMENTS: Top Heraldic Crest / Crown & Laurel Emblem
  // ══════════════════════════════════════════════════════════════════════════
  static String _buildTopHeraldicCrestSvg(String primaryHex, String goldHex, int level) {
    return '''<svg viewBox="0 0 200 64" xmlns="http://www.w3.org/2000/svg">
      <g>
        <!-- Center Heraldic Shield -->
        <path d="M 86,16 L 114,16 L 114,36 Q 114,56 100,63 Q 86,56 86,36 Z" fill="#FFFDF5" stroke="$primaryHex" stroke-width="1.6"/>
        <path d="M 89,19 L 111,19 L 111,35 Q 111,52 100,58 Q 89,52 89,35 Z" fill="none" stroke="$goldHex" stroke-width="0.8"/>
        <!-- Gold Star in Shield -->
        <polygon points="100,26 102.5,33 110,33 104,37.5 106.5,44.5 100,40.5 93.5,44.5 96,37.5 90,33 97.5,33" fill="$goldHex"/>

        <!-- Imperial Crown / Coronet on top of shield -->
        <path d="M 84,15 L 87,4 L 94,10 L 100,2 L 106,10 L 113,4 L 116,15 Z" fill="$goldHex" stroke="$primaryHex" stroke-width="0.8"/>
        <circle cx="87" cy="4" r="1.3" fill="#FFFFFF"/>
        <circle cx="100" cy="2" r="1.5" fill="#FFFFFF"/>
        <circle cx="113" cy="4" r="1.3" fill="#FFFFFF"/>

        <!-- Left Laurel Branch -->
        <path d="M 82,50 C 60,48 45,34 40,18" fill="none" stroke="$goldHex" stroke-width="1.3"/>
        <path d="M 76,46 Q 60,44 54,34 Q 68,36 76,46 Z" fill="$goldHex"/>
        <path d="M 64,38 Q 48,34 45,22 Q 58,26 64,38 Z" fill="$goldHex"/>
        <path d="M 52,28 Q 40,20 40,10 Q 50,16 52,28 Z" fill="$goldHex"/>

        <!-- Right Laurel Branch -->
        <path d="M 118,50 C 140,48 155,34 160,18" fill="none" stroke="$goldHex" stroke-width="1.3"/>
        <path d="M 124,46 Q 140,44 146,34 Q 132,36 124,46 Z" fill="$goldHex"/>
        <path d="M 136,38 Q 152,34 155,22 Q 142,26 136,38 Z" fill="$goldHex"/>
        <path d="M 148,28 Q 160,20 160,10 Q 150,16 148,28 Z" fill="$goldHex"/>

        <!-- Flowing Ribbon Swashes -->
        <path d="M 40,30 Q 20,25 4,32 Q 20,38 40,33 Z" fill="$primaryHex" opacity="0.85"/>
        <path d="M 160,30 Q 180,25 196,32 Q 180,38 160,33 Z" fill="$primaryHex" opacity="0.85"/>
      </g>
    </svg>''';
  }

  // ══════════════════════════════════════════════════════════════════════════
  // VECTOR ORNAMENTS: Calligraphic Divider Line with Swashes & Fleur-de-lis
  // ══════════════════════════════════════════════════════════════════════════
  static String _buildOrnamentalDividerSvg(String primaryHex, String goldHex, int level) {
    return '''<svg viewBox="0 0 400 20" xmlns="http://www.w3.org/2000/svg">
      <g>
        <!-- Center Fleur-de-lis / Diamond Rosette -->
        <polygon points="200,3 205,10 200,17 195,10" fill="$goldHex"/>
        <circle cx="190" cy="10" r="2" fill="$primaryHex"/>
        <circle cx="210" cy="10" r="2" fill="$primaryHex"/>
        <circle cx="184" cy="10" r="1.3" fill="$goldHex"/>
        <circle cx="216" cy="10" r="1.3" fill="$goldHex"/>

        <!-- Left Engraved Linework & Flourish Swashes -->
        <path d="M 178,10 C 145,4 120,16 80,10 C 50,5 25,12 2,10" fill="none" stroke="$primaryHex" stroke-width="1.0"/>
        <path d="M 155,8 Q 142,2 134,8" fill="none" stroke="$goldHex" stroke-width="0.8"/>
        <path d="M 105,12 Q 92,18 84,12" fill="none" stroke="$goldHex" stroke-width="0.8"/>
        <circle cx="2" cy="10" r="2" fill="$goldHex"/>

        <!-- Right Engraved Linework & Flourish Swashes -->
        <path d="M 222,10 C 255,4 280,16 320,10 C 350,5 375,12 398,10" fill="none" stroke="$primaryHex" stroke-width="1.0"/>
        <path d="M 245,8 Q 258,2 266,8" fill="none" stroke="$goldHex" stroke-width="0.8"/>
        <path d="M 295,12 Q 308,18 316,12" fill="none" stroke="$goldHex" stroke-width="0.8"/>
        <circle cx="398" cy="10" r="2" fill="$goldHex"/>
      </g>
    </svg>''';
  }

  // ══════════════════════════════════════════════════════════════════════════
  // VECTOR ORNAMENTS: Athlete Name Flourish Swashes
  // ══════════════════════════════════════════════════════════════════════════
  static String _buildNameFlourishSvg(String goldHex, bool flipX) {
    final transform = flipX ? 'transform="translate(60, 0) scale(-1, 1)"' : '';
    return '''<svg viewBox="0 0 60 20" xmlns="http://www.w3.org/2000/svg">
      <g $transform>
        <path d="M 58,10 C 44,3 32,17 18,10 C 10,6 4,12 1,10" fill="none" stroke="$goldHex" stroke-width="1.2"/>
        <path d="M 38,8 Q 30,1 24,8" fill="none" stroke="$goldHex" stroke-width="0.8"/>
        <circle cx="1" cy="10" r="1.8" fill="$goldHex"/>
      </g>
    </svg>''';
  }

  // ══════════════════════════════════════════════════════════════════════════
  // VECTOR ORNAMENTS: Official Rosette Seal with Silk Ribbon Tails
  // ══════════════════════════════════════════════════════════════════════════
  static String _buildRosetteSealSvg(String primaryHex, String goldHex, int level, String sealTitle) {
    // 32-point rosette polygon
    final rosettePoints = StringBuffer();
    for (int i = 0; i < 32; i++) {
      final rad = i * (2 * math.pi / 32);
      final r = (i % 2 == 0) ? 41.5 : 36.5;
      final x = (50 + r * math.cos(rad)).toStringAsFixed(1);
      final y = (46 + r * math.sin(rad)).toStringAsFixed(1);
      rosettePoints.write('$x,$y ');
    }

    // 28 pearl beads
    final beads = StringBuffer();
    for (int i = 0; i < 28; i++) {
      final rad = i * (2 * math.pi / 28);
      final cx = (50 + 31.5 * math.cos(rad)).toStringAsFixed(1);
      final cy = (46 + 31.5 * math.sin(rad)).toStringAsFixed(1);
      beads.write('<circle cx="$cx" cy="$cy" r="1.1" fill="$goldHex"/>');
    }

    return '''<svg viewBox="0 0 100 122" xmlns="http://www.w3.org/2000/svg">
      <g>
        <!-- Draped Silk Ribbon Tails with Inverted V-Notch -->
        <!-- Left Ribbon Tail -->
        <polygon points="36,65 24,115 36,106 48,115 44,65" fill="$goldHex"/>
        <polygon points="36,65 24,115 36,106 36,65" fill="$primaryHex" opacity="0.3"/>
        
        <!-- Right Ribbon Tail -->
        <polygon points="56,65 52,115 64,106 76,115 64,65" fill="$goldHex"/>
        <polygon points="56,65 64,106 76,115 64,65" fill="$primaryHex" opacity="0.4"/>

        <!-- 32-Point Scalloped Starburst Rosette -->
        <polygon points="$rosettePoints" fill="$goldHex" stroke="$primaryHex" stroke-width="1.0"/>
        <circle cx="50" cy="46" r="34.5" fill="#FFFDF5" stroke="$primaryHex" stroke-width="1.2"/>
        <circle cx="50" cy="46" r="33.0" fill="none" stroke="$goldHex" stroke-width="0.6"/>

        <!-- Pearl Bead Border -->
        $beads

        <circle cx="50" cy="46" r="27.5" fill="#FEF3C7" stroke="$goldHex" stroke-width="1.0"/>
        <circle cx="50" cy="46" r="25.5" fill="none" stroke="$primaryHex" stroke-width="0.5"/>

        <!-- Center Emblem: 5-Pointed Star & Laurel -->
        <polygon points="50,33 53,42 62,42 55,47.5 57.5,56.5 50,51.5 42.5,56.5 45,47.5 38,42 47,42" fill="$goldHex" stroke="$primaryHex" stroke-width="0.6"/>
      </g>
    </svg>''';
  }

  // ══════════════════════════════════════════════════════════════════════════
  // MASTER PDF GENERATOR
  // ══════════════════════════════════════════════════════════════════════════
  static Future<Uint8List> generateCertificatePdf(PlayerCertificateModel certificate) async {
    final pdf = pw.Document(title: 'Certificate - ${certificate.title}');
    final tier = certificate.tierDefinition;
    final level = tier.decorationLevel;

    // Palette Resolution - ALL WHITISH TINTS, NEVER BLACK!
    final primaryPdfColor = _getThemePdfColor(tier.theme);
    final primaryHex = _getThemeHex(tier.theme);
    final goldHex = _getGoldFoilHex(level);

    final goldPdfColor = PdfColor.fromInt(0xFFD97706);
    final darkNavy = PdfColor.fromInt(0xFF0F172A);
    final deepPlum = PdfColor.fromInt(0xFF581C87);
    final slateColor = PdfColor.fromInt(0xFF475569);

    // Whitish Canvas Background with subtle level tint
    final PdfColor canvasBg = level >= 5
        ? PdfColor.fromInt(0xFFFFFDF8) // Imperial Sovereign Alabaster with Warm Champagne Pearl Glow
        : (level >= 4
            ? PdfColor.fromInt(0xFFF2FBF9) // Porcelain Mint Luster Silk
            : (level >= 3
                ? PdfColor.fromInt(0xFFFFFDF5) // Luxury Royal Ivory Cream
                : (level >= 2
                    ? PdfColor.fromInt(0xFFF8FAFC) // Athletic Crisp Alabaster
                    : PdfColor.fromInt(0xFFFFFDF8)))); // Classic Warm Antique Parchment

    final PdfColor headingColor = (level >= 5) ? deepPlum : darkNavy;
    final PdfColor subHeadingColor = (level >= 3) ? goldPdfColor : primaryPdfColor;
    final PdfColor nameColor = (level >= 3) ? PdfColor.fromInt(0xFF9A3412) : darkNavy;
    final PdfColor bodyTextColor = PdfColor.fromInt(0xFF334155);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(14),
        build: (pw.Context context) {
          return pw.Container(
            color: canvasBg,
            child: pw.Stack(
              children: [
                // ══════════════════════════════════════════════════════════════
                // LAYER 1: Subtle Background Security Watermark
                // ══════════════════════════════════════════════════════════════
                pw.Center(
                  child: pw.SvgImage(
                    svg: _buildWatermarkSvg(primaryHex, goldHex),
                    width: 360,
                    height: 360,
                  ),
                ),

                // ══════════════════════════════════════════════════════════════
                // LAYER 2: Master Architectural Vector Frame (Full Page)
                // Outer borders, Diamond chain lattice, 4 Corner Filigrees, Edge Rosettes
                // ══════════════════════════════════════════════════════════════
                pw.Positioned(
                  top: 0,
                  left: 0,
                  child: pw.SvgImage(
                    svg: _buildMasterFrameSvg(
                      primaryHex: primaryHex,
                      goldHex: goldHex,
                      level: level,
                    ),
                    width: 814,
                    height: 567,
                  ),
                ),

                // ══════════════════════════════════════════════════════════════
                // LAYER 3: Certificate Content Layout (Safely Inside Frame)
                // ══════════════════════════════════════════════════════════════
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 55, vertical: 34),
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      // ──────────────────────────────────────────────────
                      // SECTION A: Heraldic Crest & Grand Header
                      // ──────────────────────────────────────────────────
                      pw.Column(
                        children: [
                          // Top Heraldic Crest / Crown & Laurel Emblem
                          pw.SvgImage(
                            svg: _buildTopHeraldicCrestSvg(primaryHex, goldHex, level),
                            width: 135,
                            height: 35,
                          ),
                          pw.SizedBox(height: 2),

                          // Accreditation Header Ribbon
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              if (level >= 3)
                                pw.Text('* * *  ', style: pw.TextStyle(color: goldPdfColor, fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
                              pw.Text(
                                tier.accreditationHeader.toUpperCase(),
                                style: pw.TextStyle(
                                  color: subHeadingColor,
                                  fontSize: level >= 4 ? 10.0 : 9.0,
                                  fontWeight: pw.FontWeight.bold,
                                  letterSpacing: level >= 3 ? 2.4 : 1.6,
                                ),
                              ),
                              if (level >= 3)
                                pw.Text('  * * *', style: pw.TextStyle(color: goldPdfColor, fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
                            ],
                          ),
                          pw.SizedBox(height: 2),

                          // Grand Certificate Title
                          pw.Text(
                            tier.certificateHeading,
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              color: headingColor,
                              fontSize: level >= 4 ? 20.5 : (level >= 3 ? 19.0 : 17.5),
                              fontWeight: pw.FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),

                          // Latin Motto Pill / Cartouche
                          if (level >= 2) ...[
                            pw.SizedBox(height: 2),
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                              decoration: pw.BoxDecoration(
                                color: PdfColor.fromInt(0xFFFEF3C7),
                                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                                border: pw.Border.all(color: goldPdfColor, width: 0.6),
                              ),
                              child: pw.Text(
                                '~ ${tier.latinMotto.toUpperCase()} ~',
                                style: pw.TextStyle(
                                  color: PdfColor.fromInt(0xFF92400E),
                                  fontSize: 8.0,
                                  fontStyle: pw.FontStyle.italic,
                                  fontWeight: pw.FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ],

                          pw.SizedBox(height: 3),
                          // Ornate Section Divider with Fleur-de-lis & Swashes
                          pw.SvgImage(
                            svg: _buildOrnamentalDividerSvg(primaryHex, goldHex, level),
                            width: 290,
                            height: 12,
                          ),
                        ],
                      ),

                      // ──────────────────────────────────────────────────
                      // SECTION B: Conferred Statement & Athlete Presentation
                      // ──────────────────────────────────────────────────
                      pw.Column(
                        children: [
                          pw.Text(
                            level >= 5
                                ? 'By Sovereign Decreed Authority of the Supreme National Sports Board, this honor is formally conferred upon'
                                : (level >= 4
                                    ? 'By executive resolution of the High Performance Council, this convocation is awarded unto'
                                    : 'This official sports accreditation is formally awarded to'),
                            style: pw.TextStyle(
                              color: PdfColors.grey700,
                              fontSize: 9.5,
                              fontStyle: pw.FontStyle.italic,
                            ),
                          ),
                          pw.SizedBox(height: 3),

                          // Athlete Name Flanked by Calligraphic Swashes
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            crossAxisAlignment: pw.CrossAxisAlignment.center,
                            children: [
                              pw.SvgImage(
                                svg: _buildNameFlourishSvg(goldHex, false),
                                width: 40,
                                height: 14,
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.symmetric(horizontal: 12),
                                child: pw.Text(
                                  certificate.playerName.toUpperCase(),
                                  style: pw.TextStyle(
                                    color: nameColor,
                                    fontSize: level >= 4 ? 26 : 24,
                                    fontWeight: pw.FontWeight.bold,
                                    letterSpacing: 1.8,
                                  ),
                                ),
                              ),
                              pw.SvgImage(
                                svg: _buildNameFlourishSvg(goldHex, true),
                                width: 40,
                                height: 14,
                              ),
                            ],
                          ),

                          pw.SizedBox(height: 4),
                          // Sport & Milestone Credential Pill
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 3.5),
                            decoration: pw.BoxDecoration(
                              color: (level >= 3) ? PdfColor.fromInt(0xFFFFFBEB) : PdfColor.fromInt(0xFFF1F5F9),
                              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                              border: pw.Border.all(
                                color: (level >= 3) ? goldPdfColor : primaryPdfColor,
                                width: level >= 3 ? 1.0 : 0.6,
                              ),
                            ),
                            child: pw.Text(
                              '${certificate.sport.toUpperCase()}  |  ${tier.title.toUpperCase()} (TIER ${tier.tier} OF 15 - ${tier.accolade.toUpperCase()})  |  ${certificate.requiredXp} CAREER XP',
                              style: pw.TextStyle(
                                color: (level >= 3) ? PdfColor.fromInt(0xFF92400E) : primaryPdfColor,
                                fontSize: 8.5,
                                fontWeight: pw.FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // ──────────────────────────────────────────────────
                      // SECTION C: Citation / Milestone Narrative
                      // ──────────────────────────────────────────────────
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 36),
                        child: pw.Text(
                          '${tier.description} Formally indexed into the permanent sports registry for verified drill benchmarks and surpassing ${certificate.requiredXp} Career XP.',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            color: bodyTextColor,
                            fontSize: 9.0,
                            lineSpacing: 1.5,
                          ),
                        ),
                      ),

                      // ──────────────────────────────────────────────────
                      // SECTION D: Signatories, Rosette Seal & Verification
                      // Indented inward by 24 pt to stay clear of corner filigrees
                      // ──────────────────────────────────────────────────
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 24),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            // Left Signatory (Lead Coach)
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Container(
                                  width: 125,
                                  height: 1,
                                  color: slateColor,
                                ),
                                pw.SizedBox(height: 3),
                                pw.Text(
                                  level >= 5 ? 'Chairman Marcus Sterling' : (certificate.coachName ?? 'Lead Coach'),
                                  style: pw.TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: pw.FontWeight.bold,
                                    color: headingColor,
                                  ),
                                ),
                                pw.Text(
                                  tier.signatoryRoles.first,
                                  style: pw.TextStyle(
                                    fontSize: 7.5,
                                    color: PdfColors.grey700,
                                  ),
                                ),
                              ],
                            ),

                            // Center: Ornate Rosette Medallion Seal
                            pw.Column(
                              children: [
                                pw.SvgImage(
                                  svg: _buildRosetteSealSvg(primaryHex, goldHex, level, tier.sealTitle),
                                  width: 68,
                                  height: 82,
                                ),
                                pw.SizedBox(height: 2),
                                pw.Text(
                                  tier.sealTitle,
                                  style: pw.TextStyle(
                                    color: PdfColor.fromInt(0xFF92400E),
                                    fontSize: 7.0,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                                pw.Text(
                                  'HASH: ${certificate.verificationHash}',
                                  style: pw.TextStyle(
                                    fontSize: 6.5,
                                    fontWeight: pw.FontWeight.bold,
                                    color: darkNavy,
                                  ),
                                ),
                                if (level >= 4) ...[
                                  pw.Text(
                                    level >= 5 ? 'SUPREME NATIONAL ROSTER: SEC-HOF-IND-01' : 'LEDGER: SEC-HONOR-ROLL-INDEX',
                                    style: pw.TextStyle(
                                      fontSize: 6.0,
                                      color: goldPdfColor,
                                    ),
                                  ),
                                ],
                              ],
                            ),

                            // Center-Right Signatory (if applicable)
                            if (tier.signatoryRoles.length > 1) ...[
                              pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Container(
                                    width: 125,
                                    height: 1,
                                    color: slateColor,
                                  ),
                                  pw.SizedBox(height: 3),
                                  pw.Text(
                                    level >= 5 ? 'Dr. Elizabeth Warren' : (certificate.academyName ?? 'KRICO Academy'),
                                    style: pw.TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: pw.FontWeight.bold,
                                      color: headingColor,
                                    ),
                                  ),
                                  pw.Text(
                                    tier.signatoryRoles[1],
                                    style: pw.TextStyle(
                                      fontSize: 7.5,
                                      color: PdfColors.grey700,
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            // Right: Date Issued
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.end,
                              children: [
                                pw.Container(
                                  width: 105,
                                  height: 1,
                                  color: slateColor,
                                ),
                                pw.SizedBox(height: 3),
                                pw.Text(
                                  DateFormat('MMMM d, yyyy').format(certificate.awardedAt),
                                  style: pw.TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: pw.FontWeight.bold,
                                    color: headingColor,
                                  ),
                                ),
                                pw.Text(
                                  'Conferral Date',
                                  style: pw.TextStyle(
                                    fontSize: 7.5,
                                    color: PdfColors.grey700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Downloads or opens print preview on mobile/web/desktop
  static Future<void> downloadOrPrintCertificate(PlayerCertificateModel certificate) async {
    final pdfBytes = await generateCertificatePdf(certificate);
    final filename = 'Certificate_${certificate.playerName.replaceAll(' ', '_')}_Tier${certificate.tier}.pdf';

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: filename,
    );
  }

  /// Direct Share PDF option
  static Future<void> shareCertificatePdf(PlayerCertificateModel certificate) async {
    final pdfBytes = await generateCertificatePdf(certificate);
    final filename = 'Certificate_${certificate.playerName.replaceAll(' ', '_')}_Tier${certificate.tier}.pdf';

    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: filename,
    );
  }
}
