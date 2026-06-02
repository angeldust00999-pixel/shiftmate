import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/common/app_bottom_nav.dart';
import '../../widgets/custom/report_widgets.dart';
import '../../widgets/custom/sales_gauge_widget.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: ReportColors.navyDark,
        bottomNavigationBar: const AppBottomNav(currentIndex: 3),
        body: ReportGradientBackground(
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sales Report',
                            style: TextStyle(
                              color: ReportColors.cream,
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.0,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'May 2026 · Weekly overview',
                            style: TextStyle(
                              color: ReportColors.muted,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => Navigator.pushNamed(context, '/stock'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white.withOpacity(0.09)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 19, color: ReportColors.muted),
                            SizedBox(width: 8),
                            Text(
                              'Stock',
                              style: TextStyle(
                                color: ReportColors.muted,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                const Row(
                  children: [
                    ReportStatCard(
                      label: 'Revenue',
                      value: '\$14,280',
                      trend: '+18%',
                      trendColor: ReportColors.green,
                    ),
                    SizedBox(width: 12),
                    ReportStatCard(
                      label: 'Orders',
                      value: '642',
                      trend: '+12%',
                      trendColor: ReportColors.brownLight,
                    ),
                    SizedBox(width: 12),
                    ReportStatCard(
                      label: 'Avg Daily',
                      value: '\$2,040',
                      trend: '+8%',
                      trendColor: ReportColors.indigo,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const SalesGaugeWidget(
                  initialProgress: 0.78,
                  title: 'Weekly Target',
                  valueText: '\$14,280',
                  goalText: 'of \$18,300 goal',
                ),
                const RevenueTrendChart(),
                const SalesByCategoryCard(),
                const BestSellingCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
