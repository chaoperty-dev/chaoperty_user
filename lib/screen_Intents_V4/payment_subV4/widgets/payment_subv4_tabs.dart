import 'package:flutter/material.dart';

class PaymentSubV4Tabs extends StatelessWidget {
  const PaymentSubV4Tabs({
    Key? key,
    required this.selectedTab,
    required this.countPayable,
    required this.countAwaitingSlip,
    required this.countAwaitingVerify,
    required this.onTabSelected,
  }) : super(key: key);

  final int selectedTab;
  final int countPayable;
  final int countAwaitingSlip;
  final int countAwaitingVerify;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade50,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          _buildTab(
            index: 1,
            label: 'ที่ต้องชำระ',
            count: countPayable,
            badgeColor: Colors.red,
          ),
          _buildTab(
            index: 2,
            label: 'รอแนบหลักฐาน',
            count: countAwaitingSlip,
            badgeColor: Colors.orange,
          ),
          _buildTab(
            index: 3,
            label: 'รอระบบตรวจสอบ',
            count: countAwaitingVerify,
            badgeColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required int index,
    required String label,
    required int count,
    required MaterialColor badgeColor,
  }) {
    final isSelected = selectedTab == index;

    return Expanded(
      child: InkWell(
        onTap: () => onTabSelected(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.black87 : Colors.grey.shade500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: isSelected ? badgeColor.shade600 : badgeColor.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : badgeColor.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 2.5,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? badgeColor.shade600 : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
