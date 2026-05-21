import 'dart:convert';
import 'package:chaoperty_user/color.dart';
import 'package:chaoperty_user/screen/Screen_new/fitness_app_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:http/http.dart' as http;

import '../../../Constant/Myconstant.dart';
import '../../../Model/GetCustomer_Model.dart';
import '../../../Model/GetInvoice_Model.dart';
import '../../../Model/GetTeNant_Model.dart';

import '../../../main.dart';
import '../../loginscreen.dart';
import '../fitness_app_theme.dart';

class WorkoutView extends StatelessWidget {
  final AnimationController animationController;
  final Animation<double> animation;
  final List<CustomerModel> customerModel;
  final List<TeNantModel> teNantModel;
  final List<InvoiceModel> invoiceModels;
  final String? cuslang;

  const WorkoutView({
    Key? key,
    required this.animationController,
    required this.animation,
    required this.customerModel,
    required this.cuslang,
    required this.teNantModel,
    required this.invoiceModels,
  }) : super(key: key);

  bool get _isEN => cuslang == 'EN';

  @override
  Widget build(BuildContext context) {
    final hasData = customerModel.isNotEmpty;
    final cm = hasData ? customerModel.first : null;

    return AnimatedBuilder(
      animation: animationController,
      builder: (_, __) => FadeTransition(
        opacity: animation,
        child: Transform.translate(
          offset: Offset(0, 30 * (1 - animation.value)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    offset: const Offset(0, 4),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row (Title + Edit Button)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: HexColor(
                                    "#F3F4F6"), // Light grey bg for icon
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.person_outline_rounded,
                                  color: HexColor("#4F46E5"), size: 22),
                            ),
                            const SizedBox(width: 14),
                            Text(
                              _isEN ? 'My Profile' : 'ข้อมูลส่วนตัว',
                              style: TextStyle(
                                fontFamily: 'Prompt',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: FitnessAppTheme.darkerText,
                              ),
                            ),
                          ],
                        ),
                        // Edit Button (Minimal)
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(50),
                            onTap: () => _showEditDialog(context),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                _isEN ? 'Edit' : 'แก้ไข',
                                style: TextStyle(
                                  fontFamily: 'Prompt',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      HexColor("#4F46E5"), // Brand color text
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    hasData
                        ? _WhiteInfoGrid(
                            cm: cm!,
                            teNantCount: teNantModel.length,
                            isEN: _isEN,
                            onPrivacyTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const Privacy_Policy(
                                  Url:
                                      'https://chaoperties.com/chao_api/Awaitdownload/Privacy_Policy.pdf',
                                  title: ' เช่าเพอร์ตี้ Privacy Policy',
                                ),
                              ),
                            ),
                          )
                        : _InfoSkeleton(isEN: _isEN),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final initialUser = prefs.getString('UsernameUSer') ?? '';
    final initialPass = prefs.getString('pass_word') ?? '';

    final user = TextEditingController(text: initialUser);
    final pass = TextEditingController(text: initialPass);
    final isSaving = ValueNotifier<bool>(false);
    bool obscure = true;

