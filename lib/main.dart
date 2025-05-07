import 'package:flutter/material.dart';
import 'package:pos_desktop/pages/interface.dart';

//providers
import 'package:provider/provider.dart';
import 'package:pos_desktop/podos/receipt.dart';
import 'package:pos_desktop/podos/category.dart';
import 'package:pos_desktop/podos/menuitem.dart';

// provider state management is used in the usermodule only;
// the admin module uses setState functions across; with no consumers and providers etc -- its the old code refactored to match theme!
// 👍

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ReceiptProvider()),
        ChangeNotifierProvider(create: (context) => CategoryProvider()),
        ChangeNotifierProvider(create: (context) => MenuItemProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexus Desktop PoS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
      ),
      debugShowCheckedModeBanner: false,
      home: const InterfacePage(),
    );
  }
}
