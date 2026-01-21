import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class DashboardAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final VoidCallback onLogout;

  const DashboardAppBarWidget({
    super.key,
    required this.userName,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
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
      actions: [
        IconButton(
          icon: const Icon(Icons.sort, color: Colors.black),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.add, color: Colors.black),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
