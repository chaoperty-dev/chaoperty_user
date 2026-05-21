// ignore_for_file: unused_import, non_constant_identifier_names, unused_local_variable

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../model/Home_Model.dart';

class WaitPayListProvider with ChangeNotifier {
  //รับค่า
  List<WaitHome> ListItem = [];
  List ListDF = [];
  List date_pre = [];
  List<DateTime> date_pre_single = [];

  DateTime? stt;
  DateTime? endd;
  double amount = 0;
  int count = 0;
  bool ischecked = false, dps_check = false;
  String market_name = "";
  int selected = 0;
  //ดึงข้อมูล
  List<WaitHome> getTransaction() {
    return ListItem;
  }

  //
  Future<void> add_wh(WaitHome statement) async {
    ListItem.add(statement);
    ListItem.sort((item1, item2) => item1.index.compareTo(item2.index));
    await datenowshow();
    //  print("//////////////////ListItem.length ${ListItem.length}");
    count = ListDF.length;
    notifyListeners();
  }

  void update_wh_value(index1, value) {
    ListItem[index1].value = value;
    datenowshow();
    notifyListeners();
  }

  //
  sortindex(WaitHome sort) {
    ListItem.sort((item1, item2) => item1.index.compareTo(item2.index));
    notifyListeners();
  }

  datenowshow() {
    DateTime datenow = DateTime.now();
    var datenowformat = DateFormat('yyyy-MM-dd').format(datenow);
    DateTime dnow = DateTime.parse(datenowformat);
    ListDF = [];
    ListItem.forEach((element) {
      DateTime date = DateTime.parse(element.date);

      if (date.isBefore(dnow) || dnow == date) {
        ListDF.add({
          'title': element.title,
          'date': element.date,
          'total': element.total,
          'index': element.index,
          'value': element.value,
          'month': element.month
        });
        element.value = true;
        // print("LI${ListDF.length}");
      }
    });
    notifyListeners();
  }

  Amount(aindex) {
    double total = 0;
    if (ListItem[aindex].value == false) {
      ListItem[aindex].value = true;
      total = double.parse(ListItem[aindex].total);
      amount = amount + total;
    } else if (ListItem[aindex].value == true) {
      ListItem[aindex].value = false;
      total = double.parse(ListItem[aindex].total);
      amount = amount - total;
      notifyListeners();
    }
  }

  All_Amount(aindex) {
    double total = 0;
    if (ListItem[aindex].value == true) {
      total = double.parse(ListItem[aindex].total);
      amount = amount + total;
    } else {}
    notifyListeners();
  }

  select_date(List datelist, submit) {
    if (date_pre_single.length <= 0 && submit == true) {
      if (datelist.length <= 0) {
        print("dl = 0 -- dps = 0");
      } else if (datelist.length > 0) {
        datelist.forEach((dl) {
          print("add : $dl");
          date_pre_single.add(dl);
          ListItem.forEach((element) {
            DateTime ele_date = DateTime.parse(element.date);
            if (ele_date == dl) {
              Amount(element.index);
              print(
                  "${element.index}--${element.date}--${element.total}--${element.value}");
            }
          });
          print("Add complete");
        });
      }
    } else if (date_pre_single.length <= 0 && submit == false) {
      print("date_pre_single.length <= 0 && submit == false");
      print("dps = ${date_pre_single.length}");
    } else if (date_pre_single.length > 0 && submit == true) {
      date_pre_single.forEach((dps) {
        print("delete : $dps");
        ListItem.forEach((element) {
          DateTime ele_date = DateTime.parse(element.date);
          if (dps == ele_date) {
            Amount(element.index);
            print(
                "${element.index}--${element.date}--${element.total}--${element.value}");
          }
        });
      });
      date_pre_single = [];
      print("dps =${date_pre_single.length}");
      print("Delete complete");

      datelist.forEach((dl) {
        print("add : $dl");
        date_pre_single.add(dl);
        ListItem.forEach((element) {
          DateTime ele_date = DateTime.parse(element.date);
          if (ele_date == dl) {
            Amount(element.index);
            print(
                "${element.index}--${element.date}--${element.total}--${element.value}");
          }
        });
        print("Add complete");
      });
    } else if (date_pre_single.length > 0 && submit == false) {
      date_pre_single.forEach((dps) {
        print("delete : $dps");
        ListItem.forEach((element) {
          DateTime ele_date = DateTime.parse(element.date);
          if (dps == ele_date) {
            Amount(element.index);
            print(
                "${element.index}--${element.date}--${element.total}--${element.value}");
          }
        });
      });
      date_pre_single = [];
      print("dps =${date_pre_single.length}");
      print("Delete complete");
    }
    notifyListeners();
  }

