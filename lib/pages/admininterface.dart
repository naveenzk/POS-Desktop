import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_desktop/main.dart';

//admin subpages
import 'package:pos_desktop/pages/admin-subpages/dashboard.dart';
import 'package:pos_desktop/pages/admin-subpages/manageproducts.dart';
import 'package:pos_desktop/pages/admin-subpages/reset.dart';

// NO PROVIDERS HERE

class AdminInterface extends StatefulWidget {
  @override
  _AdminInterfaceState createState() => _AdminInterfaceState();
}

class _AdminInterfaceState extends State<AdminInterface> {
  int _selectedIndex = 0;
  final List<String> _navItems = ['Dashboard', 'Manage Products', 'Reset'];
  final List<Widget> _selectedPages = [
    TotalSalesPage(),

    DishPage(),

    ResetPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFFD7BDA6),
      body: Column(
        children: [
          // TOP BAR
          Container(
            height: screenHeight * (60 / 1080),
            color: const Color(0xFF6d3914),
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * (20 / 1920),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "POS Nexus Desktop",
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFFD7BDA6),
                    fontSize: screenWidth * (25.25 / 1920),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                VerticalDivider(
                  color: const Color(0xFFAB7843),
                  endIndent: screenHeight * (10 / 1080),
                  indent: screenHeight * (10 / 1080),
                  thickness: screenWidth * (2 / 1920),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.account_circle,
                      color: const Color(0xFFD7BDA6),
                      size: screenWidth * (28 / 1920),
                    ),
                    SizedBox(width: screenWidth * (10 / 1920)),
                    Tooltip(
                      message: "Log out of the admin interface",
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
                            colors: [Color(0xFFD7BDA6), Color(0xffAB7843)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => MyApp()),
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            padding: EdgeInsets.all(screenWidth * (5 / 1920)),
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
                            Icons.logout,
                            color: const Color(0xFF6d3914),
                            size: screenWidth * (21 / 1920),
                          ),
                          label: Text(
                            'LOG OUT',
                            style: GoogleFonts.poppins(
                              fontSize: screenWidth * (21 / 1920),
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF6d3914),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // MAIN CONTENT
          Expanded(
            child: Row(
              children: [
                // LEFT SIDE BAR
                Container(
                  width: screenWidth * (300 / 1920),
                  height: screenHeight - (screenHeight * (60 / 1080)),
                  decoration: const BoxDecoration(
                    color: Color(0xFF6d3914),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(4.5),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(screenWidth * (20 / 1920)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(
                          color: const Color(0xFFAB7843),
                          thickness: screenWidth * (2 / 1920),
                        ),
                        ...List.generate(_navItems.length, (index) {
                          return _buildNavItem(index, _navItems[index]);
                        }),
                        Divider(
                          color: const Color(0xFFAB7843),
                          thickness: screenWidth * (2 / 1920),
                        ),
                        SizedBox(height: screenHeight * (30 / 1080)),
                        Center(
                          child: Text(
                            'POWERED BY',
                            style: GoogleFonts.poppins(
                              fontSize: screenWidth * (20 / 1920),
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFFD7BDA6),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * (5 / 1080)),
                        Center(
                          child: ColorFiltered(
                            colorFilter: const ColorFilter.mode(
                              Color(0xFFD7BDA6),
                              BlendMode.srcATop,
                            ),
                            child: Image.asset(
                              'assets/images/trust_nexus_logo.png',
                              height: screenHeight * (120 / 1080),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const Spacer(flex: 2),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => MyApp()),
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFAB7843),
                            padding: EdgeInsets.symmetric(
                              vertical: screenHeight * (20 / 1080),
                              horizontal: screenWidth * (10 / 1920),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Icon(
                                Icons.home,
                                color: const Color(0xFFd7bda6),
                                size: screenWidth * (30 / 1920),
                              ),
                              SizedBox(width: screenWidth * (8 / 1920)),
                              Text(
                                'BACK TO HOME SCREEN',
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFFd7bda6),
                                  fontWeight: FontWeight.w500,
                                  fontSize: screenWidth * (15 / 1920),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // PAGE CONTENT
                Expanded(
                  child: Container(
                    color: const Color(0xFFD7BDA6),
                    child: _selectedPages[_selectedIndex],
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
    bool isSelected = _selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isSelected ? const Color(0xFF722F03) : const Color(0xFFDBC2AA),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side:
                isSelected
                    ? const BorderSide(color: Color(0x224c2b08), width: 10)
                    : BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title.toUpperCase(),
              style: GoogleFonts.plusJakartaSans(
                color:
                    isSelected
                        ? const Color(0xFFD7BDA6)
                        : const Color(0xFF4c2b08),
                fontSize: MediaQuery.of(context).size.width * (15 / 1920),
                fontWeight: FontWeight.w700,
              ),
            ),
            Icon(
              index == 0
                  ? Icons.dashboard
                  : index == 1
                  ? Icons.production_quantity_limits
                  : Icons.refresh,
              color:
                  isSelected
                      ? const Color(0xFFD7BDA6)
                      : const Color(0xFF4c2b08),
              size: MediaQuery.of(context).size.width * (30 / 1920),
            ),
          ],
        ),
      ),
    );
  }
}
