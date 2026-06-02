import 'package:flutter/material.dart';

import '../../pages/dashboard/dashboard_page.dart';
import '../../pages/menu/menu_page.dart';
import '../../pages/report/report_page.dart';
import '../../pages/profile/profile_page.dart';
import '../../pages/shift/shift_page.dart';
import '../custom/report_widgets.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
  });

  void _goToPage(BuildContext context, int index) {
    if (index == currentIndex) return;

    final pages = [
      const DashboardPage(),
      const ShiftPage(),
      const MenuPage(),
      const ReportPage(),
      const ProfilePage(),
    ];

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => pages[index],
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(Icons.home_outlined, 'Home'),
      _NavItem(Icons.calendar_month_outlined, 'Shifts'),
      _NavItem(Icons.local_cafe_outlined, 'Menu'),
      _NavItem(Icons.bar_chart_rounded, 'Reports'),
      _NavItem(Icons.person_outline_rounded, 'Profile'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: ReportColors.navyDeep,
        border: Border(
          top: BorderSide(color: Color(0x163E5177)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final selected = index == currentIndex;
              final item = items[index];

              return Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () => _goToPage(context, index),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? ReportColors.brown.withOpacity(0.32)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          item.icon,
                          color: selected
                              ? ReportColors.brownLight
                              : ReportColors.muted,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: selected
                              ? ReportColors.brownLight
                              : ReportColors.muted,
                          fontSize: 11,
                          fontWeight: selected
                              ? FontWeight.w800
                              : FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  _NavItem(this.icon, this.label);
}
