import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../model/pay_Model.dart';

class PayFormProvider with ChangeNotifier {
  //รับค่า
  List<PayFormModel> data = [];

  //ดึงข้อมูล
  List<PayFormModel> getTransaction() {
    return data;
  }

  //
  void add_pf(PayFormModel formdata) {
    data.add(formdata);
    print(data);
    notifyListeners();
  }
}
