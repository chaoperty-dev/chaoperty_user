// ignore_for_file: unused_import, unused_local_variable, unnecessary_null_comparison, unused_field, override_on_non_overriding_member, prefer_const_constructors, unnecessary_import, implementation_imports, prefer_const_constructors_in_immutables, non_constant_identifier_names, avoid_init_to_null, prefer_void_to_null, unnecessary_brace_in_string_interps, avoid_print, sized_box_for_whitespace, use_build_context_synchronously, file_names, prefer_const_literals_to_create_immutables, prefer_const_declarations, unnecessary_string_interpolations, prefer_collection_literals, sort_child_properties_last, avoid_unnecessary_containers, prefer_is_empty, prefer_final_fields, camel_case_types, avoid_web_libraries_in_flutter, prefer_typing_uninitialized_variables, no_leading_underscores_for_local_identifiers, deprecated_member_use
import 'package:intl/intl.dart';

String roundToTwoDecimals(String input) {
  // ລຶບຄ່າອອກຈາກຕົວເລກ
  String sanitizedInput = input.replaceAll(',', '');

  // ແປງເປັນ double ແລະປັດຄ່າໄປທີ່ໃກລ້ອງຄົງສູງໃນລະດັບທີ່ສູງ
  double number = double.parse(sanitizedInput);
  double rounded = (number * 10).round() / 10;

  // ແປງໃຫ້ເປັນ String ທີ່ມີທົດສອງຕຳແໜ່
  return rounded.toStringAsFixed(2);
}

String convertToLaoBaht(double amount) {
  var nFormat = NumberFormat("#,##0.00", "en_US");
  var nFormat2 = NumberFormat("###0.00", "en_US");
  final List<String> _digitLao = [
    'ສູນ',
    'ໜຶງ',
    'ສອງ',
    'ສາມ',
    'ສີ່',
    'ຫ້າ',
    'ຫົກ',
    'ເຈັດ',
    'ແປດ',
    'ເກົ້າ'
  ];

  final List<String> _positionLao = [
    '',
    'ສິບ',
    'ຮ້ອຍ',
    'ພັນ',
    'ໝື່ນ',
    'ແສນ',
    'ລ້ານ'
  ];
  /////////////////////////////------------------------>(ຈຳນວນເຕັມ)
  String convertNumberToText(int number) {
    String result = '';
    int numberIntPart = number.toInt();
    int numberDecimalPart = ((number - numberIntPart) * 100).toInt();
    final List<String> digits = numberIntPart.toString().split('');
    int position = digits.length - 1;
    for (int i = 0; i < digits.length; i++) {
      final int digit = int.parse(digits[i]);
      if (digit != 0) {
        if (position == 6) {
          result = '$result${_positionLao[6]}';
        }
        if (position != 6 && position != 8) {
          if (digit == 1 && position == 1) {
            // result = '$resultເຈັດ';
            result = '$resultສິບ';
          } else {
            result = '$result${_digitLao[digit]}${_positionLao[position % 6]}';
          }
        } else if (position == 8) {
          result = '$result${_digitLao[digit]}${_positionLao[6]}';
        }
      }
      position--;
    }
    // final String decimalText =
    //     convertNumberToText(numberDecimalPart).replaceAll(_digitLao[0], "");
    return result;
  }

  /////////////////////////////------------------------>(ຈຳນວນທົດສອງຕຳແໜ່)
  String convertNumberToText2(int number2) {
    String result = '';
    int numberIntPart = number2.toInt();
    int numberDecimalPart = ((number2 - numberIntPart) * 100).toInt();
    final List<String> digits = numberIntPart.toString().split('');
    int position = digits.length - 1;
    for (int i = 0; i < digits.length; i++) {
      final int digit = int.parse(digits[i]);
      if (digit != 0) {
        if (position == 6) {
          result = '$result${_positionLao[6]}';
        }
        if (position != 6 && position != 8) {
          if (digit == 1 && position == 1) {
            // result = '$resultເຈັດ';
            result = '$resultສິບ';
          } else {
            result = '$result${_digitLao[digit]}${_positionLao[position % 6]}';
          }
        } else if (position == 8) {
          result = '$result${_digitLao[digit]}${_positionLao[6]}';
        }
      }
      position--;
    }
    // final String decimalText =
    //     convertNumberToText(numberDecimalPart).replaceAll(_digitLao[0], "");
    return result;
  }

  //////////////////------------->(ຕັດ ຫນ້າຈຸດກັບຫລັງຈຸດອອກຈາກກັນ)
  var number_ = "${nFormat2.format(double.parse(amount.toString()))}";
  var parts = number_.split('.');
  var front = parts[0];
  var back = parts[1];

  //////////////////--------------->(ກີບ)
  double number = double.parse(front);
  final int numberIntPart = number.toInt();
  final double numberDecimalPart = (number - numberIntPart) * 100;
  final String numberText = convertNumberToText(numberIntPart);
  final String decimalText = convertNumberToText(numberDecimalPart.toInt());
  //////////////////------------->(ສຕາງຄ໌)
  double number2 = double.parse(number_);
  final int numberIntPart2 = number.toInt();
  final int numberDecimalPart2 = ((number2 - numberIntPart2) * 100).round();
  final String numberText2 = convertNumberToText2(numberIntPart2);
  final String decimalText2 = convertNumberToText2(numberDecimalPart2.toInt());
  //////////////////-------------->((ເຊັກແລະເພິ່ມຕົວອັກສອນ)
  final String formattedNumber = (decimalText2.replaceAll(_digitLao[0], "") ==
          '')
      ? '$numberTextກີບຖ້ວນ'
      : (back[0].toString() == '0')
          ? '$numberTextກີບຈຸດສູນ${decimalText2.replaceAll(_digitLao[0], "")}ສຕາງຄ໌'
          : '$numberTextກີບຈຸດ${decimalText2.replaceAll(_digitLao[0], "")}ສຕາງຄ໌';

  String text_Number1 = formattedNumber;
  RegExp exp1 = RegExp(r"ສອງສິບ");
  if (exp1.hasMatch(text_Number1)) {
    text_Number1 = text_Number1.replaceAll(exp1, 'ສອງສິບ');
  }
  String text_Number2 = text_Number1;
  RegExp exp2 = RegExp(r"ສິບໜຶງ");
  if (exp2.hasMatch(text_Number2)) {
    text_Number2 = text_Number2.replaceAll(exp2, 'ສິບເຈັດ');
  }

  return (amount == 0.00) ? 'ສູນກີບຈຸດສູນສູນສູນສຕາງຄ໌ຖ້ວນ' : text_Number2;
}