    String? validate() {
      if (user.text.trim().isEmpty) {
        return _isEN ? 'Username is required' : 'กรุณากรอกชื่อผู้ใช้';
      }
      if (pass.text.length < 6) {
        return _isEN
            ? 'Password must be at least 6 chars'
            : 'รหัสผ่านอย่างน้อย 6 ตัวอักษร';
      }
      if (user.text == initialUser && pass.text == initialPass) {
        return _isEN ? 'Nothing changed' : 'ไม่มีการเปลี่ยนแปลง';
      }
      return null;
    }

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Center(
              child: Text(
                _isEN ? 'Edit Profile' : 'แก้ไขข้อมูล',
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Prompt',
                ),
              ),
            ),
            content: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _FieldRow(
                    label: _isEN ? 'Username' : 'ชื่อผู้ใช้',
                    child: TextFormField(
                      controller: user,
                      cursorColor: HexColor("#4F46E5"),
                      style: const TextStyle(
                          fontFamily: 'Prompt', color: Colors.black87),
                      decoration: _inputDecoration(
                          hint: _isEN ? 'Enter username' : 'กรอกชื่อผู้ใช้',
                          icon: Icons.person_outline),
                      textInputAction: TextInputAction.next,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _FieldRow(
                    label: _isEN ? 'Password' : 'รหัสผ่าน',
                    child: TextFormField(
                      controller: pass,
                      cursorColor: HexColor("#4F46E5"),
                      style: const TextStyle(
                          fontFamily: 'Prompt', color: Colors.black87),
                      obscureText: obscure,
                      decoration: _inputDecoration(
                              hint: _isEN ? 'Enter password' : 'กรอกรหัสผ่าน',
                              icon: Icons.lock_outline)
                          .copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                              obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.grey),
                          onPressed: () => setState(() => obscure = !obscure),
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (validate() != null &&
                      (user.text != initialUser || pass.text != initialPass))
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              size: 18, color: Colors.orange),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              validate()!,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Prompt'),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        foregroundColor: Colors.grey[600],
                      ),
                      child: Text(_isEN ? 'Cancel' : 'ยกเลิก',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Prompt')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ValueListenableBuilder<bool>(
                      valueListenable: isSaving,
                      builder: (_, saving, __) {
                        final disabled = saving || validate() != null;
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: HexColor("#4F46E5"),
                            disabledBackgroundColor:
                                HexColor("#4F46E5").withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: disabled
                              ? null
                              : () async {
                                  isSaving.value = true;
                                  final ser = prefs.getString('ser') ?? '';
                                  final url = Uri.parse(
                                    '${MyConstant().domain_chao}'
                                    '/U_user_Edit.php?isAdd=true&editser=$ser'
                                    '&edituser=${Uri.encodeComponent(user.text)}'
                                    '&editpass=${Uri.encodeComponent(pass.text)}',
                                  );
                                  try {
                                    final resp = await http.get(url);
                                    final body = json.decode(resp.body);
                                    if (body.toString() == 'true') {
                                      await prefs.clear();
                                      if (context.mounted) {
                                        Navigator.of(context)
                                            .pushAndRemoveUntil(
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  const LoginScreen()),
                                          (_) => false,
                                        );
                                      }
                                    } else {
                                      _toast(
                                          context,
                                          _isEN
                                              ? 'Update failed'
                                              : 'แก้ไขไม่สำเร็จ');
                                    }
                                  } catch (_) {
                                    _toast(
                                        context,
                                        _isEN
                                            ? 'Network error'
                                            : 'เครือข่ายมีปัญหา');
                                  } finally {
                                    isSaving.value = false;
                                  }
                                },
                          child: Text(
                              saving
                                  ? (_isEN ? 'Saving...' : 'กำลังบันทึก...')
                                  : (_isEN ? 'Update' : 'บันทึก'),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Prompt')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          );
        });
      },
    );
  }

  static InputDecoration _inputDecoration({String? hint, IconData? icon}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
            color: Colors.grey[400], fontSize: 14, fontFamily: 'Prompt'),
        prefixIcon: Icon(icon, color: HexColor("#4F46E5"), size: 20),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(width: 1.5, color: HexColor("#4F46E5")),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(width: 1, color: Colors.grey.shade200),
        ),
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(width: 1, color: Colors.grey.shade200),
        ),
      );

  static void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(msg, style: const TextStyle(fontFamily: 'Prompt')),
          backgroundColor: Colors.black87,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2)),
    );
  }
}

class _WhiteInfoGrid extends StatelessWidget {
  final CustomerModel cm;
  final int teNantCount;
  final bool isEN;
  final VoidCallback onPrivacyTap;

