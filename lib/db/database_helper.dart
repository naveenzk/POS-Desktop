import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:pos_desktop/podos/receiptitem.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:flutter/services.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();

    return _database!;
  }

  // Loading Database
  Future<Database> _initDatabase() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    Directory documentsDir = await getApplicationDocumentsDirectory();
    String databasesPath = join(documentsDir.path, 'pos_desktop');

    String path = join(databasesPath, 'database.db');

    try {
      if (!await databaseExists(path)) {
        await Directory(dirname(path)).create(recursive: true);
        ByteData data = await rootBundle.load(
          'assets/ImtiazBakers_database.db',
        );
        List<int> bytes = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        );
        await File(path).writeAsBytes(bytes, flush: true);
      }
    } catch (e) {
      print("Error copying database: $e");
    }

    return await openDatabase(path);
  }

  //Admin Login
  Future<Map<String, String>?> fetchAdminCredentials() async {
    final db = await database;
    final result = await db.query(
      'admin',
      columns: ['username', 'password'],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return {
        'username': result[0]['username'].toString(),
        'password': result[0]['password'].toString(),
      };
    } else {
      return null;
    }
  }

  //fetch items based on categories
  Future<List<Map<String, dynamic>>> fetchMenuItemsByCategory(
    int categoryId,
  ) async {
    final db = await database;
    return await db.rawQuery(
      '''
    SELECT 
      menu.product_id, 
      COALESCE(menu.product_name, ' ') AS product_name, 
      COALESCE(menu.price, 0) AS price, 
      menu.category_id,
      categories.category_name,
      COALESCE(menu.image_path, ' ') AS image_path
    FROM menu
    INNER JOIN categories ON menu.category_id = categories.category_id
    WHERE menu.category_id = ?
    ORDER BY menu.product_id
    ''',
      [categoryId],
    );
  }

  //Used to show products in managesproducts page
  Future<List<Map<String, dynamic>>> fetchMenuItems() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT menu.product_id, COALESCE(menu.product_name, ' ') AS product_name, COALESCE(menu.price, 0) AS price, categories.category_name, COALESCE(menu.image_path, ' ') AS image_path
      FROM menu
      INNER JOIN categories ON menu.category_id = categories.category_id
      ORDER BY categories.category_id, menu.product_id
    ''');
  }

  //Used to edit products in manageproducts page
  Future<int> updateItem(
    int productId,
    String name,
    String price,
    String image,
  ) async {
    final db = await database;

    // Build the map dynamically
    final Map<String, dynamic> updateData = {
      'product_name': name,
      'price': price,
    };

    // Only include image_path if the new image is not empty
    if (image.isNotEmpty) {
      updateData['image_path'] = image;
    }

    return await db.update(
      'menu',
      updateData,
      where: 'product_id = ?',
      whereArgs: [productId],
    );
  }

  Future<String> saveImageToAppDir(String imagePath) async {
    final originalFile = File(imagePath);

    // Get the documents directory
    final dir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(path.join(dir.path, 'pos_desktop', 'images'));

    // Create directory if it doesn't exist
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    // Create new image file path
    final fileName = path.basename(imagePath); // Get original file name
    final newImagePath = path.join(imagesDir.path, fileName);

    // Copy file to new location
    await originalFile.copy(newImagePath);

    return newImagePath;
  }

  //Following functions are used in dashboard page

  Future<List<Map<String, dynamic>>> fetchMonthlySales() async {
    final db = await database;
    final result = await db.rawQuery('''
    WITH Last4Weeks AS (
      SELECT date('now', '-35 days') AS start_date, 'Week 1' AS week_name UNION ALL
      SELECT date('now', '-28 days'), 'Week 2' UNION ALL
      SELECT date('now', '-21 days'), 'Week 3' UNION ALL
      SELECT date('now', '-14 days'), 'Week 4'
    )
    SELECT 
      l.week_name,
      COALESCE(SUM(o.total_amount), 0) AS total_sales
    FROM Last4Weeks l
    LEFT JOIN orders o ON date(o.order_date) >= l.start_date 
                        AND date(o.order_date) < date(l.start_date, '+7 days')
    GROUP BY l.week_name
    ORDER BY l.start_date;
  ''');

    return result.map((map) {
      return {
        'week_name': map['week_name'],
        'total_sales': (map['total_sales'] as num).toDouble(),
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> fetchDailySales() async {
    final db = await database;
    final result = await db.rawQuery('''
  WITH Last7Days AS (
    SELECT date('now', '-6 days') AS sale_date UNION ALL
    SELECT date('now', '-5 days') UNION ALL
    SELECT date('now', '-4 days') UNION ALL
    SELECT date('now', '-3 days') UNION ALL
    SELECT date('now', '-2 days') UNION ALL
    SELECT date('now', '-1 days') UNION ALL
    SELECT date('now', '-0 days')
  )
  SELECT 
    CASE 
      WHEN strftime('%w', l.sale_date) = '0' THEN 'Sunday'
      WHEN strftime('%w', l.sale_date) = '1' THEN 'Monday'
      WHEN strftime('%w', l.sale_date) = '2' THEN 'Tuesday'
      WHEN strftime('%w', l.sale_date) = '3' THEN 'Wednesday'
      WHEN strftime('%w', l.sale_date) = '4' THEN 'Thursday'
      WHEN strftime('%w', l.sale_date) = '5' THEN 'Friday'
      WHEN strftime('%w', l.sale_date) = '6' THEN 'Saturday'
    END AS day_name,
    COALESCE(SUM(o.total_amount), 0) AS total_sales
  FROM Last7Days l
  LEFT JOIN orders o ON date(o.order_date) = l.sale_date
  GROUP BY l.sale_date
  ORDER BY l.sale_date DESC;
  ''');

    return result.map((map) {
      return {
        'day_name': map['day_name'],
        'total_sales': (map['total_sales'] as num).toDouble(),
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> fetchTopProducts(
    int selectedCategoryId,
  ) async {
    final db = await database;
    final today = DateTime.now().toIso8601String().split('T')[0];

    // First get ALL products in the category
    final allProducts = await db.rawQuery(
      '''
    SELECT 
      m.product_id,
      m.product_name,
      m.price
    FROM menu m
    WHERE m.category_id = ?
    ORDER BY m.product_name
    ''',
      [selectedCategoryId],
    );

    // Then get sales data for today
    final salesData = await db.rawQuery(
      '''
    SELECT 
      m.product_id,
      SUM(od.quantity) as quantity_sold,
      SUM(od.quantity * m.price) as total_sales
    FROM menu m
    LEFT JOIN order_details od ON m.product_id = od.product_id
    LEFT JOIN orders o ON od.order_id = o.order_id AND date(o.order_date) = ?
    WHERE m.category_id = ?
    GROUP BY m.product_id
    ''',
      [today, selectedCategoryId],
    );

    // Create a map of product sales for easy lookup
    final salesMap = {
      for (var sale in salesData)
        sale['product_id'] as int: {
          'quantity': sale['quantity_sold'] as int? ?? 0,
          'total_sales':
              sale['total_sales'] != null
                  ? (sale['total_sales'] as num).toDouble()
                  : 0.0,
        },
    };

    // Group products by their cleaned names
    final Map<String, List<Map<String, dynamic>>> groupedProducts = {};

    for (var product in allProducts) {
      final productId = product['product_id'] as int;
      final productName = product['product_name'] as String? ?? '';
      final price =
          product['price'] != null ? (product['price'] as num).toDouble() : 0.0;

      // Get sales data for this product (default to 0 if not found)
      final sales = salesMap[productId] ?? {'quantity': 0, 'total_sales': 0.0};

      // Clean the product name
      final cleanedName = cleanName(productName);
      if (cleanedName.isEmpty) continue;

      // Add to grouped products
      if (!groupedProducts.containsKey(cleanedName)) {
        groupedProducts[cleanedName] = [];
      }

      groupedProducts[cleanedName]!.add({
        'product_id': productId,
        'original_name': productName,
        'price': price,
        'quantity': sales['quantity'],
        'total_sales': sales['total_sales'],
      });
    }

    // Combine data for products with the same cleaned name
    final List<Map<String, dynamic>> combinedData = [];

    groupedProducts.forEach((cleanedName, products) {
      if (products.isEmpty) return;

      // Sum quantities and sales for all variations of this product
      final totalQuantity = products.fold(
        0,
        (sum, product) => sum + (product['quantity'] as int),
      );
      final totalSales = products.fold(
        0.0,
        (sum, product) => sum + (product['total_sales'] as double),
      );

      combinedData.add({
        'category': cleanedName,
        'quantity': totalQuantity,
        'total_price': totalSales,
        'products': products, // Keep original products for reference
      });
    });

    // Sort by quantity sold (descending) then by name
    combinedData.sort((a, b) {
      final quantityCompare = (b['quantity'] as int).compareTo(
        a['quantity'] as int,
      );
      if (quantityCompare != 0) return quantityCompare;
      return (a['category'] as String).compareTo(b['category'] as String);
    });

    return combinedData;
  }

  // Helper function to get top-products names
  String cleanName(String name) {
    List<String> removeWords = [
      'آدھا',
      'کلو',
      'گرام',
      'چھوٹا',
      'بڑا',
      'پلیٹ',
      'عدد',
      'کپ',
      'چھوٹے',
      'بڑے',
      'پاؤ',
      'درمیانی',
      'درمیانہ',
      'بڑی',
      'ایکسٹرا',
      '-',
      '—',
    ];

    // Remove anything after a dash "-"
    if (name.contains('-')) {
      name = name.split('-')[0].trim();
    }

    // Remove unwanted Urdu words
    for (var word in removeWords) {
      name = name.replaceAll(word, '');
    }

    // Remove any numbers (e.g., 1kg, 2 plate)
    name = name.replaceAll(RegExp(r'\d+'), '');

    // Remove extra spaces
    name = name.replaceAll(RegExp(r'\s+'), ' ').trim();

    return name;
  }

  Future<Map<String, dynamic>> fetchDashboardStats() async {
    final db = await database;

    final totalSalesResult = await db.rawQuery(
      'SELECT SUM(total_amount) AS total_sales FROM orders',
    );
    double totalSales = totalSalesResult.first['total_sales'] as double? ?? 0.0;

    final totalOrdersResult = await db.rawQuery(
      'SELECT COUNT(order_id) AS total_orders FROM orders',
    );
    int totalOrders = totalOrdersResult.first['total_orders'] as int? ?? 0;

    final salesLast30DaysResult = await db.rawQuery(
      "SELECT SUM(total_amount) AS sales_30_days FROM orders WHERE order_date >= date('now', '-30 days')",
    );
    double salesLast30Days =
        salesLast30DaysResult.first['sales_30_days'] as double? ?? 0.0;

    final totalProductsResult = await db.rawQuery(
      "SELECT SUM(quantity) AS total_products FROM order_details",
    );
    int totalProductsSold =
        totalProductsResult.first['total_products'] as int? ?? 0;

    return {
      'totalSales': totalSales,
      'totalOrders': totalOrders,
      'salesLast30Days': salesLast30Days,
      'totalProductsSold': totalProductsSold,
    };
  }

  // Helper function to get today's date in yyyy-MM-dd format
  String getFormattedToday() {
    final today = DateTime.now();
    return "${today.year.toString().padLeft(4, '0')}-"
        "${today.month.toString().padLeft(2, '0')}-"
        "${today.day.toString().padLeft(2, '0')}";
  }

  Future<double> getTodaySales() async {
    final db = await database;
    final formattedToday = getFormattedToday();

    final result = await db.rawQuery(
      '''
    SELECT SUM(total_amount) as total FROM orders 
    WHERE date(order_date) = ?
    ''',
      [formattedToday],
    );

    return result.isNotEmpty && result.first['total'] != null
        ? (result.first['total'] as double)
        : 0.0;
  }

  Future<double> getWeeklySales() async {
    final db = await database;
    final formattedToday = getFormattedToday();

    final result = await db.rawQuery(
      '''
    SELECT SUM(total_amount) as total FROM orders 
    WHERE date(order_date) BETWEEN date(?, '-7 days') AND date(?, '-1 day')
    ''',
      [formattedToday, formattedToday],
    );

    return result.isNotEmpty && result.first['total'] != null
        ? (result.first['total'] as double)
        : 0.0;
  }

  Future<double> getMonthlySales() async {
    final db = await database;
    final formattedToday = getFormattedToday();

    final result = await db.rawQuery(
      '''
    SELECT SUM(total_amount) as total FROM orders 
    WHERE date(order_date) BETWEEN date(?, '-37 days') AND date(?, '-8 days')
    ''',
      [formattedToday, formattedToday],
    );

    return result.isNotEmpty && result.first['total'] != null
        ? (result.first['total'] as double)
        : 0.0;
  }

  Future<void> resetDailySales() async {
    final db = await database;
    final today = getFormattedToday();

    await db.rawDelete(
      '''
    DELETE FROM order_details 
    WHERE order_id IN (
      SELECT order_id FROM orders 
      WHERE date(order_date) = ?
    )
    ''',
      [today],
    );

    await db.rawDelete(
      '''
    DELETE FROM orders 
    WHERE date(order_date) = ?
    ''',
      [today],
    );
  }

  Future<void> resetWeeklySales() async {
    final db = await database;
    final today = getFormattedToday();

    await db.rawDelete(
      '''
    DELETE FROM order_details 
    WHERE order_id IN (
      SELECT order_id FROM orders 
      WHERE date(order_date) BETWEEN date(?, '-7 days') AND date(?, '-1 day')
    )
    ''',
      [today, today],
    );

    await db.rawDelete(
      '''
    DELETE FROM orders 
    WHERE date(order_date) BETWEEN date(?, '-7 days') AND date(?, '-1 day')
    ''',
      [today, today],
    );
  }

  Future<void> resetMonthlySales() async {
    final db = await database;
    final today = getFormattedToday();

    await db.rawDelete(
      '''
    DELETE FROM order_details 
    WHERE order_id IN (
      SELECT order_id FROM orders 
      WHERE date(order_date) BETWEEN date(?, '-37 days') AND date(?, '-8 days')
    )
    ''',
      [today, today],
    );

    await db.rawDelete(
      '''
    DELETE FROM orders 
    WHERE date(order_date) BETWEEN date(?, '-37 days') AND date(?, '-8 days')
    ''',
      [today, today],
    );
  }

  Future<void> resetAllSales() async {
    final db = await database;

    await db.rawDelete('DELETE FROM order_details');
    await db.rawDelete('DELETE FROM orders');
  }

  Future<void> saveOrder(
    double totalAmount,
    List<ReceiptItem> orderItems,
  ) async {
    String orderDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final db = await database;

    await db.transaction((txn) async {
      int orderId = await txn.insert('orders', {
        'order_date': orderDate,
        'total_amount': totalAmount,
      });

      for (var item in orderItems) {
        await txn.insert('order_details', {
          'order_id': orderId,
          'product_id': item.product_id,
          'quantity': item.quantity,
        });
      }
    });
  }
}