// ອ່ານແຄ່ຈຳນວນເຕັມ
String laoIntegerFromAmount(double amount) {
  final int n = amount.truncate(); // ຕັດທົດສອງຕຳແໜ່ ບໍ່ປັດຂຶ້ນ
  return _laoNumber(n);
}

String _laoNumber(int n) {
  if (n == 0) return 'ສູນ';
  if (n < 0) return 'ລົບ${_laoNumber(-n)}';

  // ຈັດການທີ່ລະ "ລ້ານ"
  if (n >= 1000000) {
    final int millions = n ~/ 1000000;
    final int rest = n % 1000000;
    final head = '${_laoNumber(millions)}ລ້ານ';
    return rest == 0 ? head : '$head${_laoUnderMillion(rest)}';
  }
  return _laoUnderMillion(n);
}

String _laoUnderMillion(int n) {
  final digits = [
    'ສູນ',
    'ໜຶງ',
    'ສອງ',
    'ສາມ',
    'ສີ່',
    'ຫ້າ',
    'ຫົກ',
    'ເຈັດ',
    'ແປດ',
    'ເກົ້າ'
  ];
  final units = ['', 'ສິບ', 'ຮ້ອຍ', 'ພັນ', 'ໝື່ນ', 'ແສນ'];

  final s = n.toString();
  final len = s.length;
  final buf = StringBuffer();

  for (int i = 0; i < len; i++) {
    final d = int.parse(s[i]);
    final pos = len - i - 1; // 0=ຫນ້ອຍ,1=ສິບ,...,5=ແສນ

    if (d == 0) continue;

    if (pos == 0) {
      // ຫລັກຫນ້ອຍ
      if (len > 1 && d == 1) {
        buf.write('ເຈັດ'); // …ເຈັດ (ເມື່ອມີຫລັກສູງກວ່າຫນ້ອຍ)
      } else {
        buf.write(digits[d]);
      }
    } else if (pos == 1) {
      // ຫລັກສິບ
      if (d == 1) {
        buf.write('ສິບ');
      } else if (d == 2) {
        buf.write('ສອງສິບ');
      } else {
        buf.write('${digits[d]}ສິບ');
      }
    } else {
      buf.write('${digits[d]}${units[pos]}');
    }
  }
  return buf.toString();
}
