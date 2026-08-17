class AuthorizedLessorModel {
  String? id;
  String? uuid;
  String? type;
  String? firstName;
  String? lastName;
  String? taxId;
  String? phoneNumber;
  String? email;
  String? address;
  String? bankAccountName;
  String? bankAccountNumber;
  String? bankName;
  String? authorizationDocPath;
  String? birth;
  String? status;
  String? createdBy;
  String? updatedBy;
  String? createdAt;
  String? updatedAt;
  List<String> assignedZones;

  AuthorizedLessorModel({
    this.id,
    this.uuid,
    this.type,
    this.firstName,
    this.lastName,
    this.taxId,
    this.phoneNumber,
    this.email,
    this.address,
    this.bankAccountName,
    this.bankAccountNumber,
    this.bankName,
    this.authorizationDocPath,
    this.birth,
    this.status,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
    this.assignedZones = const [],
  });

  AuthorizedLessorModel.fromJson(Map<String, dynamic> json)
      : assignedZones = (json['assigned_zones'] is List)
            ? (json['assigned_zones'] as List)
                .map((e) => e.toString())
                .where((e) => e.isNotEmpty)
                .toList()
            : <String>[] {
    id = json['id']?.toString();
    uuid = json['uuid']?.toString();
    type = json['type']?.toString();
    firstName = json['first_name']?.toString();
    lastName = json['last_name']?.toString();
    taxId = json['tax_id']?.toString();
    phoneNumber = json['phone_number']?.toString();
    email = json['email']?.toString();
    address = json['address']?.toString();
    bankAccountName = json['bank_account_name']?.toString();
    bankAccountNumber = json['bank_account_number']?.toString();
    bankName = json['bank_name']?.toString();
    authorizationDocPath = json['authorization_doc_path']?.toString();
    birth = json['birth']?.toString();
    status = json['status']?.toString();
    createdBy = json['created_by']?.toString();
    updatedBy = json['updated_by']?.toString();
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['uuid'] = uuid;
    data['type'] = type;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['tax_id'] = taxId;
    data['phone_number'] = phoneNumber;
    data['email'] = email;
    data['address'] = address;
    data['bank_account_name'] = bankAccountName;
    data['bank_account_number'] = bankAccountNumber;
    data['bank_name'] = bankName;
    data['authorization_doc_path'] = authorizationDocPath;
    data['birth'] = birth;
    data['status'] = status;
    data['created_by'] = createdBy;
    data['updated_by'] = updatedBy;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['assigned_zones'] = assignedZones;
    return data;
  }

  /// ชื่อที่ใช้แสดงผล: บุคคลธรรมดาใช้ ชื่อ + นามสกุล, นิติบุคคลใช้ชื่อกิจการ
  String get displayName {
    final f = (firstName ?? '').trim();
    final l = (lastName ?? '').trim();
    if (l.isEmpty) return f;
    return '$f $l'.trim();
  }

  String get typeText => (type == 'juristic') ? 'นิติบุคคล' : 'บุคคลธรรมดา';

  bool get isActive => (status ?? '').toLowerCase() == 'active';

  /// ข้อความรวมสำหรับค้นหา (ชื่อ / เลขผู้เสียภาษี / เบอร์ / อีเมล / ธนาคาร)
  String get searchText => [
        displayName,
        taxId ?? '',
        phoneNumber ?? '',
        email ?? '',
        bankName ?? '',
        bankAccountNumber ?? '',
        address ?? '',
      ].join(' ').toLowerCase();
}
