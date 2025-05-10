import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

//podos -- in PODOS folder
import 'package:pos_desktop/podos/receiptitem.dart'; //RECEIPT ITEM
import 'package:pos_desktop/podos/admin.dart'; // ADMIN

// widget(s) - header clock
import 'package:pos_desktop/widgets/realtimeclock.dart';

//providers -- in PODOS folder
import 'package:provider/provider.dart';
import 'package:pos_desktop/podos/receipt.dart';
import 'package:pos_desktop/podos/category.dart';
import 'package:pos_desktop/podos/menuitem.dart';

//page(s) - admin interface page
import 'package:pos_desktop/pages/admininterface.dart';

// printing related - see line 1512 for print's button's save mechanism!
// add save mechanism for save buttons urself use dbHelper if you want, np
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

// using _dbHelper to save order line #1618 onwards
import 'package:pos_desktop/db/database_helper.dart';

//math
import 'dart:math' as math;

class InterfacePage extends StatefulWidget {
  const InterfacePage({super.key});

  @override
  State<InterfacePage> createState() => _InterfacePageState();
}

class _InterfacePageState extends State<InterfacePage> {
  int _selectedIndex = 0;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm');
  final ScrollController _scrollController = ScrollController();
  final DatabaseHelper _databaseHelper =
      DatabaseHelper(); // line #1618 for print saving

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Load menu items from the database (psuedo implementation)
    Provider.of<MenuItemProvider>(
      context,
      listen: false,
    ).loadAllMenuItems(); // SEE MENUITEM.DART PODO
  }

  String _getDayOfWeek(int weekday) {
    const days = [
      'SUNDAY',
      'MONDAY',
      'TUESDAY',
      'WEDNESDAY',
      'THURSDAY',
      'FRIDAY',
      'SATURDAY',
    ];
    return days[weekday % 7];
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    double childAspectRatio = screenWidth / (screenHeight * 0.75);
    childAspectRatio = childAspectRatio.clamp(1.1, 1.85);

    ReceiptProvider _receiptProvider = Provider.of<ReceiptProvider>(
      context,
      listen: false,
    );

    return Scaffold(
      backgroundColor: Color(0xFF4c2b08),
      body: Column(
        children: [
          Container(
            // HEADER START
            color: const Color(0xFFD7BDA6),
            width: double.infinity,
            height: screenHeight * (150 / 1080),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.only(left: screenWidth * (85 / 1920)),
                    color: const Color(0xFFD7BDA6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            const Color(0xFF4c2b08).withOpacity(0.7),
                            BlendMode.srcATop,
                          ),
                          child: Image.asset(
                            'assets/images/trust_nexus_logo.png',
                            height: screenHeight * (150 / 1080),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                const Spacer(),
                const Spacer(),
                Flexible(
                  flex: 4,
                  child: Container(
                    color: const Color(0xFFD7BDA6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "امتیاز بیکرز",
                          style: GoogleFonts.notoNastaliqUrdu(
                            fontSize: screenWidth * (60 / 1920),
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF6d3914),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                const Spacer(),
                const Spacer(),
                Flexible(
                  flex: 0,
                  child: Container(
                    margin: EdgeInsets.only(right: screenWidth * (40 / 1920)),
                    child: VerticalDivider(
                      color: const Color(0xFF4c2b08),
                      thickness: 2,
                      width: screenWidth * (10 / 1920),
                      indent: screenHeight * (10 / 1080),
                      endIndent: screenHeight * (10 / 1080),
                    ),
                  ),
                ),
                Flexible(
                  flex: 0,
                  child: Container(
                    alignment: Alignment.centerRight,
                    color: const Color(0xFFD7BDA6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: screenWidth * (160 / 1920),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: RealtimeClock(),
                          ),
                        ),

                        SizedBox(height: screenHeight * (5 / 1080)),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              _getDayOfWeek(DateTime.now().weekday),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: screenWidth * (20 / 1920),
                                fontWeight: FontWeight.w500,
                                color: const Color(0xff4C2B08),
                              ),
                            ),
                            SizedBox(width: screenWidth * (10 / 1920)),
                            Text(
                              DateTime.now().toString().split(' ')[0],
                              style: GoogleFonts.poppins(
                                fontSize: screenWidth * (20 / 1920),
                                fontWeight: FontWeight.w500,
                                color: const Color(0xff4C2B08),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  flex: 0,
                  child: Container(
                    margin: EdgeInsets.only(right: screenWidth * (12 / 1920)),
                    alignment: Alignment.center,
                    color: const Color(0xFFD7BDA6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 0),
                              child: Text(
                                'POWERED BY',
                                style: GoogleFonts.poppins(
                                  fontSize: screenWidth * (20 / 1920),
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF4c2b08),
                                ),
                              ),
                            ),
                            SizedBox(width: screenWidth * (10 / 1920)),
                            Padding(
                              padding: EdgeInsets.only(top: 0),
                              child: ShaderMask(
                                shaderCallback:
                                    (bounds) => const LinearGradient(
                                      colors: [
                                        Color(0xFF6d3914),
                                        Color(0xff4C2B08),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ).createShader(bounds),
                                child: Text(
                                  'TRUST NEXUS',
                                  style: GoogleFonts.poppins(
                                    fontSize: screenWidth * (20 / 1920),
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white, // ignored
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Tooltip(
                                message: "Need help? Contact support!",
                                textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth * (13 / 1920),
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.help_outline,
                                  color: const Color(0xff4C2B08),
                                  size: screenWidth * (27 / 1920),
                                ),
                              ),
                              SizedBox(width: screenWidth * (5 / 1920)),
                              Text(
                                '0303-8184136',
                                style: GoogleFonts.poppins(
                                  fontSize: screenWidth * (20 / 1920),
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF4c2b08),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          child: Tooltip(
                            message:
                                "Log in as an admin to access advanced features",
                            textStyle: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * (14 / 1920),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF6d3914),
                                    Color(0xff4C2B08),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  final usernameController =
                                      TextEditingController();
                                  final passwordController =
                                      TextEditingController();

                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        backgroundColor: Color(0xFFD7BDA6),
                                        title: Text(
                                          "Admin Login",
                                          style: GoogleFonts.poppins(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF4c2b08),
                                          ),
                                        ),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextField(
                                              controller: usernameController,
                                              decoration: InputDecoration(
                                                labelText: 'Username',
                                                labelStyle: GoogleFonts.poppins(
                                                  color: const Color(
                                                    0xFF4c2b08,
                                                  ),
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            TextField(
                                              controller: passwordController,
                                              obscureText: true,
                                              decoration: InputDecoration(
                                                labelText: 'Password',
                                                labelStyle: GoogleFonts.poppins(
                                                  color: const Color(
                                                    0xFF4c2b08,
                                                  ),
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text(
                                              'Cancel',
                                              style: GoogleFonts.poppins(
                                                color: const Color(0xFF4c2b08),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              final username =
                                                  usernameController.text
                                                      .trim();
                                              final password =
                                                  passwordController.text
                                                      .trim();
                                              final isAuthenticated =
                                                  await Admin.authenticate(
                                                    username,
                                                    password,
                                                  );
                                              if (isAuthenticated) {
                                                Navigator.of(context).pop();
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder:
                                                        (context) =>
                                                            AdminInterface(),
                                                  ),
                                                );
                                              } else {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Invalid username or password',
                                                    ),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            },

                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFF4c2b08,
                                              ),
                                            ),
                                            child: Text(
                                              'Login',
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  padding: EdgeInsets.all(
                                    screenWidth * (5 / 1920),
                                  ),
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  minimumSize: Size(
                                    screenWidth * (100 / 1920),
                                    screenHeight * (40 / 1080),
                                  ),
                                ),
                                icon: Icon(
                                  Icons.admin_panel_settings,
                                  color: const Color(0xFFD7BDA6),
                                  size: screenWidth * (21 / 1920),
                                ),
                                label: Text(
                                  'ADMIN LOGIN',
                                  style: GoogleFonts.poppins(
                                    fontSize: screenWidth * (21 / 1920),
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFFD7BDA6),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ), // HEADER END

          Divider(
            color: Color(0xFFAB7843),
            thickness: 2,
            height: 20,
          ), // DIVIDER

          Expanded(
            // MAIN
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // NAVIGATION COLUMN
                Padding(
                  padding: EdgeInsets.only(
                    left: screenWidth * (20 / 1920),
                    right: screenWidth * (20 / 1920),
                    bottom: screenHeight * (20 / 1080),
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    width: screenWidth * (280 / 1920),
                    child: Column(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: RawScrollbar(
                              thumbColor: Colors.brown.shade500,
                              thumbVisibility: true,
                              controller: _scrollController,
                              child: SingleChildScrollView(
                                controller: _scrollController,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        alignment: Alignment.center,
                                        child: Text(
                                          "زمرہ منتخب کریں",
                                          style: GoogleFonts.notoNastaliqUrdu(
                                            fontSize: screenWidth * (18 / 1920),
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFFD7BDA6),
                                          ),
                                        ),
                                      ),
                                    ),
                                    ...List.generate(
                                      Provider.of<CategoryProvider>(
                                        context,
                                        listen: false,
                                      ).categories.length,
                                      (index) {
                                        return SizedBox(
                                          width: 350,
                                          child: _buildNavItem(
                                            index,
                                            Provider.of<CategoryProvider>(
                                              context,
                                              listen: false,
                                            ).categories[index].name,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Flexible(
                  flex: 0,
                  child: VerticalDivider(
                    color: const Color(0xFFAB7843),
                    thickness: screenWidth * (2 / 1920),
                    width: screenWidth * (10 / 1920),
                    indent: screenHeight * (80 / 1080),
                    endIndent: screenHeight * (125 / 1080),
                  ),
                ),

                // MAIN CONTENT AREA
                Flexible(
                  flex: 7,
                  child: Container(
                    color: Color(0xFF4c2b08),
                    padding: EdgeInsets.fromLTRB(
                      screenWidth * (20 / 1920),
                      screenHeight * (17 / 1080),
                      screenWidth * (20 / 1920),
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "مینو آئٹم منتخب کریں",
                              style: GoogleFonts.notoNastaliqUrdu(
                                fontSize: screenWidth * (18 / 1920),
                                color: Color(0xFFD7BDA6),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Consumer<CategoryProvider>(
                              builder: (context, categoryProvider, child) {
                                return Text(
                                  categoryProvider
                                      .categories[categoryProvider
                                          .selectedIndex]
                                      .name,
                                  style: GoogleFonts.notoNastaliqUrdu(
                                    fontSize: screenWidth * (28 / 1920),
                                    color: Color(0xFFE4CCB7),
                                    fontWeight: FontWeight.w700,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * (10 / 1080)),
                        Divider(
                          color: Color(0xFFAB7843),
                          thickness: 2,
                          height: 20,
                        ),
                        SizedBox(height: screenHeight * (10 / 1080)),
                        Flexible(
                          flex: 8,
                          child: Consumer<MenuItemProvider>(
                            builder: (context, menuItemProvider, child) {
                              return GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 5,
                                      crossAxisSpacing: 5,
                                      mainAxisSpacing: 5,
                                      childAspectRatio: childAspectRatio,
                                    ),
                                itemCount: menuItemProvider.menuItems.length,
                                itemBuilder: (context, index) {
                                  return ElevatedButton(
                                    onPressed: () {
                                      final receiptProvider =
                                          Provider.of<ReceiptProvider>(
                                            context,
                                            listen: false,
                                          );
                                      if (index <
                                          menuItemProvider.menuItems.length) {
                                        ReceiptItem newItem = ReceiptItem(
                                          id: index,
                                          itemName:
                                              menuItemProvider
                                                  .menuItems[index]
                                                  .product_name,
                                          quantity: 1,
                                          price:
                                              menuItemProvider
                                                  .menuItems[index]
                                                  .price,
                                          product_id:
                                              menuItemProvider
                                                  .menuItems[index]
                                                  .product_id,
                                        );

                                        // Add the item to the receipt
                                        receiptProvider.addItem(newItem);
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "یہ آئٹم ابھی دستیاب نہیں ہے",
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(
                                          color:
                                              index % 2 == 0
                                                  ? const Color(
                                                    0xFFAB7843,
                                                  ).withOpacity(0.85)
                                                  : const Color(
                                                    0xFF6D3914,
                                                  ).withOpacity(0.85),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: ColorFiltered(
                                              colorFilter: ColorFilter.mode(
                                                index % 2 == 0
                                                    ? const Color(
                                                      0xFFAB7843,
                                                    ).withOpacity(0.85)
                                                    : const Color(
                                                      0xFFBA7834,
                                                    ).withOpacity(0.85),
                                                BlendMode.multiply,
                                              ),
                                              child:
                                                  index <
                                                          menuItemProvider
                                                              .menuItems
                                                              .length
                                                      ? (menuItemProvider
                                                                      .menuItems[index]
                                                                      .imagePath !=
                                                                  null &&
                                                              menuItemProvider
                                                                  .menuItems[index]
                                                                  .imagePath!
                                                                  .isNotEmpty)
                                                          ? (menuItemProvider
                                                                  .menuItems[index]
                                                                  .imagePath!
                                                                  .startsWith(
                                                                    'assets/',
                                                                  )
                                                              ? Image.asset(
                                                                menuItemProvider
                                                                    .menuItems[index]
                                                                    .imagePath!,
                                                                fit:
                                                                    BoxFit
                                                                        .cover,
                                                                width:
                                                                    double
                                                                        .infinity,
                                                                height:
                                                                    double
                                                                        .infinity,
                                                              )
                                                              : Image.file(
                                                                File(
                                                                  menuItemProvider
                                                                      .menuItems[index]
                                                                      .imagePath!
                                                                      .replaceAll(
                                                                        '\\',
                                                                        '/',
                                                                      ),
                                                                ),
                                                                fit:
                                                                    BoxFit
                                                                        .cover,
                                                                width:
                                                                    double
                                                                        .infinity,
                                                                height:
                                                                    double
                                                                        .infinity,
                                                                errorBuilder: (
                                                                  context,
                                                                  error,
                                                                  stackTrace,
                                                                ) {
                                                                  return Image.asset(
                                                                    'assets/images/items/item30.jpg',
                                                                    fit:
                                                                        BoxFit
                                                                            .cover,
                                                                    width:
                                                                        double
                                                                            .infinity,
                                                                    height:
                                                                        double
                                                                            .infinity,
                                                                  );
                                                                },
                                                              ))
                                                          : Image.asset(
                                                            'assets/images/items/item30.jpg',
                                                            fit: BoxFit.cover,
                                                            width:
                                                                double.infinity,
                                                            height:
                                                                double.infinity,
                                                          )
                                                      : Image.asset(
                                                        'assets/images/items/item30.jpg',
                                                        fit: BoxFit.cover,

                                                        width: double.infinity,
                                                        height: double.infinity,
                                                      ),
                                            ),
                                          ),
                                          menuItemProvider
                                                  .menuItems[index]
                                                  .product_name
                                                  .trim()
                                                  .isNotEmpty
                                              ? Center(
                                                // CENTER COLUMN FOR NAME AND PRICE
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Color(
                                                      0xFF4c2b08,
                                                    ).withOpacity(0.4),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        menuItemProvider
                                                            .menuItems[index]
                                                            .product_name,
                                                        style:
                                                            GoogleFonts.notoNastaliqUrdu(
                                                              fontSize:
                                                                  screenWidth *
                                                                  0.0104,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),

                                                      Text(
                                                        "RS. ${menuItemProvider.menuItems[index].price}", // SEE MENUITEM.DART PODO
                                                        style:
                                                            GoogleFonts.poppins(
                                                              fontSize:
                                                                  screenWidth *
                                                                  0.0084,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              color:
                                                                  Colors
                                                                      .white70,
                                                            ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                              : const SizedBox.shrink(), // renders nothing if name is empty
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),

                //RECEIPT SECTION
                Flexible(
                  flex: 3,
                  child: Container(
                    height: screenHeight + 20,
                    padding: EdgeInsets.fromLTRB(
                      screenWidth * 20 / 1920,
                      screenHeight * 45 / 1080,
                      screenWidth * 20 / 1920,
                      screenHeight * 10 / 1080,
                    ),
                    color: const Color(0xFF4c2b08),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),

                        // Receipt Container
                        Container(
                          height: MediaQuery.of(context).size.height * 0.7,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: const Color(0xFFAB7843),
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD7BDA6),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Header
                                    Column(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(8),
                                              ),
                                          child: Container(
                                            height: screenHeight * (40 / 1080),
                                            color: const Color(0xFF6d3914),
                                            alignment: Alignment.center,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                SizedBox(width: 5),
                                                const Icon(
                                                  Icons.receipt_long,
                                                  color: Color(0xFFD7BDA6),
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 5),
                                                Text(
                                                  "Receipt",
                                                  style: GoogleFonts.poppins(
                                                    fontSize:
                                                        screenWidth * 0.009375,
                                                    fontWeight: FontWeight.w600,
                                                    color: const Color(
                                                      0xFFD7BDA6,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: screenWidth * 0.009375,
                                                ),
                                                Consumer<ReceiptProvider>(
                                                  builder: (
                                                    context,
                                                    receiptProvider,
                                                    child,
                                                  ) {
                                                    return Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 6,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                          0xFFD7BDA6,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        "Items: ${receiptProvider.receiptItems.length}",
                                                        style:
                                                            GoogleFonts.poppins(
                                                              fontSize:
                                                                  screenWidth *
                                                                  0.0083,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  const Color(
                                                                    0xFF4c2b08,
                                                                  ),
                                                            ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                                const SizedBox(width: 8),
                                                ElevatedButton.icon(
                                                  onPressed: () {
                                                    setState(() {
                                                      _receiptProvider
                                                          .clearReceipt();
                                                    });
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color(0xFFD7BDA6),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 5,
                                                          horizontal: 10,
                                                        ),
                                                  ),
                                                  icon: const Icon(
                                                    Icons.clear_all,
                                                    color: Color(0xFF6d3914),
                                                  ),
                                                  label: Text(
                                                    "Clear",
                                                    style: GoogleFonts.poppins(
                                                      fontSize:
                                                          screenWidth * 0.0083,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: const Color(
                                                        0xFF6d3914,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                bottom: Radius.circular(12),
                                              ),
                                          child: Container(
                                            height: screenHeight * (50 / 1080),
                                            color: const Color(0xFFAB7843),
                                            alignment: Alignment.center,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                SizedBox(
                                                  width:
                                                      screenWidth * (5 / 1920),
                                                ),
                                                Text(
                                                  "Item Name",
                                                  style: GoogleFonts.poppins(
                                                    fontSize:
                                                        screenWidth *
                                                        (18 / 1920),
                                                    fontWeight: FontWeight.w600,
                                                    color: const Color(
                                                      0xFFD7BDA6,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width:
                                                      screenWidth * (32 / 1920),
                                                ),
                                                Text(
                                                  "Quantity",
                                                  style: GoogleFonts.poppins(
                                                    fontSize:
                                                        screenWidth *
                                                        (18 / 1920),
                                                    fontWeight: FontWeight.w600,
                                                    color: const Color(
                                                      0xFFD7BDA6,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width:
                                                      screenWidth * (52 / 1920),
                                                ),
                                                Text(
                                                  "Price",
                                                  style: GoogleFonts.poppins(
                                                    fontSize:
                                                        screenWidth *
                                                        (18 / 1920),
                                                    fontWeight: FontWeight.w600,
                                                    color: const Color(
                                                      0xFFD7BDA6,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width:
                                                      screenWidth * (13 / 1920),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    Consumer<ReceiptProvider>(
                                      builder: (
                                        context,
                                        receiptProvider,
                                        child,
                                      ) {
                                        final receiptItems =
                                            receiptProvider.receiptItems;

                                        return receiptItems.isEmpty
                                            ? Expanded(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .shopping_cart_outlined,
                                                    size:
                                                        screenHeight *
                                                        (50 / 1080),
                                                    color: Color(0xFF4c2b08),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Text(
                                                    "ابھی تک کوئی آئٹم شامل نہیں کی گئی",
                                                    style:
                                                        GoogleFonts.notoNastaliqUrdu(
                                                          fontSize:
                                                              screenWidth *
                                                              (18 / 1920),
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: const Color(
                                                            0xFF4c2b08,
                                                          ),
                                                        ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  const SizedBox(height: 15),
                                                  Text(
                                                    "مینو آئٹمز پر کلک کریں تاکہ آئٹمز شامل کی جا سکیں",
                                                    style:
                                                        GoogleFonts.notoNastaliqUrdu(
                                                          fontSize:
                                                              screenWidth *
                                                              (14 / 1920),
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: const Color(
                                                            0xaa4c2b08,
                                                          ),
                                                        ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                            )
                                            : Expanded(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFD7BDA6),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: ListView.separated(
                                                  itemCount:
                                                      receiptItems.length,
                                                  separatorBuilder:
                                                      (context, index) =>
                                                          Divider(
                                                            height: 1,
                                                            color: Color(
                                                              0xFFAB7843,
                                                            ),
                                                          ),
                                                  itemBuilder: (
                                                    context,
                                                    index,
                                                  ) {
                                                    final item =
                                                        receiptItems[index];
                                                    return Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            vertical:
                                                                screenHeight *
                                                                (6 / 1080),
                                                            horizontal:
                                                                screenWidth *
                                                                (10 / 1920),
                                                          ),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  item.itemName,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  maxLines: 2,
                                                                  style: GoogleFonts.notoNastaliqUrdu(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontSize: math.max(
                                                                      screenWidth *
                                                                          (12 /
                                                                              1920),
                                                                      12,
                                                                    ),
                                                                    color: const Color(
                                                                      0xFF4c2b08,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Text(
                                                                  'Rs. ${item.price.toStringAsFixed(0)}',
                                                                  style: TextStyle(
                                                                    color: const Color(
                                                                      0xdd4c2b08,
                                                                    ),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    fontSize: math.max(
                                                                      screenWidth *
                                                                          (15 /
                                                                              1920),
                                                                      14,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),

                                                          Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              IconButton(
                                                                icon: Icon(
                                                                  Icons
                                                                      .remove_circle_outline,
                                                                  size:
                                                                      screenWidth *
                                                                      (30 /
                                                                          1920),
                                                                ),
                                                                color:
                                                                    Colors
                                                                        .red[400],
                                                                onPressed: () {
                                                                  receiptProvider
                                                                      .updateQuantity(
                                                                        index,
                                                                        item.quantity -
                                                                            1,
                                                                      );
                                                                },
                                                              ),
                                                              Container(
                                                                padding: EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      screenWidth *
                                                                      (8 /
                                                                          1920),
                                                                  vertical:
                                                                      screenHeight *
                                                                      (4 /
                                                                          1080),
                                                                ),
                                                                decoration: BoxDecoration(
                                                                  color: const Color(
                                                                    0x224c2b08,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        screenWidth *
                                                                            (4 /
                                                                                1920),
                                                                      ),
                                                                ),
                                                                child: SizedBox(
                                                                  width:
                                                                      screenWidth *
                                                                      (30 /
                                                                          1920),
                                                                  child: Text(
                                                                    '${item.quantity}',
                                                                    style: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                  ),
                                                                ),
                                                              ),
                                                              IconButton(
                                                                icon: Icon(
                                                                  Icons
                                                                      .add_circle_outline,
                                                                  size:
                                                                      screenWidth *
                                                                      (30 /
                                                                          1920),
                                                                ),
                                                                color:
                                                                    Colors
                                                                        .green[400],
                                                                onPressed: () {
                                                                  receiptProvider
                                                                      .updateQuantity(
                                                                        index,
                                                                        item.quantity +
                                                                            1,
                                                                      );
                                                                },
                                                              ),
                                                              SizedBox(
                                                                width:
                                                                    screenWidth *
                                                                    (10 / 1920),
                                                              ),
                                                              Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  SizedBox(
                                                                    width:
                                                                        screenWidth *
                                                                        (80 /
                                                                            1920),
                                                                    child: Text(
                                                                      'Rs. ${(item.price * item.quantity).toStringAsFixed(0)}',
                                                                      style: TextStyle(
                                                                        fontSize: math.max(
                                                                          screenWidth *
                                                                              (18 /
                                                                                  1920),
                                                                          15,
                                                                        ),
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .right,
                                                                    ),
                                                                  ),
                                                                  IconButton(
                                                                    icon: Icon(
                                                                      Icons
                                                                          .delete_outline,
                                                                      size:
                                                                          screenHeight *
                                                                          (30 /
                                                                              1080),
                                                                    ),
                                                                    color:
                                                                        Colors
                                                                            .red[700],
                                                                    onPressed: () {
                                                                      receiptProvider
                                                                          .removeItem(
                                                                            index,
                                                                          );
                                                                    },
                                                                    padding:
                                                                        EdgeInsets
                                                                            .zero,
                                                                    constraints:
                                                                        const BoxConstraints(),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            );
                                      },
                                    ),

                                    // Footer with Total and Buttons
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        bottom: Radius.circular(12),
                                      ),
                                      child: Container(
                                        color: const Color(0xFFAB7843),
                                        child: Column(
                                          children: [
                                            // Total Row
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16.0,
                                                    vertical: 8.0,
                                                  ),
                                              child: Consumer<ReceiptProvider>(
                                                builder: (
                                                  context,
                                                  receiptProvider,
                                                  child,
                                                ) {
                                                  return Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        "TOTAL:",
                                                        style:
                                                            GoogleFonts.poppins(
                                                              fontSize:
                                                                  screenWidth *
                                                                  (20 / 1920),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  const Color(
                                                                    0xDDFFFFFF,
                                                                  ),
                                                            ),
                                                      ),
                                                      Text(
                                                        "PKR ${Provider.of<ReceiptProvider>(context, listen: false).calculateTotalPrice().toStringAsFixed(0)}",
                                                        style:
                                                            GoogleFonts.poppins(
                                                              fontSize:
                                                                  screenWidth *
                                                                  (20 / 1920),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: Colors
                                                                  .white
                                                                  .withAlpha(
                                                                    0xDD,
                                                                  ),
                                                            ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ),
                                            ),

                                            Divider(
                                              height: 10,
                                              indent: 10,
                                              endIndent: 10,
                                              color: Color(0xFF4c2b08),
                                              thickness: 1,
                                            ),

                                            // Buttons
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 8.0,
                                                  ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  ElevatedButton.icon(
                                                    onPressed: () {
                                                      final receiptProvider =
                                                          Provider.of<
                                                            ReceiptProvider
                                                          >(
                                                            context,
                                                            listen: false,
                                                          );
                                                      final items =
                                                          receiptProvider
                                                              .receiptItems;

                                                      if (items.isNotEmpty) {
                                                        double totalPrice =
                                                            receiptProvider
                                                                .calculateTotalPrice();

                                                        _databaseHelper
                                                            .saveOrder(
                                                              totalPrice,
                                                              items,
                                                            )
                                                            .then((_) {
                                                              setState(() {
                                                                _receiptProvider
                                                                    .clearReceipt();
                                                              });
                                                              ScaffoldMessenger.of(
                                                                context,
                                                              ).showSnackBar(
                                                                SnackBar(
                                                                  content: Text(
                                                                    'Order saved successfully!',
                                                                  ),
                                                                ),
                                                              );
                                                            })
                                                            .catchError((
                                                              error,
                                                            ) {
                                                              ScaffoldMessenger.of(
                                                                context,
                                                              ).showSnackBar(
                                                                SnackBar(
                                                                  content: Text(
                                                                    'Failed to save order: $error',
                                                                  ),
                                                                ),
                                                              );
                                                            });
                                                      }
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          const Color.fromARGB(
                                                            255,
                                                            238,
                                                            184,
                                                            127,
                                                          ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 10,
                                                            horizontal: 20,
                                                          ),
                                                    ),
                                                    icon: Icon(
                                                      Icons.save,
                                                      color: Color(0xFF6d3914),
                                                    ),
                                                    label: Text(
                                                      "Save Bill",
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize:
                                                                screenWidth *
                                                                (18 / 1920),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Color(
                                                              0xFF6d3914,
                                                            ),
                                                          ),
                                                    ),
                                                  ),
                                                  ElevatedButton.icon(
                                                    onPressed: () {
                                                      final items =
                                                          Provider.of<
                                                            ReceiptProvider
                                                          >(
                                                            context,
                                                            listen: false,
                                                          ).receiptItems;
                                                      if (items.isNotEmpty) {
                                                        _printBill().then((_) {
                                                          setState(() {
                                                            _receiptProvider
                                                                .clearReceipt();
                                                          });
                                                        });
                                                      }
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          const Color.fromARGB(
                                                            255,
                                                            238,
                                                            184,
                                                            127,
                                                          ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 10,
                                                            horizontal: 20,
                                                          ),
                                                    ),
                                                    icon: const Icon(
                                                      Icons.print,
                                                      color: Color(0xFF6d3914),
                                                    ),
                                                    label: Text(
                                                      "Print Bill",
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize:
                                                                screenWidth *
                                                                (18 / 1920),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Color(
                                                              0xFF6d3914,
                                                            ),
                                                          ),
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
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String title) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    bool isSelected = _selectedIndex == index;

    // Example scaling function
    double sw(double value) => screenWidth * (value / 1920);
    double sh(double value) => screenHeight * (value / 1080);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: sh(8.0)),
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedIndex = index;
                  Provider.of<CategoryProvider>(
                    context,
                    listen: false,
                  ).setSelectedIndex(index);
                  Provider.of<MenuItemProvider>(
                    context,
                    listen: false,
                  ).loadMenuItems(index + 1);
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isSelected
                        ? const Color(0xFFAB7843)
                        : Color.lerp(
                          const Color(0xFFD7BDA6),
                          const Color(0xFFAB7843),
                          index /
                              Provider.of<CategoryProvider>(
                                context,
                                listen: false,
                              ).categories.length,
                        ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(sw(12)),
                  side:
                      isSelected
                          ? const BorderSide(
                            color: Color(0x224c2b08),
                            width: 10,
                          )
                          : BorderSide.none,
                ),
                padding: EdgeInsets.symmetric(
                  vertical: sh(41),
                  horizontal: sw(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Consumer<CategoryProvider>(
                    builder: (context, categoryProvider, child) {
                      return ClipOval(
                        child: Image.asset(
                          categoryProvider.categories[index].imagePath ??
                              'assets/images/bread.jpg',
                          height: sw(60),
                          width: sw(60),
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                  SizedBox(width: sw(10)),
                  VerticalDivider(
                    color: const Color(0xFF4c2b08),
                    thickness: 2,
                    width: sw(20),
                    indent: sh(10),
                    endIndent: sh(10),
                  ),
                  const Spacer(),
                  Text(
                    title.toUpperCase(),
                    style: GoogleFonts.notoNastaliqUrdu(
                      color: const Color(0xFF4c2b08),
                      fontSize: sw(23), // ← originally 23
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // PRINT BILL

  Future<void> _printBill() async {
    final pdf = pw.Document();
    final String formattedDate = DateFormat(
      'yyyyMMdd_HHmmss',
    ).format(DateTime.now());
    final String fileName = 'Bill_$formattedDate.pdf';

    final receiptProvider = Provider.of<ReceiptProvider>(
      context,
      listen: false,
    );

    final urduFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/static/Amiri-Regular.ttf'), //@NEW
    );

    final _orderItems = receiptProvider.receiptItems;
    final _totalAmount = receiptProvider.calculateTotalPrice();

    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(
          70 * PdfPageFormat.mm,
          200 * PdfPageFormat.mm,
        ).applyMargin(left: 2, right: 2, top: 2, bottom: 2),
        textDirection: pw.TextDirection.rtl, //@NEW
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Restaurant name
              pw.Center(
                child: pw.Text(
                  'Imtiaz Bakers',
                  style: pw.TextStyle(
                    fontSize: 13, // Smaller font size
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 6),

              // Bill details
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Bill #: ${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                  pw.Text(
                    'Date: ${_dateFormat.format(DateTime.now())}',
                    style: const pw.TextStyle(fontSize: 9), // Smaller font size
                  ),
                ],
              ),
              pw.SizedBox(height: 10), // Reduced spacing
              // Table for items
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(5),
                  ),
                ),
                child: pw.Table(
                  border: pw.TableBorder.symmetric(
                    inside: const pw.BorderSide(width: 0.5),
                  ),
                  columnWidths: {
                    // 0: const pw.FlexColumnWidth(80),// Smaller column width
                    0: const pw.FlexColumnWidth(3.5),
                    1: const pw.FlexColumnWidth(1),
                    2: const pw.FlexColumnWidth(1),
                    3: const pw.FlexColumnWidth(1.5), // Adjusted column width
                    //1: const pw.FixedColumnWidth(23), // Smaller column width
                    //2: const pw.FixedColumnWidth(33), // Smaller column width
                    //3: const pw.FixedColumnWidth(46), // Smaller column width
                  },
                  children: [
                    // Table header
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey300,
                      ),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(
                            1.0,
                          ), // Reduced padding----4
                          child: pw.Text(
                            'ITEM',
                            style: pw.TextStyle(
                              fontSize: 9, // Smaller font size
                              fontWeight: pw.FontWeight.bold,
                            ),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(
                            1,
                          ), // Reduced padding------4
                          child: pw.Text(
                            'QTY',
                            style: pw.TextStyle(
                              fontSize: 9, // Smaller font size
                              fontWeight: pw.FontWeight.bold,
                            ),
                            textAlign: pw.TextAlign.left,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(
                            1,
                          ), // Reduced padding-----4
                          child: pw.Text(
                            'RATE',
                            style: pw.TextStyle(
                              fontSize: 9, // Smaller font size
                              fontWeight: pw.FontWeight.bold,
                            ),
                            textAlign: pw.TextAlign.left,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(
                            1,
                          ), // Reduced padding----4
                          child: pw.Text(
                            'AMOUNT',
                            style: pw.TextStyle(
                              fontSize: 9, // Smaller font size ---8
                              fontWeight: pw.FontWeight.bold,
                            ),
                            textAlign: pw.TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                    // Table rows for each item
                    ..._orderItems.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return pw.TableRow(
                        decoration:
                            index % 2 == 0
                                ? const pw.BoxDecoration(
                                  color: PdfColors.grey100,
                                )
                                : null,
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(
                              4.0,
                            ), // Reduced padding
                            child: pw.Text(
                              item.itemName,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                font: urduFont,
                                fontSize: 10,
                              ),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(
                              4.0,
                            ), // Reduced padding
                            child: pw.Text(
                              '${item.quantity}',
                              style: const pw.TextStyle(fontSize: 9),
                              textAlign: pw.TextAlign.left, // Smaller font size
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(
                              4.0,
                            ), // Reduced padding
                            child: pw.Text(
                              '${item.price.toInt()}',
                              style: pw.TextStyle(
                                fontWeight:
                                    pw
                                        .FontWeight
                                        .bold, // Use pw.FontWeight instead of FontWeight
                                fontSize: 10,
                                // Adjust font size
                              ),
                              textAlign: pw.TextAlign.left,
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(
                              4.0,
                            ), // Reduced padding
                            child: pw.Text(
                              (item.price * item.quantity).toStringAsFixed(0),
                              style: const pw.TextStyle(fontSize: 9),
                              textAlign: pw.TextAlign.left, // Smaller font size
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
              pw.SizedBox(height: 10), // Reduced spacing
              // Total amount
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Row(
                      mainAxisSize: pw.MainAxisSize.min,
                      children: [
                        pw.Container(
                          width: 60, // Adjusted width
                          child: pw.Text(
                            'Rs. ${_totalAmount.toStringAsFixed(0)}',
                            style: pw.TextStyle(
                              fontSize: 10, // Smaller font size
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),

                        pw.Container(
                          width: 80, // Adjusted width
                          child: pw.Text(
                            'TOTAL:',
                            style: pw.TextStyle(
                              fontSize: 10, // Smaller font size
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 2), // Reduced spacing -----4
              // Powered by Trust Nexus
              pw.Center(
                child: pw.RichText(
                  text: pw.TextSpan(
                    children: [
                      pw.TextSpan(
                        text: '\nTrust Nexus', // Bold text
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),

                      pw.TextSpan(
                        text: 'Powered by ', // Normal text
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              pw.SizedBox(height: 3),
              pw.Center(
                child: pw.Text(
                  'For Software Development: 0303-8184136',
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
              ),
              pw.SizedBox(height: 10), // Adds spacing before cutting
              pw.SizedBox(height: 30), // Ensures bottom space for cutter
            ],
          );
        },
      ),
    );

    Directory? directory;
    if (Platform.isWindows) {
      directory = Directory(
        '${Platform.environment['USERPROFILE']}\\Documents\\pos_desktop',
      );
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    final String path = '${directory.path}\\$fileName';
    final File file = File(path);
    await file.writeAsBytes(await pdf.save());
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Receipt saved to $path')));

    //Selects default printer automatically
    final List<Printer> printers = await Printing.listPrinters();

    Printer? defaultPrinter;
    if (printers.isNotEmpty) {
      defaultPrinter = printers.firstWhere(
        (printer) => printer.isDefault,
        orElse:
            () =>
                printers
                    .first, // Fallback to the first printer if no default found
      );
    }

    if (defaultPrinter != null) {
      await Printing.directPrintPdf(
        printer: defaultPrinter,
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No printer found. Please connect a printer.'),
          backgroundColor: Colors.red,
        ),
      );
    }
    _databaseHelper.saveOrder(_totalAmount, _orderItems);
  }
}
