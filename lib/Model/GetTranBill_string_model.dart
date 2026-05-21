class TransBillStringModel {
  String? ser;
  String? docno;

  TransBillStringModel({
    this.ser,
    this.docno,
  });

  TransBillStringModel.fromJson(Map<String, dynamic> json) {
    ser = json['ser'];
    docno = json['docno'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ser'] = this.ser;
    data['docno'] = this.docno;

    return data;
  }
}
