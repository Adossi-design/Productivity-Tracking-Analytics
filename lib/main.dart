import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/time_tracker_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(ProductivityTrackingApp());
}

class ProductivityTrackingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProductivityRepository(),
        ),
      ],
      child: MaterialApp(
        title: 'Project & Task Time Tracking System',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: HomeScreen(),
      ),
    );
  }
}
