import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/common/app_bottom_nav.dart';
import '../../widgets/custom/report_widgets.dart';
import '../../widgets/custom/sales_gauge_widget.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: ReportColors.navyDark,
        bottomNavigationBar: const AppBottomNav(currentIndex: 0),
        body: ReportGradientBackground(
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dashboard Café',
                            style: TextStyle(
                              color: ReportColors.cream,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Ringkasan performa hari ini',
                            style: TextStyle(
                              color: ReportColors.muted,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.09)),
                      ),
                      child: const Icon(Icons.notifications_none_rounded, color: ReportColors.muted),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Row(
                  children: [
                    ReportStatCard(
                      label: 'Penjualan',
                      value: '\$2,040',
                      trend: '+8%',
                      trendColor: ReportColors.green,
                    ),
                    SizedBox(width: 12),
                    ReportStatCard(
                      label: 'Transaksi',
                      value: '86',
                      trend: '+12%',
                      trendColor: ReportColors.brownLight,
                    ),
                    SizedBox(width: 12),
                    ReportStatCard(
                      label: 'Quantity',
                      value: '214',
                      trend: '+18%',
                      trendColor: ReportColors.indigo,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const SalesGaugeWidget(
                  initialProgress: 0.72,
                  title: 'Target Harian',
                  valueText: '\$2,040',
                  goalText: 'of \$2,850 goal',
                ),
                const SizedBox(height: 18),
                ReportGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Menu Terlaris',
                        style: TextStyle(
                          color: ReportColors.cream,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: ReportColors.brownLight.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(Icons.local_cafe_rounded, color: ReportColors.brownLight),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Café Latte',
                                  style: TextStyle(
                                    color: ReportColors.cream,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  '189 cup terjual minggu ini',
                                  style: TextStyle(
                                    color: ReportColors.muted,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Text(
                            '\$907.20',
                            style: TextStyle(
                              color: ReportColors.amber,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const RevenueTrendChart(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _DashboardShortcut(
                        icon: Icons.receipt_long_outlined,
                        title: 'Laporan',
                        subtitle: 'Detail sales',
                        onTap: () => Navigator.pushNamed(context, '/report'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DashboardShortcut(
                        icon: Icons.point_of_sale_outlined,
                        title: 'Transaksi',
                        subtitle: 'Input order',
                        onTap: () => Navigator.pushNamed(context, '/transaction'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _DashboardShortcut(
                        icon: Icons.calendar_month_outlined,
                        title: 'Shift',
                        subtitle: 'Jadwal barista',
                        onTap: () => Navigator.pushNamed(context, '/shift'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DashboardShortcut(
                        icon: Icons.inventory_2_outlined,
                        title: 'Stok',
                        subtitle: 'Bahan café',
                        onTap: () => Navigator.pushNamed(context, '/stock'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardShortcut extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DashboardShortcut({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: ReportGlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: ReportColors.muted, size: 30),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                color: ReportColors.cream,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: const TextStyle(
                color: ReportColors.muted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
