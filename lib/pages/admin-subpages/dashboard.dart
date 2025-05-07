import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pos_desktop/db/database_helper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

//providers
import 'package:provider/provider.dart';
import 'package:pos_desktop/podos/category.dart';

class TotalSalesPage extends StatefulWidget {
  const TotalSalesPage({super.key});

  @override
  _TotalSalesPageState createState() => _TotalSalesPageState();
}

class _TotalSalesPageState extends State<TotalSalesPage> {
  double totalSales = 0.0;
  int totalOrders = 0;
  double salesLast30Days = 0.0;
  int totalProductsSold = 0;

  List<Map<String, dynamic>> salesData = [];
  List<String> labels = [];
  List<Map<String, dynamic>> topProductsData = [];

  String selectedTimeframe = "Last Month"; // Default selection

  final DatabaseHelper _dbHelper = DatabaseHelper();
  int selectedCategoryIndex = 1;

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchSalesData(selectedCategoryIndex).then((data) {
      setState(() {
        salesData = data;
      });
    });
  }

  Future<List<Map<String, dynamic>>> fetchSalesData(int categoryIndex) async {
    if (selectedTimeframe == "Last Month") {
      return await _dbHelper.fetchMonthlySales();
    } else if (selectedTimeframe == "Daily Sales") {
      return await _dbHelper.fetchDailySales();
    } else if (selectedTimeframe == "Top Products") {
      return await _dbHelper.fetchTopProducts(categoryIndex);
    } else {
      return [];
    }
  }

  Future<void> fetchData() async {
    final stats = await _dbHelper.fetchDashboardStats();
    setState(() {
      totalSales = stats['totalSales'];
      totalOrders = stats['totalOrders'];
      salesLast30Days = stats['salesLast30Days'];
      totalProductsSold = stats['totalProductsSold'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      backgroundColor: Color(0xFFd7bda6),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TOTAL SALES CONTAINER
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFFAB7843),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.grey.shade300, blurRadius: 5),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: screenHeight * (50 / 1080),
                          width: screenWidth * (50 / 1920),
                          decoration: const BoxDecoration(
                            color: Color(0xFF6d3914),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.bar_chart,
                            color: Color(0xFFd7bda6),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              " TOTAL SALES",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: screenWidth * (17 / 1920),
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD7BDA6),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "Rs ${totalSales.toStringAsFixed(0)}",
                              style: GoogleFonts.montserrat(
                                fontSize: screenWidth * (28 / 1920),
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6d3914),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // TIMEFRAME BUTTONS
                  Divider(
                    color: Color(0xFF6d3914).withOpacity(0.4),
                    thickness: 2,
                    indent: 10,
                    endIndent: 10,
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // LAST MONTH BUTTON
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedTimeframe = "Last Month";
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(screenWidth * (17 / 1920)),
                          backgroundColor:
                              selectedTimeframe == "Last Month"
                                  ? Color(0xFF6d3914)
                                  : Color(0xFF6d3914).withOpacity(0.4),
                        ),
                        child: Text(
                          "Last Month",
                          style: GoogleFonts.plusJakartaSans(
                            color: Color(0xFFd7bda6),
                          ),
                        ),
                      ),

                      // DAILY SALES BUTTON
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedTimeframe = "Daily Sales";
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(screenWidth * (17 / 1920)),
                          backgroundColor:
                              selectedTimeframe == "Daily Sales"
                                  ? Color(0xFF6d3914)
                                  : Color(0xFF6d3914).withOpacity(0.4),
                        ),
                        child: Text(
                          "Daily Sales",
                          style: GoogleFonts.plusJakartaSans(
                            color: Color(0xFFd7bda6),
                          ),
                        ),
                      ),

                      // TOP PRODUCTS BUTTON
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedTimeframe = "Top Products";
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(screenWidth * (17 / 1920)),
                          backgroundColor:
                              selectedTimeframe == "Top Products"
                                  ? Color(0xFF6d3914)
                                  : Color(0xFF6d3914).withOpacity(0.4),
                        ),
                        child: Text(
                          "Top Products",
                          style: GoogleFonts.plusJakartaSans(
                            color: Color(0xFFd7bda6),
                          ),
                        ),
                      ),

                      // @NEW
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        transitionBuilder: (
                          Widget child,
                          Animation<double> animation,
                        ) {
                          final offsetAnimation = Tween<Offset>(
                            begin: Offset(-0.3, 0),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOut,
                            ),
                          );

                          return SlideTransition(
                            position: offsetAnimation,
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                        child:
                            selectedTimeframe == "Top Products"
                                ? Container(
                                  key: ValueKey("TopProductsDropdown"),
                                  width: screenWidth * (205 / 1920),
                                  height: screenHeight * (45 / 1080),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * (20 / 1920),
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF6d3914),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<int>(
                                      value: selectedCategoryIndex - 1,
                                      dropdownColor: Color(0xFF6d3914),
                                      iconEnabledColor: Color(0xFFD7BDA6),
                                      items:
                                          categoryProvider.categories
                                              .asMap()
                                              .entries
                                              .map((entry) {
                                                final index = entry.key;
                                                final category = entry.value;
                                                return DropdownMenuItem<int>(
                                                  value: index,
                                                  child: Text(
                                                    category.name,
                                                    style:
                                                        GoogleFonts.plusJakartaSans(
                                                          color: Color(
                                                            0xFFD7BDA6,
                                                          ),
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize:
                                                              screenWidth *
                                                              (20 / 1920),
                                                        ),
                                                  ),
                                                );
                                              })
                                              .toList(),
                                      onChanged: (newIndex) {
                                        if (newIndex != null) {
                                          setState(() {
                                            selectedCategoryIndex =
                                                newIndex + 1;
                                          });
                                          fetchSalesData(newIndex).then((data) {
                                            setState(() {
                                              salesData = data;
                                            });
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                )
                                : SizedBox(
                                  key: ValueKey("EmptyDropdownSlot"),
                                  width: screenWidth * (200 / 1920),
                                ),
                      ),
                    ],
                  ),

                  SizedBox(height: screenHeight * (50 / 1080)), //@CHANGEME
                  // BAR CHART WITH FUTURE BUILDER
                  Container(
                    height: screenHeight * (360 / 1080),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFFD7BDA6),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Color(0x4c2b08), blurRadius: 5),
                      ],
                    ),
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: fetchSalesData(selectedCategoryIndex),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              "Error loading data: ${snapshot.error}",
                            ),
                          );
                        }

                        salesData = snapshot.data ?? [];

                        if (selectedTimeframe == "Top Products") {
                          if (salesData.isEmpty) {
                            return const Center(
                              child: Text("No sales data available today."),
                            );
                          }

                          return _buildTopProductsChart(salesData);
                        } else {
                          if (salesData.isEmpty) {
                            if (selectedTimeframe == "Last Month") {
                              // Create empty data for 4 weeks
                              salesData = List.generate(
                                4,
                                (index) => {
                                  'week_name': 'Week ${index + 1}',
                                  'total_sales': 0.0,
                                },
                              );
                            } else {
                              // Create empty data for 7 days
                              salesData = List.generate(
                                7,
                                (index) => {
                                  'day_name':
                                      [
                                        'Sunday',
                                        'Monday',
                                        'Tuesday',
                                        'Wednesday',
                                        'Thursday',
                                        'Friday',
                                        'Saturday',
                                      ][index],
                                  'total_sales': 0.0,
                                },
                              );
                            }
                          }
                          return _buildSalesChart();
                        }
                      },
                    ),
                  ),
                  Divider(
                    color: Color(0xFF6d3914).withOpacity(0.4),
                    thickness: 2,
                    indent: 10,
                    endIndent: 10,
                  ),
                  const SizedBox(height: 10),
                  // STAT CARDS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatCard(
                        "Total Sales",
                        "Rs ${totalSales.toStringAsFixed(0)}",
                        Icons.attach_money,
                        Colors.brown.shade100,
                        Colors.brown.shade900,
                        screenWidth,
                        screenHeight,
                      ),
                      _buildStatCard(
                        "Total Orders",
                        "${totalOrders.toStringAsFixed(0)}",
                        Icons.shopping_cart,
                        Colors.orange,
                        Colors.brown.shade800,
                        screenWidth,
                        screenHeight,
                      ),
                      _buildStatCard(
                        "Sales of Last 30 Days",
                        "Rs ${salesLast30Days.toStringAsFixed(0)}",
                        Icons.receipt,
                        Colors.red,
                        Colors.brown.shade700,
                        screenWidth,
                        screenHeight,
                      ),
                      _buildStatCard(
                        "Total Products Sold",
                        "${totalProductsSold.toStringAsFixed(0)}",
                        Icons.shopping_bag,
                        Colors.green,
                        Colors.brown.shade600,
                        screenWidth,
                        screenHeight,
                      ),
                    ],
                  ),

                  SizedBox(height: screenHeight * (200 / 1080)),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SvgPicture.asset(
              'assets/images/wave.svg',
              fit: BoxFit.cover,
              height: MediaQuery.of(context).size.height * (300 / 1080),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesChart() {
    // Generate labels based on the selected timeframe
    labels =
        selectedTimeframe == "Last Month"
            ? salesData.map<String>((e) => e['week_name'].toString()).toList()
            : salesData.map<String>((e) => e['day_name'].toString()).toList();

    return BarChart(
      BarChartData(
        maxY: _calculateMaxY(),
        minY: 0,
        barGroups: _getBarGroups(),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            axisNameSize: 60,
            axisNameWidget: Padding(
              padding: EdgeInsets.only(right: 60),
              child: Text(
                "Sales Count",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4c2b08),
                ),
              ),
            ),
            sideTitles: SideTitles(showTitles: true, reservedSize: 50),
          ),
          bottomTitles: AxisTitles(
            axisNameWidget: Text(
              selectedTimeframe == "Last Month" ? "Weeks" : "Last 7 Days",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4c2b08),
              ),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value.toInt() >= 0 && value.toInt() < labels.length) {
                  double salesValue =
                      selectedTimeframe == "Daily Sales"
                          ? salesData[value.toInt()]['total_sales'] ?? 0.0
                          : selectedTimeframe == "Last Month"
                          ? salesData[value.toInt()]['total_sales']
                                  ?.toDouble() ??
                              0.0
                          : 0.0;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        labels[value.toInt()],
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                      if (selectedTimeframe == "Daily Sales" ||
                          selectedTimeframe == "Last Month")
                        Column(
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              "Rs ${salesValue.toStringAsFixed(0)}",
                              style: const TextStyle(
                                color: Color(0xFF6d3914),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
              reservedSize: 50,
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
      ),
    );
  }

  double calculateMaxYForTopProducts(List<Map<String, dynamic>> salesData) {
    final maxQuantity = salesData
        .map((e) => (e['quantity'] as num?)?.toDouble() ?? 0.0)
        .fold<double>(0.0, (prev, qty) => qty > prev ? qty : prev);

    final buffer = maxQuantity * 0.1;
    return (maxQuantity + buffer).ceilToDouble();
  }

  double calculateYIntervalForTopProducts(
    List<Map<String, dynamic>> salesData,
  ) {
    final maxY = calculateMaxYForTopProducts(salesData);
    final rawInterval = (maxY / 5).ceilToDouble();
    return rawInterval < 1.0 ? 1.0 : rawInterval;
  }

  Widget _buildTopProductsChart(List<Map<String, dynamic>> salesData) {
    // Build category data from dynamic salesData
    final Map<String, Map<String, double>> categoryData = {};

    for (var item in salesData) {
      final category = item['category'] as String;
      final quantity = (item['quantity'] as num?)?.toDouble() ?? 0.0;
      final totalPrice = (item['total_price'] as num?)?.toDouble() ?? 0.0;

      categoryData[category] = {
        'quantity': quantity,
        'total_price': totalPrice,
      };
    }

    // Sort by quantity
    final sortedCategories =
        categoryData.entries.toList()..sort(
          (a, b) => b.value['quantity']!.compareTo(a.value['quantity']!),
        );

    // Prepare chart data
    List<BarChartGroupData> barGroups = [];
    List<String> categoryLabels = [];

    for (int i = 0; i < sortedCategories.length; i++) {
      final entry = sortedCategories[i];
      categoryLabels.add(entry.key);

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: entry.value['quantity']!,
              color: _getCategoryColor(i),
              width: 20,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        maxY: calculateMaxYForTopProducts(salesData),
        minY: 0,
        barGroups: barGroups,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            axisNameSize: 50,
            axisNameWidget: const Padding(
              padding: EdgeInsets.only(right: 50.0),
              child: Column(
                children: [
                  Text(
                    'Quantity Sold',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4c2b08),
                    ),
                  ),
                ],
              ),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              interval: calculateYIntervalForTopProducts(salesData),
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            axisNameWidget: const Padding(
              padding: EdgeInsets.only(top: 1.0),
              child: Text(
                'Products',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4c2b08),
                ),
              ),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value.toInt() >= 0 &&
                    value.toInt() < categoryLabels.length) {
                  final category = categoryLabels[value.toInt()];
                  final price =
                      sortedCategories[value.toInt()].value['total_price']!
                          .toInt();

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        category,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rs $price',
                        style: const TextStyle(
                          color: Color(0xFF6d3914),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
      ),
    );
  }

  Color _getCategoryColor(int index) {
    return Color(0xFF6d3914);
  }

  double _calculateMaxY() {
    if (salesData.isEmpty) return 10;
    double maxSales = salesData
        .map((e) => e['total_sales'].toDouble())
        .reduce((a, b) => a > b ? a : b);
    if (maxSales <= 0) return 10;
    int exponent = maxSales.toInt().toString().length - 1;
    double roundFactor = pow(10, exponent).toDouble();
    return ((maxSales / roundFactor).ceil() * roundFactor).toDouble();
  }

  List<BarChartGroupData> _getBarGroups() {
    int totalBars = selectedTimeframe == "Daily Sales" ? 10 : salesData.length;

    return salesData.asMap().entries.map((entry) {
      int index = entry.key;
      double salesCount = entry.value['total_sales'].toDouble();

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: salesCount,
            color: salesCount == 0 ? Colors.grey.shade300 : Color(0xFF6d3914),
            width: (250 / totalBars).clamp(15, 25),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color iconColor,
    Color bgColor,
    double screenWidth,
    double screenHeight,
  ) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: screenWidth * (6 / 1920)),
        padding: EdgeInsets.all(screenWidth * (20 / 1920)),
        height: screenHeight * (120 / 1080),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(screenWidth * (12 / 1920)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: screenWidth * (5 / 1920),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: screenWidth * (50 / 1920),
              width: screenWidth * (50 / 1920),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: screenWidth * (28 / 1920),
              ),
            ),
            SizedBox(width: screenWidth * (12 / 1920)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: screenWidth * (18 / 1920),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFd7bda6),
                  ),
                ),
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: screenWidth * (13 / 1920),
                    color: const Color(0xDDd7bda6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
