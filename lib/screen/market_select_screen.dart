import 'package:flutter/material.dart';
import '../Constant/Myconstant.dart';
import '../Model/GetC_regis_Model.dart';
import '../color.dart';
import 'Screen_new/fitness_app_theme.dart';

class MarketSelectScreen extends StatelessWidget {
  final List<c_regis_Model> markets;
  final Future<void> Function(c_regis_Model) onSelect;

  const MarketSelectScreen({
    super.key,
    required this.markets,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      color: FitnessAppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App bar area
            Container(
              color: FitnessAppTheme.white,
              padding: EdgeInsets.fromLTRB(16, topPad + 16, 16, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3F4F6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.store_mall_directory_outlined,
                        color: Color(0xFF4F46E5), size: 22),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'เลือกตลาด',
                        style: TextStyle(
                          fontFamily: Font_.Fonts_T,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          letterSpacing: 0.5,
                          color: FitnessAppTheme.darkerText,
                        ),
                      ),
                      Text(
                        'พบ ${markets.length} ตลาดในบัญชีของคุณ',
                        style: const TextStyle(
                          fontFamily: Font_.Fonts_T,
                          fontSize: 12,
                          color: FitnessAppTheme.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                itemCount: markets.length,
                itemBuilder: (ctx, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _MarketCard(
                    model: markets[i],
                    onTap: () => onSelect(markets[i]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MarketCard extends StatelessWidget {
  final c_regis_Model model;
  final VoidCallback onTap;

  const _MarketCard({required this.model, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final foder = (model.rentalFoder ?? '').trim();
    final logoFile = (model.rentalLogo ?? '').trim();
    final logoUrl = (foder.isNotEmpty && logoFile.isNotEmpty)
        ? '${MyConstant().domain_chao}/files/$foder/logo/$logoFile'
        : '';

    final name = model.pn ?? '-';
    final initChar = name.isNotEmpty ? name[0] : '?';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: FitnessAppTheme.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: FitnessAppTheme.grey.withValues(alpha: 0.1),
              offset: const Offset(0, 4),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Logo circle
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: FitnessAppTheme.nearlyWhite,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: FitnessAppTheme.grey.withValues(alpha: 0.2),
                    offset: const Offset(1, 1),
                    blurRadius: 6,
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: logoUrl.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        logoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _avatarText(initChar),
                      ),
                    )
                  : _avatarText(initChar),
            ),
            const SizedBox(width: 16),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontFamily: Font_.Fonts_T,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: FitnessAppTheme.darkerText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _row(Icons.badge_outlined,
                      'รหัสลูกค้า : ${model.custno ?? '-'}'),
                  if ((model.rentalIdCard ?? '').isNotEmpty) ...[
                    const SizedBox(height: 3),
                    _row(Icons.storefront_outlined,
                        'เลขที่ห้อง : ${model.rentalIdCard}'),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: FitnessAppTheme.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatarText(String char) => Center(
        child: Text(
          char,
          style: const TextStyle(
            fontFamily: Font_.Fonts_T,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: FitnessAppTheme.orange,
          ),
        ),
      );

  Widget _row(IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 13, color: FitnessAppTheme.grey),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              fontFamily: Font_.Fonts_T,
              fontSize: 12.5,
              color: FitnessAppTheme.grey,
            ),
          ),
        ],
      );
}
