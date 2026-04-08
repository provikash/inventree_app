import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:inventree_app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:inventree_app/features/parts/presentation/providers/part_provider.dart';
import 'package:inventree_app/features/stock/presentation/providers/stock_provider.dart';
import 'package:inventree_app/features/parts/presentation/screens/parts_screen.dart';
import 'package:inventree_app/features/stock/presentation/screens/stock_screen.dart';
import 'package:inventree_app/features/settings/presentation/screens/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    DashboardOverview(),
    PartsScreen(),
    StockScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            labelType: isWide
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.all,
            extended: isWide,
            leading: const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Icon(Icons.account_tree, size: 40, color: Colors.blue),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.category_outlined),
                selectedIcon: Icon(Icons.category),
                label: Text('Parts'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.inventory_2_outlined),
                selectedIcon: Icon(Icons.inventory_2),
                label: Text('Stock'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: _widgetOptions.elementAt(_selectedIndex)),
        ],
      ),
    );
  }
}

class DashboardOverview extends ConsumerWidget {
  const DashboardOverview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(dashboardStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('InvenTree Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Manual Refresh',
            onPressed: () {
              ref.invalidate(partsProvider);
              ref.invalidate(stockItemsProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(partsProvider);
          ref.invalidate(stockItemsProvider);
          await Future.wait([
            ref.read(partsProvider.future),
            ref.read(stockItemsProvider.future),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Welcome to InvenTree',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Chip(
                    avatar: Icon(Icons.timer_outlined, size: 16),
                    label: Text('Auto-refreshing (30s)'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildStatsGrid(context, stats),
              const SizedBox(height: 32),
              Text(
                'Stock Distribution by Category',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: _buildCategoryChart(stats.stockByCategory),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, DashboardStats stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 1200
            ? 4
            : (constraints.maxWidth > 800 ? 3 : 2);
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildDashboardCard(
              context,
              'Total Parts',
              '${stats.totalParts}',
              Icons.category,
              Colors.blue,
            ),
            _buildDashboardCard(
              context,
              'Stock Items',
              '${stats.totalStockItems}',
              Icons.inventory_2,
              Colors.green,
            ),
            _buildDashboardCard(
              context,
              'Low Stock',
              '${stats.lowStockCount}',
              Icons.warning_amber_rounded,
              Colors.orange,
            ),
            _buildDashboardCard(
              context,
              'System Status',
              'Online',
              Icons.check_circle_outline,
              Colors.teal,
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryChart(Map<String, int> categories) {
    if (categories.isEmpty) {
      return const Center(child: Text('No category data available'));
    }

    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];

    return PieChart(
      PieChartData(
        sectionsSpace: 4,
        centerSpaceRadius: 50,
        sections: categories.entries.toList().asMap().entries.map((entry) {
          final index = entry.key;
          final category = entry.value;
          return PieChartSectionData(
            value: category.value.toDouble(),
            title: '${category.key}\n${category.value}',
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            color: colors[index % colors.length],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
