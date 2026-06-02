import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ReportColors {
  static const navyDeep = Color(0xFF0A1628);
  static const navyDark = Color(0xFF0F1A2E);
  static const navy = Color(0xFF1B2A4A);
  static const navyMid = Color(0xFF243356);
  static const brown = Color(0xFF8B5E3C);
  static const brownLight = Color(0xFFA0703F);
  static const cream = Color(0xFFF8F6F2);
  static const muted = Color(0xFF7B92BB);
  static const green = Color(0xFF2ECC71);
  static const amber = Color(0xFFF59E0B);
  static const indigo = Color(0xFF6366F1);
}

class ReportGradientBackground extends StatelessWidget {
  final Widget child;

  const ReportGradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ReportColors.navyDark,
            ReportColors.navy,
            Color(0xFF1C3265),
          ],
        ),
      ),
      child: child,
    );
  }
}

class ReportGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  const ReportGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.045),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: child,
    );
  }
}

class ReportStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String trend;
  final Color trendColor;

  const ReportStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.trend,
    required this.trendColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ReportGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: ReportColors.muted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(
                  color: ReportColors.cream,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              trend,
              style: TextStyle(
                color: trendColor,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RevenueTrendChart extends StatelessWidget {
  const RevenueTrendChart({super.key});

  @override
  Widget build(BuildContext context) {
    const thisWeek = [1200.0, 1850.0, 1430.0, 2100.0, 2450.0, 3200.0, 2800.0];
    const lastWeek = [900.0, 1400.0, 1600.0, 1800.0, 2000.0, 2600.0, 2200.0];

    return ReportGlassCard(
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Revenue Trend',
                style: TextStyle(
                  color: ReportColors.cream,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              _LegendRow(),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 175,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 3600,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      interval: 800,
                      getTitlesWidget: (value, meta) {
                        if (value == 0 || value == 800 || value == 1600 || value == 3200) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              color: ReportColors.muted,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        final index = value.toInt();
                        if (index < 0 || index >= days.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            days[index],
                            style: const TextStyle(
                              color: ReportColors.muted,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      thisWeek.length,
                      (index) => FlSpot(index.toDouble(), thisWeek[index]),
                    ),
                    isCurved: true,
                    barWidth: 4,
                    color: ReportColors.green,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                  ),
                  LineChartBarData(
                    spots: List.generate(
                      lastWeek.length,
                      (index) => FlSpot(index.toDouble(), lastWeek[index]),
                    ),
                    isCurved: true,
                    barWidth: 3,
                    color: ReportColors.muted,
                    dotData: const FlDotData(show: false),
                    dashArray: [8, 8],
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _LegendDot(color: ReportColors.green, label: 'This week'),
        SizedBox(width: 14),
        _LegendDot(color: ReportColors.muted, label: 'Last week'),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 7),
        Text(
          label,
          style: const TextStyle(
            color: ReportColors.muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class SalesByCategoryCard extends StatelessWidget {
  const SalesByCategoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final data = [
      _CategoryItem('Espresso', 35, ReportColors.brownLight),
      _CategoryItem('Latte', 28, ReportColors.green),
      _CategoryItem('Cappuccino', 20, ReportColors.amber),
      _CategoryItem('Others', 17, ReportColors.indigo),
    ];

    return ReportGlassCard(
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sales by Category',
            style: TextStyle(
              color: ReportColors.cream,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                width: 145,
                height: 145,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 38,
                    sections: data
                        .map(
                          (item) => PieChartSectionData(
                            value: item.value.toDouble(),
                            color: item.color,
                            radius: 32,
                            showTitle: false,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: data
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: item.color,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: const TextStyle(
                                    color: ReportColors.muted,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                '${item.value}%',
                                style: const TextStyle(
                                  color: ReportColors.cream,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BestSellingCard extends StatelessWidget {
  const BestSellingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _BestItem(1, 'Café Latte', '\$907.20', 0.29, ReportColors.amber),
      _BestItem(2, 'Espresso', '\$497.00', 0.22, ReportColors.green),
      _BestItem(3, 'Cappuccino', '\$531.00', 0.18, ReportColors.brownLight),
    ];

    return ReportGlassCard(
      margin: const EdgeInsets.only(top: 16, bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Best Selling',
            style: TextStyle(
              color: ReportColors.cream,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Row(
                children: [
                  SizedBox(
                    width: 44,
                    child: Text(
                      '#${item.rank}',
                      style: TextStyle(
                        color: item.color,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.name,
                                style: const TextStyle(
                                  color: ReportColors.cream,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Text(
                              item.revenue,
                              style: TextStyle(
                                color: item.color,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: item.progress,
                            minHeight: 5,
                            color: item.color,
                            backgroundColor: Colors.white.withOpacity(0.08),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryItem {
  final String name;
  final int value;
  final Color color;

  const _CategoryItem(this.name, this.value, this.color);
}

class _BestItem {
  final int rank;
  final String name;
  final String revenue;
  final double progress;
  final Color color;

  const _BestItem(this.rank, this.name, this.revenue, this.progress, this.color);
}
