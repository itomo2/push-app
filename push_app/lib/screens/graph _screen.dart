import 'package:flutter/material.dart';

class GraphScreen extends StatefulWidget {
  GraphScreen(this.month);
  final int month;

  @override
  State<GraphScreen> createState() => _GraphScreenState(month);
}

class _GraphScreenState extends State<GraphScreen> {
  _GraphScreenState(this.month);

  int month;
  late String monthname;

  String monthName(int k) {
    switch (k) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return 'Unknown';
    }
  }

  void initState() {
    super.initState();
    monthname = monthName(month);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF2D2D35), // AppBarの背景色
        titleSpacing: 0, // タイトルの余白
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "$monthname Achievements", // 目標回数ラベル
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(color: Colors.black),
          Center(
            child: Text('ここにグラフを表示するっピ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
