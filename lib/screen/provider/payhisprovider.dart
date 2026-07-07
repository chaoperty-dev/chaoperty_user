import 'package:flutter/foundation.dart';

import '../model/payhis_Model.dart';

class PayHisProvider extends ChangeNotifier {
  List<RebillModel> Rebill = [];
  String foder = "";

  /// รีเซ็ต state (เรียกตอน logout)
  void reset() {
    Rebill = <RebillModel>[];
    foder = "";
    notifyListeners();
  }

  List<RebillModel> getTransaction() {
    return Rebill;
  }

  Future<void> add_rebill(RebillModel data) async {
    Rebill.add(data);
    print("Rebill${Rebill.length}");
    Rebill.forEach(
      (element) {
        // print(element.docno);
      },
    );
    notifyListeners();
  }

  Future<void> Foder(name) async {
    foder = name;
    notifyListeners();
  }
}
