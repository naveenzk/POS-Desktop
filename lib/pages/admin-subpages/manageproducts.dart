import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pos_desktop/db/database_helper.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:file_picker/file_picker.dart';

class DishPage extends StatefulWidget {
  const DishPage({super.key});

  @override
  State<DishPage> createState() => _DishPageState();
}

class _DishPageState extends State<DishPage> {
  List<Map<String, dynamic>> dishes = [];
  bool _isLoading = false;

  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadDishes();
  }

  Future<void> _loadDishes() async {
    setState(() => _isLoading = true);
    final data = await _dbHelper.fetchMenuItems();
    setState(() {
      dishes =
          data.map((item) {
            return {
              "sno": item['product_id'],
              "name": item['product_name'],
              "price": "RS ${(item['price'].round())}",
              "category": item['category_name'],
              "image_path": item['image_path'],
            };
          }).toList();
      _isLoading = false;
    });
  }

  void _editDish(int productId) async {
    BuildContext parentContext = context;
    // Find dish by productId
    Map<String, dynamic>? dish = dishes.firstWhere(
      (dish) => dish['sno'] == productId,
      orElse: () => {},
    );

    String imagePath = "";
    TextEditingController imagePathController = TextEditingController(
      text: imagePath,
    );

    if (dish.isEmpty) {
      return; // Exit if no dish found
    }

    TextEditingController nameController = TextEditingController(
      text: dish['name'],
    );
    TextEditingController priceController = TextEditingController(
      text: dish['price'].replaceAll("RS ", ""),
    );

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          child: SizedBox(
            width: 450,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Edit Item",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF264653),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Item Name",
                      prefixIcon: const Icon(
                        Icons.breakfast_dining,
                        color: Color(0xFF4c2b08),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: "Price",
                      prefixIcon: const Icon(
                        Icons.money,
                        color: Color(0xFFE76F51),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty && double.tryParse(value) == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Only numeric values are allowed!"),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 2),
                          ),
                        );
                        priceController.clear(); // Clear invalid input
                      }
                    },
                  ),
                  const SizedBox(height: 10),

                  // FILEPICKER
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          FilePickerResult? result = await FilePicker.platform
                              .pickFiles(type: FileType.image);

                          if (result != null &&
                              result.files.single.path != null) {
                            setState(() {
                              imagePath = result.files.single.path!;
                              imagePathController.text = imagePath;
                            });
                          }
                        },
                        icon: const Icon(Icons.image),
                        label: const Text(
                          "Choose Image...",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4c2b08),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: imagePathController,
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: "No file selected",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          // Update in Database
                          // Save image to documents directory
                          String windowsPath = "";
                          if (imagePathController.text.isNotEmpty) {
                            String newImagePath = await _dbHelper
                                .saveImageToAppDir(imagePathController.text);
                            windowsPath = newImagePath.replaceAll(r'\', r'/');
                          }

                          await _dbHelper.updateItem(
                            productId,
                            nameController.text,
                            priceController.text.isEmpty
                                ? '0'
                                : priceController
                                    .text, // Handle null/empty price
                            windowsPath,
                          );

                          // Refresh UI
                          _loadDishes();

                          // Close the dialog first
                          Navigator.pop(context);

                          // Show success message after closing the dialog
                          ScaffoldMessenger.of(parentContext).showSnackBar(
                            const SnackBar(
                              content: Text("Item edited successfully!"),
                            ),
                          );
                        },
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: const Text(
                          "Save",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4c2b08),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Group dishes by category
    Map<String, List<Map<String, dynamic>>> groupedDishes = {};
    for (var dish in dishes) {
      if (!groupedDishes.containsKey(dish["category"])) {
        groupedDishes[dish["category"]] = [];
      }
      groupedDishes[dish["category"]]!.add(dish);
    }

    return Scaffold(
      backgroundColor: Color(0xFFd7bda6),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Color(0xFF4c2b08)),
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            groupedDishes.entries.map((entry) {
                              String category = entry.key;
                              List<Map<String, dynamic>> categoryDishes =
                                  entry.value;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Category Heading
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    child: Text(
                                      category, // Category Name
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF4c2b08),
                                      ),
                                    ),
                                  ),
                                  Table(
                                    columnWidths: const {
                                      0: FixedColumnWidth(50), // S.No
                                      1: FlexColumnWidth(), // Dish Name (Auto Adjust)
                                      2: FixedColumnWidth(140), // Price
                                      3: FixedColumnWidth(170), // Category
                                      4: FixedColumnWidth(
                                        160,
                                      ), // Actions (Reduced Width)
                                    },
                                    border: TableBorder.all(
                                      color: Colors.black45,
                                    ),
                                    children: [
                                      // Table Header
                                      TableRow(
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF6d3914),
                                        ),
                                        children: [
                                          TableCell(
                                            child: Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: Text(
                                                "S.No",
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                            ),
                                          ),
                                          TableCell(
                                            child: Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: Text(
                                                "Item Name",
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                    ),
                                              ),
                                            ),
                                          ),
                                          TableCell(
                                            child: Padding(
                                              padding: EdgeInsets.all(8),
                                              child: Text(
                                                "Price",
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                    ),
                                              ),
                                            ),
                                          ),
                                          TableCell(
                                            child: Padding(
                                              padding: EdgeInsets.all(8),
                                              child: Text(
                                                "Category",
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                    ),
                                              ),
                                            ),
                                          ),
                                          TableCell(
                                            child: Padding(
                                              padding: EdgeInsets.all(8),
                                              child: Text(
                                                "Actions",
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Table Rows for each dish in the category
                                      ...categoryDishes.asMap().entries.map((
                                        entry,
                                      ) {
                                        int categoryIndex =
                                            entry.key +
                                            1; // Start numbering from 1
                                        Map<String, dynamic> dish = entry.value;
                                        return TableRow(
                                          decoration: BoxDecoration(
                                            color:
                                                categoryIndex.isEven
                                                    ? const Color(
                                                      0xFFe8d9c4,
                                                    ) // lighter beige
                                                    : const Color(
                                                      0xFFc6a98d,
                                                    ), // soft brown
                                          ),
                                          children: [
                                            TableCell(
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                child: Text(
                                                  "$categoryIndex",
                                                  style:
                                                      GoogleFonts.plusJakartaSans(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: const Color(
                                                          0xFF4c2b08,
                                                        ),
                                                      ),
                                                ),
                                              ),
                                            ),
                                            TableCell(
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                child: Text(
                                                  dish["name"],
                                                  style:
                                                      GoogleFonts.plusJakartaSans(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: const Color(
                                                          0xFF4c2b08,
                                                        ),
                                                      ),
                                                ),
                                              ),
                                            ),
                                            TableCell(
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                child: Text(
                                                  dish["price"],
                                                  style:
                                                      GoogleFonts.plusJakartaSans(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: const Color(
                                                          0xFF4c2b08,
                                                        ),
                                                      ),
                                                ),
                                              ),
                                            ),
                                            TableCell(
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                child: Text(
                                                  dish["category"],
                                                  style:
                                                      GoogleFonts.plusJakartaSans(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: const Color(
                                                          0xFF4c2b08,
                                                        ),
                                                      ),
                                                ),
                                              ),
                                            ),
                                            TableCell(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                    ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Expanded(
                                                      child: ElevatedButton.icon(
                                                        onPressed:
                                                            () => _editDish(
                                                              dish["sno"],
                                                            ),
                                                        icon: const Icon(
                                                          Icons.edit,
                                                          size: 16,
                                                          color: Colors.white,
                                                        ),
                                                        label: const Text(
                                                          "Edit",
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Color(
                                                                0xFF4c2b08,
                                                              ).withOpacity(
                                                                0.8,
                                                              ),
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 8,
                                                                vertical: 4,
                                                              ),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  6,
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
                                        );
                                      }),
                                    ],
                                  ),
                                ],
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
    );
  }
}
