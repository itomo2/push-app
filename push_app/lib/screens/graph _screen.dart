import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart'; // 日付フォーマット用パッケージをインポート
import 'package:push_app/main.dart';

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

  final List<Color> weekColors = [
    Colors.blueAccent,
    Colors.orangeAccent,
    Colors.greenAccent,
    Colors.purpleAccent,
    Colors.yellowAccent,
    Colors.pinkAccent,
    Colors.cyanAccent,
  ];

  late List<double> situpcount;
  late List<double> pushupcount;
  late List<String> pushuptime;
  late List<String> situptime;
  late List<String> date;

  DateTime sunday = DateTime.now().subtract(
    Duration(days: DateTime.now().weekday % 7),
  );

  void _loadData() {
    try {
      print('Start _loadData');
      final keys = List.generate(
        7,
        (i) => DateFormat('yyyy-MM-dd').format(sunday.add(Duration(days: i))),
      );
      date = List.generate(
        7,
        (i) => DateFormat('dd').format(sunday.add(Duration(days: i))),
      );
      final infoData = keys.map((k) => box.get(k)).toList();
      print('infoData: $infoData');
      //infoDataがnullでなければinfoData.pushupcount、nullならnullを返す
      //??でnullなら０を返すのでnullは返らない
      pushupcount = List.generate(
        7,
        (i) => (infoData[i]?.pushupcount ?? 0).toDouble(),
      );
      print("pushupcount:$pushupcount");
      situpcount = List.generate(
        7,
        (i) => (infoData[i]?.situpcount ?? 0).toDouble(),
      );
      pushuptime = List.generate(
        7,
        (i) => formatDuration(infoData[i]?.pushuptime ?? Duration.zero),
      );
      situptime = List.generate(
        7,
        (i) => formatDuration(infoData[i]?.situptime ?? Duration.zero),
      );
    } catch (e) {
      pushupcount = List.filled(7, 0);
      situpcount = List.filled(7, 0);
      pushuptime = List.filled(7, '00:00');
      situptime = List.filled(7, '00:00');
    }
  }

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
    _loadData();
    final List<BarChartGroupData> _zeroBarGroups = List.generate(
      7,
      (i) =>
          //generateは指定した個数の要素を持つリストを作る。長さは_allBarGroupsに依存
          //iはリストのインデックス、０からlengthよりも1少ない数まで増える
          BarChartGroupData(
            x: i, //横軸位置
            barRods: [
              //ぼうの情報をもつ
              BarChartRodData(
                //棒一本を表すクラス
                toY: 0, //棒の高さ(アニメーションのためとりあえず０)
                color: Color.fromARGB(255, 212, 255, 95),
                width: 18,
                borderRadius: BorderRadius.circular(2), //棒の角丸
              ),
            ],
          ),
    );

    _barGroups = List.from(_zeroBarGroups);
    //_zeroBarGroupsの内容を_barGroupsにコピー、zeroBarGroupsに影響を与えない代入（浅いコピー）

    Future.delayed(Duration(milliseconds: 250), () {
      //アニメーション
      //delayedを使うと指定した時間だけ待つ、この場合だとinit終わった後に実行させるようになってる
      setState(() {
        _barGroups = List.generate(
          _zeroBarGroups.length,
          (i) =>
              //generateは指定した個数の要素を持つリストを作る。長さは_allBarGroupsに依存
              //iはリストのインデックス、length-1まで増える
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: pushupcount[i],
                    color: weekColors[i],
                    //barRodsリストの一つ目のデータ（今回は各グループに棒が一本しかないので0)
                    width: _zeroBarGroups[i].barRods[0].width,
                    borderRadius: _zeroBarGroups[i].barRods[0].borderRadius,
                  ),
                ],
              ),
        );
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
            child: Column(
              children: [
                SizedBox(height: 30),
                Flexible(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () {},
                      ),
                      SizedBox(
                        width: 200,
                        child: Text(
                          "${DateFormat("dd").format(sunday)}~${DateFormat("dd").format(sunday.add(Duration(days: 6)))}",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  flex: 4,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: BarChart(
                        BarChartData(
                          gridData: FlGridData(
                            drawHorizontalLine: true, //水平線を描画
                            drawVerticalLine: false, //垂直線を非表示
                            getDrawingHorizontalLine: (_) =>
                                FlLine(color: Colors.white, strokeWidth: 0.5),
                          ),
                          alignment: BarChartAlignment.spaceAround,
                          //ぼうの間隔を均等に両端にも半分のスペースを設置
                          maxY:
                              (pushupcount.isNotEmpty
                                  ? pushupcount.reduce((a, b) => a > b ? a : b)
                                  : 0) +
                              5,
                          barTouchData: BarTouchData(enabled: true),
                          //棒のタッチが有効になる
                          titlesData: FlTitlesData(
                            //titlesDataはグラフの軸ラベルやタイトルの表示方法をまとめた設定
                            leftTitles: AxisTitles(
                              //Y軸らべる
                              sideTitles: SideTitles(
                                showTitles: false,
                              ), //数字ラベルを表示
                            ),
                            bottomTitles: AxisTitles(
                              //X軸ラベル
                              sideTitles: SideTitles(
                                showTitles: true, //ラベルを表示
                                getTitlesWidget: (double value, _) {
                                  //titlemetaは軸ラベル生成関数
                                  //metaはラベル描画に関する補助情報
                                  //valueは軸上の位置(0,1,2,~)
                                  final daynow = sunday.add(
                                    Duration(days: value.toInt()),
                                  );
                                  return Text(
                                    "${DateFormat("dd").format(daynow)}(${DateFormat('E').format(daynow)})", //days.lengthは７
                                    //value.toIntで小数を正数に変換
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
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
                        //アニメーション時の動きを決める
                      ),
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
}