  preAmount_date(start, end, submit) {
    print("preAmount_date($start, $end)");
    if (stt != null && endd == null) {
      print("1");
      ListItem.forEach((element) {
        DateTime ele_date = DateTime.parse(element.date);
        if (stt == ele_date) {
          print(
              "!= null ${element.index}// ${ele_date} // value : ${element.value}");
          Amount(element.index);
          print(
              "!= null ${element.index}//${ele_date} // value : ${element.value} Amount");
        }
      });
      date_pre = [];
      stt = null;
      endd = null;
      if (submit == true) {
        prepay_date(start, end);
      } else if (submit == false) {
        print("cancle");
      }
    } else if (stt != null && endd != null) {
      print("2");
      DateTime? old;
      date_pre.forEach((date_pre_) {
        if (old == null) {
          old = date_pre_;
          ListItem.forEach((element) {
            DateTime ele_date = DateTime.parse(element.date);
            if (date_pre_ == ele_date) {
              print(
                  "!= null ${element.index}// ${ele_date} // value : ${element.value}");
              Amount(element.index);
              print(
                  "!= null ${element.index}//${ele_date} // value : ${element.value} Amount");
            }
          });
        } else if (old != null && old != date_pre_) {
          old = date_pre_;
          ListItem.forEach((element) {
            DateTime ele_date = DateTime.parse(element.date);
            if (date_pre_ == ele_date) {
              print(
                  "!= null ${element.index}// ${ele_date} // value : ${element.value}");
              Amount(element.index);
              print(
                  "!= null ${element.index}//${ele_date} // value : ${element.value} Amount");
            }
          });
        } else if (old == date_pre_) {
          print("aaaa");
        }
      });
      date_pre = [];
      stt = null;
      endd = null;
      if (submit == true) {
        prepay_date(start, end);
      } else if (submit == false) {
        print("cancle");
      }
    } else if (stt == null && endd == null) {
      print("3");
      date_pre = [];
      stt = null;
      endd = null;
      if (submit == true) {
        prepay_date(start, end);
      } else if (submit == false) {
        print("cancle");
      }
    }

    notifyListeners();
  }

  prepay_date(start, end) {
    var check = (start != null && end == '');
    if (check == true) {
      DateTime st = DateTime.parse(start);
      stt = st;
      endd = null;
      DateTime st_date = DateTime(st.year, st.month, st.day - 1);
      ListItem.forEach((element) {
        DateTime ele_date = DateTime.parse(element.date);
        if (stt == ele_date) {
          print(
              "== null ${element.index}// ${element.date} // value : ${element.value}");
          Amount(element.index);
          print(
              "== null ${element.index}// ${element.date} // value : ${element.value} Amount");
        }
      });
    } else if (start == '' && end == '') {
      stt = null;
      endd = null;
    } else {
      DateTime st = DateTime.parse(start);
      DateTime e = DateTime.parse(end);
      stt = st;
      endd = e;
      DateTime st_date = DateTime(st.year, st.month, st.day - 1);
      DateTime e_date = DateTime(e.year, e.month, e.day + 1);
      ListItem.forEach((element) {
        DateTime el_date = DateTime.parse(element.date);
        if (el_date.isBefore(e_date) && el_date.isAfter(st_date)) {
          date_pre.add(el_date);
          print(
              "== null ${element.index}// ${element.date} // value : ${element.value}");
          Amount(element.index);
          print(
              "== null ${element.index}// ${element.date} // value : ${element.value} Amount");
        }
      });
    }
    notifyListeners();
  }

  select(value) {
    selected = value;
    notifyListeners();
  }

  void marketname(name) {
    market_name = name;
    notifyListeners();
  }
}
