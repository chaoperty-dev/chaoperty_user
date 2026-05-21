class RebillModel {
  final doctax; //เลขบิล
  final docno; //เลขบิลมั้ง
  final daterec; //วันที่ชำระ
  final dtype; //รายการชำระ
  final expname; //รายการที่ยกเลิก
  final total_sum;
  RebillModel({this.doctax, this.docno, this.daterec, this.dtype, this.expname, this.total_sum});
}
