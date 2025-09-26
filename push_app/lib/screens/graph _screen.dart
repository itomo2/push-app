import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:async';

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

  List<BarChartGroupData> _barGroups = [];
  //BarChartGroupDataはfl_chartの棒グラフで一つのグループを表すクラス。一つ一つのグラフの情報が入ってる

  final List<double> _targetValues = [8, 10, 14, 15, 13, 10, 6];
  //それぞれのグラフが到達する高さ

  final List<BarChartGroupData> _allBarGroups = [
    BarChartGroupData(
      x: 0, //横軸位置
      barRods: [
        //ぼうの情報をもつ
        BarChartRodData(
          //棒一本を表すクラス
          toY: 0, //棒の高さ(アニメーションのためとりあえず０)
          color: Colors.lightBlueAccent,
          width: 18,
          borderRadius: BorderRadius.circular(4), //棒の角丸
        ),
      ],
    ),
    BarChartGroupData(
      x: 1,
      barRods: [
        BarChartRodData(
          toY: 0,
          color: Colors.orangeAccent,
          width: 18,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    ),
    BarChartGroupData(
      x: 2,
      barRods: [
        BarChartRodData(
          toY: 0,
          color: Colors.greenAccent,
          width: 18,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    ),
    BarChartGroupData(
      x: 3,
      barRods: [
        BarChartRodData(
          toY: 0,
          color: Colors.purpleAccent,
          width: 18,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    ),
    BarChartGroupData(
      x: 4,
      barRods: [
        BarChartRodData(
          toY: 0,
          color: Colors.yellowAccent,
          width: 18,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    ),
    BarChartGroupData(
      x: 5,
      barRods: [
        BarChartRodData(
          toY: 0,
          color: Colors.redAccent,
          width: 18,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    ),
    BarChartGroupData(
      x: 6,
      barRods: [
        BarChartRodData(
          toY: 0,
          color: Colors.tealAccent,
          width: 18,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    ),
  ];

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

    _barGroups = List.from(_allBarGroups);
    //_allBarGroupsの内容を_barGroupsにコピー、allBarGroupsに影響を与えない代入（浅いコピー）

    Future.delayed(Duration(milliseconds: 250), () {
      //アニメーション
      //delayedを使うと指定した時間だけ待つ、この場合だとinit終わった後に実行させるようになってる
      setState(() {
        _barGroups = List.generate(_allBarGroups.length, (i) {
          //generateは指定した個数の要素を持つリストを作る。長さは_allBarGroupsに依存
          //iはリストのインデックス、length-1まで増える
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: _targetValues[i], //前で作った目標長さ
                color: _allBarGroups[i].barRods[0].color,
                //barRodsリストの一つ目のデータ（今回は各グループに棒が一本しかないので0)
                width: 30,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        });
      });
    });
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  //ぼうの間隔を均等に両端にも半分のスペースを設置
                  maxY: 20,
                  barTouchData: BarTouchData(enabled: true),
                  //棒のタッチが有効になる
                  titlesData: FlTitlesData(
                    //titlesDataはグラフの軸ラベルやタイトルの表示方法をまとめた設定
                    leftTitles: AxisTitles(
                      //Y軸らべる
                      sideTitles: SideTitles(showTitles: true), //数字ラベルを表示
                    ),
                    bottomTitles: AxisTitles(
                      //X軸ラベル
                      sideTitles: SideTitles(
                        showTitles: true, //ラベルを表示
                        getTitlesWidget: (double value, _) {
                          //titlemetaは軸ラベル生成関数
                          //metaはラベル描画に関する補助情報
                          //valueは軸上の位置(0,1,2,~)
                          const days = [
                            'Mon',
                            'Tue',
                            'Wed',
                            'Thu',
                            'Fri',
                            'Sat',
                            'Sun',
                          ];
                          return Text(
                            days[value.toInt() % days.length], //days.lengthは７
                            //value.toIntで小数を正数に変換
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          );
                        },
                        interval: 1, //１ずつラベルを表示
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _barGroups,
                ),
                swapAnimationDuration: Duration(milliseconds: 1200),
                swapAnimationCurve: Curves.easeOutCubic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
