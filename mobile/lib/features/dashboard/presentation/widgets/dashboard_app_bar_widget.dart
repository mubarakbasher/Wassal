import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../vouchers/presentation/pages/generate_voucher_page.dart';

class DashboardAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final VoidCallback onLogout;
  final VoidCallback? onProfileTap;
  final VoidCallback? onSelectModePressed;
  final bool showSelectOption;

  const DashboardAppBarWidget({
    super.key,
    required this.userName,
    required this.onLogout,
    this.onProfileTap,
    this.onSelectModePressed,
    this.showSelectOption = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: GestureDetector(
          onTap: onProfileTap,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFFFEAEB), // Light pink background
                radius: 20,
                child: Icon(Icons.person, color: AppColors.primary),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    border: Border.fromBorderSide(
                      BorderSide(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.black),
          offset: const Offset(0, 45),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (value) {
            if (value == 'generate') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GenerateVoucherPage()),
              );
            } else if (value == 'select') {
              onSelectModePressed?.call();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem<String>(
              value: 'generate',
              child: Row(
                children: [
                  Icon(Icons.add_rounded, color: AppColors.primary),
                  SizedBox(width: 12),
                  Text('Generate Voucher'),
                ],
              ),
            ),
            if (showSelectOption)
              const PopupMenuItem<String>(
                value: 'select',
                child: Row(
                  children: [
                    Icon(Icons.checklist_rounded, color: AppColors.primary),
                    SizedBox(width: 12),
                    Text('Select Vouchers'),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