  const _WhiteInfoGrid({
    required this.cm,
    required this.teNantCount,
    required this.isEN,
    required this.onPrivacyTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _InfoItem(
                icon: Icons.card_membership_outlined,
                label: isEN ? 'Member ID' : 'รหัสสมาชิก',
                value: cm.custno?.trim() ?? '-',
              ),
            ),
            const SizedBox(width: 16),
            // Expanded(
            //   child: _InfoItem(
            //     icon: Icons.account_circle_outlined,
            //     label: isEN ? 'Username' : 'ชื่อผู้ใช้',
            //     value: cm.user_name?.trim() ?? '-',
            //   ),
            // ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _InfoItem(
                icon: Icons.account_circle_outlined,
                label: isEN ? 'Username' : 'ชื่อผู้ใช้',
                value: cm.cname?.trim() ?? '-',
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _InfoItem(
                icon: Icons.card_travel,
                label: isEN ? 'Line ID' : 'ไลน์',
                value: cm.displayname?.trim() ?? '-',
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _InfoItem(
                icon: Icons.email_outlined,
                label: isEN ? 'Email' : 'อีเมล',
                value: cm.email?.trim() ?? '-',
              ),
            ),
            // const SizedBox(width: 16),
            // Expanded(
            //   child: _InfoItem(
            //     icon: Icons.phone_android_rounded,
            //     label: isEN ? 'Tel' : 'เบอร์โทร',
            //     value: cm.tel?.trim() ?? '-',
            //   ),
            // ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _InfoItem(
                icon: Icons.location_on_outlined,
                label: isEN ? 'Address' : 'ที่อยู่',
                value: cm.addr1?.trim() ?? '-',
              ),
            ),
            // const SizedBox(width: 16),
            // Expanded(
            //   child: _InfoItem(
            //     icon: Icons.phone_android_rounded,
            //     label: isEN ? 'Tel' : 'เบอร์โทร',
            //     value: cm.tel?.trim() ?? '-',
            //   ),
            // ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _InfoItem(
                icon: Icons.badge_outlined,
                label: isEN ? 'TaxID' : 'เลขประจำตัวผู้เสียภาษี',
                value: cm.tax?.trim() ?? '-',
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _InfoItem(
                icon: Icons.phone_android_rounded,
                label: isEN ? 'Tel' : 'เบอร์โทร',
                value: cm.tel?.trim() ?? '-',
              ),
            ),
          ],
        ),
        // Row(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: [
        //     Expanded(
        //       child: _InfoItem(
        //         icon: Icons.logout_outlined,
        //         label: isEN ? 'Logout' : 'ออกจากระบบ',
        //         value: cm.tel?.trim() ?? '-',
        //       ),
        //     ),
        //     InkWell(
        //         onTap: () async {
        //           final preferences = await SharedPreferences.getInstance();
        //           preferences.clear();
        //           Navigator.pushAndRemoveUntil(
        //             context,
        //             MaterialPageRoute(
        //               builder: (context) => FitnessAppHomeScreen(),
        //             ),
        //             (route) => false,
        //           );
        //         },
        //         child: Icon(Icons.logout_outlined,
        //             color: Colors.red[400], size: 20)),
        //   ],
        // ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Row(
            //   children: [
            //     // Spacer(),
            //     // Icon(Icons.logout_outlined, color: Colors.grey[600], size: 18),
            //     // const SizedBox(width: 8),
            //     Text(
            //       isEN ? 'Logout' : 'ออกจากระบบ',
            //       style: TextStyle(
            //           fontFamily: 'Prompt',
            //           fontSize: 13,
            //           color: Colors.grey[600]),
            //     ),
            //   ],
            // ),
            Text(
              isEN ? 'Logout' : 'ออกจากระบบ',
              style: TextStyle(
                  fontFamily: 'Prompt', fontSize: 13, color: Colors.grey[600]),
            ),
            InkWell(
              onTap: onPrivacyTap,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: InkWell(
                    onTap: () async {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              child: Center(
                                child: Container(
                                  constraints:
                                      const BoxConstraints(maxWidth: 400),
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 10,
                                        offset: Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Container(
                                        padding: const EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                          color: FitnessAppTheme.nearlyDarkRed
                                              .withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.logout,
                                          size: 40,
                                          color: FitnessAppTheme.nearlyDarkRed,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      const Text(
                                        "Logout",
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: Font_.Fonts_T,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        isEN
                                            ? "Are you sure you want to logout?"
                                            : "คุณต้องการออกจากระบบหรือไม่?",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                          fontFamily: Font_.Fonts_T,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 25),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              style: TextButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  side: BorderSide(
                                                      color:
                                                          Colors.grey.shade300),
                                                ),
                                              ),
                                              child: Text(
                                                isEN ? "Cancel" : "ยกเลิก",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.grey.shade700,
                                                  fontFamily: Font_.Fonts_T,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 15),
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    FitnessAppTheme
                                                        .nearlyDarkRed,
                                                    const Color(0xFFFF6B6B),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: FitnessAppTheme
                                                        .nearlyDarkRed
                                                        .withOpacity(0.3),
                                                    blurRadius: 5,
                                                    offset: const Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  onTap: () async {
                                                    SharedPreferences
                                                        preferences =
                                                        await SharedPreferences
                                                            .getInstance();
                                                    await preferences.clear();
                                                    MaterialPageRoute route =
                                                        MaterialPageRoute(
                                                      builder: (context) =>
                                                          const LoginScreen(),
                                                    );
                                                    Navigator
                                                        .pushAndRemoveUntil(
                                                            context,
                                                            route,
                                                            (route) => false);
                                                  },
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 12),
                                                    child: Center(
                                                      child: Text(
                                                        isEN
                                                            ? "Logout"
                                                            : "ยืนยัน",
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.white,
                                                          fontFamily:
                                                              Font_.Fonts_T,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ));
                        },
                      );
                    },
                    child: Icon(Icons.logout_outlined,
                        color: Colors.red[400], size: 20)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Divider(color: Colors.black12, height: 1),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.description_outlined,
                    color: Colors.grey[600], size: 18),
                const SizedBox(width: 8),
                Text(
                  isEN ? 'Contracts' : 'สัญญาเช่า',
                  style: TextStyle(
                      fontFamily: 'Prompt',
                      fontSize: 13,
                      color: Colors.grey[600]),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                      color: HexColor("#4F46E5").withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    '$teNantCount',
                    style: TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: HexColor("#4F46E5")),
                  ),
                )
              ],
            ),
            InkWell(
              onTap: onPrivacyTap,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: Text(
                  isEN ? 'Privacy Policy' : 'นโยบายความเป็นส่วนตัว',
                  style: TextStyle(
                    fontFamily: 'Prompt',
                    fontSize: 12,
                    color: Colors.grey[500],
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isHighlight;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: HexColor("#4F46E5"), size: 20), // Brand color icon
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Prompt',
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Prompt',
                  fontSize: 14,
                  color: isHighlight ? HexColor("#F59E0B") : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoSkeleton extends StatelessWidget {
  final bool isEN;
  const _InfoSkeleton({required this.isEN});

  @override
  Widget build(BuildContext context) {
    Widget bar(double width) => Container(
          width: width,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
        );

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: bar(double.infinity)),
            const SizedBox(width: 16),
            Expanded(child: bar(double.infinity)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: bar(double.infinity)),
            const SizedBox(width: 16),
            Expanded(child: bar(double.infinity)),
          ],
        ),
      ],
    );
  }
}

