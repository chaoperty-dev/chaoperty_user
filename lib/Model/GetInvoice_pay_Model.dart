class InvoicePayModel {
  String? ser;
  String? docno;
  String? amtall;
  String? fine;
  String? discount;
  String? fine_book;
  String? discount_book;

  InvoicePayModel({
    this.ser,
    this.docno,
    this.amtall,
    this.fine,
    this.discount,
    this.fine_book,
    this.discount_book,
  });

  InvoicePayModel.fromJson(Map<String, dynamic> json) {
    ser = json['ser'];
    docno = json['docno'];
    amtall = json['amtall'];
    fine = json['fine'];
    discount = json['discount'];
    fine_book = json['fine_book'];
    discount_book = json['discount_book'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ser'] = this.ser;
    data['docno'] = this.docno;
    data['amtall'] = this.amtall;
    data['fine'] = this.fine;
    data['discount'] = this.discount;
    data['fine_book'] = this.fine_book;
    data['discount_book'] = this.discount_book;
    return data;
  }
}
