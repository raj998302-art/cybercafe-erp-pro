import 'package:intl/intl.dart';

/// Indian GST calculation utilities.
/// Computes CGST + SGST for intra-state, IGST for inter-state.
class GstService {
  /// Returns {cgst, sgst, igst, total} for a given taxable amount.
  static Map<String, double> breakup(
      double taxable, double gstRate, bool isIntraState) {
    final gst = taxable * gstRate / 100;
    if (isIntraState) {
      // Ensure cgst + sgst == total exactly (avoid 0.01 rounding mismatch)
      final totalGst = round(gst);
      final cgst = (totalGst / 2).roundToDouble();
      final sgst = totalGst - cgst;
      return {
        'cgst': cgst,
        'sgst': sgst,
        'igst': 0,
        'total': totalGst,
      };
    }
    return {
      'cgst': 0,
      'sgst': 0,
      'igst': round(gst),
      'total': round(gst),
    };
  }

  static double round(double v) => double.parse(v.toStringAsFixed(2));

  static String formatMoney(double v) {
    final f = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
    return f.format(v);
  }

  static String formatNumber(double v) =>
      NumberFormat.currency(locale: 'en_IN', symbol: '', decimalDigits: 2)
          .format(v);
}

/// Convert a number into Indian English words (rupees and paise).
/// Lightweight implementation supporting up to crores.
class AmountInWords {
  static const _ones = [
    '', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight',
    'Nine', 'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen',
    'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'
  ];
  static const _tens = [
    '', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy',
    'Eighty', 'Ninety'
  ];
  static const _scales = ['', 'Thousand', 'Lakh', 'Crore'];

  static String convert(double amount) {
    if (amount == 0) return 'Zero Rupees Only';

    final rupees = amount.truncate();
    final paise = ((amount - rupees) * 100).round();

    String words;
    if (rupees == 0) {
      words = '';
    } else {
      words = _convertIndian(rupees) + ' Rupees';
    }

    if (paise > 0) {
      if (rupees > 0) words += ' and ';
      words += '${_convertIndian(paise)} Paise';
    }
    return '$words Only';
  }

  static String _convertIndian(int n) {
    if (n == 0) return '';
    final parts = <String>[];
    // Indian grouping: last 3 digits, then groups of 2
    final thousands = n % 1000;
    n ~/= 1000;
    parts.insert(0, _twoOrThreeDigit(thousands));
    int scaleIdx = 1;
    while (n > 0) {
      final grp = n % 100;
      n ~/= 100;
      if (grp > 0) {
        parts.insert(0, '${_twoOrThreeDigit(grp)} ${_scales[scaleIdx]}');
      }
      scaleIdx++;
    }
    return parts.where((s) => s.isNotEmpty).join(' ').trim();
  }

  static String _twoOrThreeDigit(int n) {
    if (n == 0) return '';
    if (n < 20) return _ones[n];
    if (n < 100) {
      return '${_tens[n ~/ 10]}${n % 10 != 0 ? ' ${_ones[n % 10]}' : ''}';
    }
    // 3-digit (only for the thousands group)
    final h = n ~/ 100;
    final rem = n % 100;
    final sb = StringBuffer('${_ones[h]} Hundred');
    if (rem > 0) sb.write(' ${_twoOrThreeDigit(rem)}');
    return sb.toString();
  }
}