class _FieldRow extends StatelessWidget {
  final String label;
  final Widget child;
  const _FieldRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black87,
                  fontFamily: 'Prompt')),
        ),
        child,
      ],
    );
  }
}

class Privacy_Policy extends StatefulWidget {
  final String title;
  final String Url;
  const Privacy_Policy({super.key, required this.title, required this.Url});

  @override
  State<Privacy_Policy> createState() => _Privacy_PolicyState();
}

class _Privacy_PolicyState extends State<Privacy_Policy> {
  final _key = GlobalKey<SfPdfViewerState>();
  final _controller = PdfViewerController();
  double _zoom = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: Colors.grey[200], height: 1)),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black87, size: 20),
        ),
        centerTitle: true,
        title: Text(widget.title,
            style: const TextStyle(
                fontFamily: 'Prompt', fontSize: 18, color: Colors.black87)),
        actions: [
          IconButton(
            tooltip: 'Zoom in',
            icon: const Icon(Icons.zoom_in, color: Colors.black54),
            onPressed: () => setState(() {
              _zoom = (_zoom + 0.25).clamp(1.0, 3.0);
              _controller.zoomLevel = _zoom;
            }),
          ),
          IconButton(
            tooltip: 'Zoom out',
            icon: const Icon(Icons.zoom_out, color: Colors.black54),
            onPressed: () => setState(() {
              _zoom = (_zoom - 0.25).clamp(1.0, 3.0);
              _controller.zoomLevel = _zoom;
            }),
          ),
        ],
      ),
      body: SfPdfViewer.network(
        widget.Url,
        key: _key,
        controller: _controller,
        enableDocumentLinkAnnotation: false,
        canShowScrollHead: false,
        canShowScrollStatus: false,
        pageLayoutMode: PdfPageLayoutMode.continuous,
        enableDoubleTapZooming: true,
      ),
    );
  }
}
