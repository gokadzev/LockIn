import 'package:flutter/material.dart';
import 'package:lockin/constants/app_constants.dart';
import 'package:lockin/widgets/lockin_card.dart';

class LockinDashboardCard extends StatelessWidget {
  const LockinDashboardCard({
    super.key,
    required this.title,
    required this.items,
    this.elevation = 4,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.all(AppConstants.defaultPadding),
    this.trailing,
  });
  final String title;
  final List<DashboardItem> items;
  final double elevation;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return LockinCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.dashboard, color: Colors.white, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    height: 1.15,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: item.onTap,
                child: Row(
                  children: [
                    Icon(item.icon, color: Colors.white, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.text,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardItem {
  const DashboardItem({required this.icon, required this.text, this.onTap});
  final IconData icon;
  final String text;
  final VoidCallback? onTap;
}
