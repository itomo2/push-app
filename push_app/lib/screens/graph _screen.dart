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
  int graphlengh = 0;

  List<BarChartGroupData> _barGroups = [];
  //BarChartGroupDataはfl_chartの棒グラフで一つのグループを表すクラス。一つ一つのグラフの情報が入ってる

  void _changeweek(int yy) {
    setState(() {
      firstday = graphlengh > 7
          ? firstday.month == oldfirstday.month
                ? oldfirstday
                : firstday.subtract(Duration(days: firstday.weekday % 7))
          : firstday.add(Duration(days: 7 * yy));
      graphlengh = 7;
      _checkweek();
      _loadData("week");
      _barGroups = List.from(zero());
      _updateBarGroups();
    });
  }

  void _changemonth(int mm) {
    setState(() {
      if (graphlengh == 7) {
        oldfirstday = firstday;
      }
      firstday = DateTime(firstday.year, firstday.month + mm, 1);
      graphlengh = DateTime(firstday.year, firstday.month + 1, 0).day;
      _loadData("month");
      _barGroups = List.from(zero());
      _updateBarGroups();
    });
  }

  late List<double> situpcount;
  late List<double> pushupcount;
  late List<String> pushuptime;
  late List<String> situptime;
  late List<String> date;

  late bool othermonth;

  DateTime oldfirstday = DateTime.now();

  late List<bool> _togglelist;
  int oldindex = 0;

  DateTime firstday = DateTime.now().subtract(
    Duration(days: DateTime.now().weekday % 7),
  );

  List<BarChartGroupData> zero() {
    List<BarChartGroupData> _zeroBarGroups = List.generate(graphlengh, (i) {
      //generateは指定した個数の要素を持つリストを作る。長さは_allBarGroupsに依存
      //iはリストのインデックス、０からlengthよりも1少ない数まで増える
      final day = firstday.add(Duration(days: i));
      Color barColor = monthColor(day.month);
      return BarChartGroupData(
        x: i, //横軸位置
        barRods: [
          //ぼうの情報をもつ
          BarChartRodData(
            //棒一本を表すクラス
            toY: 0, //棒の高さ(アニメーションのためとりあえず０)
            color: barColor,
            width: graphlengh > 7 ? 8 : 50,
            borderRadius: BorderRadius.circular(2), //棒の角丸
          ),
        ],
      );
    });
    return _zeroBarGroups;
  }

  Color monthColor(int index) {
    switch (index) {
      case 1: // January - 冬の澄んだ青
        return const Color(0xFF5DADE2);
      case 2: // February - やわらかな藤色
        return const Color(0xFFB39DDB);
      case 3: // March - 若草の緑
        return const Color(0xFF81C784);
      case 4: // April - 桜のピンク
        return const Color(0xFFF8BBD0);
      case 5: // May - 新緑のグリーン
        return const Color(0xFF66BB6A);
      case 6: // June - 梅雨のアクアブルー
        return const Color(0xFF4FC3F7);
      case 7: // July - 夏の太陽イエロー
        return const Color(0xFFFFCA28);
      case 8: // August - 青空のスカイブルー
        return const Color(0xFF29B6F6);
      case 9: // September - 秋の黄金オレンジ
        return const Color(0xFFFFB74D);
      case 10: // October - 紅葉のディープオレンジ
        return const Color(0xFFD84315);
      case 11: // November - 木の温もりブラウン
        return const Color(0xFF8D6E63);
      case 12: // December - 冬夜のディープブルー
        return const Color(0xFF1565C0);
      default:
        return const Color(0xFFE0E0E0);
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

  void _checkweek() {
    if (firstday.day > firstday.add(Duration(days: 7)).day)
      othermonth = true;
    else
      othermonth = false;
  }

  void _loadData(String ii) {
    int gg = graphlengh;
    try {
      final keys = List.generate(
        gg,
        (i) => DateFormat('yyyy-MM-dd').format(firstday.add(Duration(days: i))),
      );
      date = List.generate(
        gg,
        (i) => DateFormat('dd').format(firstday.add(Duration(days: i))),
      );
      final infoData = keys.map((k) => box.get(k)).toList();
      //infoDataがnullでなければinfoData.pushupcount、nullならnullを返す
      //??でnullなら０を返すのでnullは返らない
      pushupcount = List.generate(
        gg,
        (i) => (infoData[i]?.pushupcount ?? 0).toDouble(),
      );
      situpcount = List.generate(
        gg,
        (i) => (infoData[i]?.situpcount ?? 0).toDouble(),
      );
      pushuptime = List.generate(
        gg,
        (i) => formatDuration(infoData[i]?.pushuptime ?? Duration.zero),
      );
      situptime = List.generate(
        gg,
        (i) => formatDuration(infoData[i]?.situptime ?? Duration.zero),
      );
    } catch (e) {
      pushupcount = List.filled(graphlengh, 0);
      situpcount = List.filled(graphlengh, 0);
      pushuptime = List.filled(graphlengh, '00:00');
      situptime = List.filled(graphlengh, '00:00');
    }
  }

  void _updateBarGroups() {
    Future.delayed(Duration(milliseconds: 0), () {
      setState(() {
        _barGroups = List.generate(
          zero().length,
          (i) => BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: _togglelist[0] ? pushupcount[i] : situpcount[i],
                color: zero()[i].barRods[0].color,
                width: zero()[i].barRods[0].width,
                borderRadius: zero()[i].barRods[0].borderRadius,
              ),
            ],
          ),
        );
      });
    });
  }

  double maxValue(List<double> list) {
    if (list.isEmpty) return 0; // 空なら0を返す
    return list.reduce((a, b) => a > b ? a : b);
  }

  void initState() {
    super.initState();
    if (box.get("graph") == null) {
      box.put("graph", false);
    }
    _togglelist = box.get("kakotoggle", defaultValue: [true, false]);
    oldindex = _togglelist[0] ? 0 : 1;
    _changeweek(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
        toolbarHeight: 70,
        backgroundColor: Color(0xFF2D2D35), // AppBarの背景色
        titleSpacing: 0, // タイトルの余白
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "${monthName(firstday.month)}-${firstday.year}",
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              icon: Icon(Icons.menu, size: 40, color: Colors.white),
              onPressed: () => showMenuDialog(context, month),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(color: Colors.black),
          IconButton(
            icon: Icon(Icons.circle),
            onPressed: () => _changemonth(0),
          ),
          Center(
            child: Column(
              children: [
                SizedBox(height: 30),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 35,
                    width: 365,
                    color: Color(0xFF2D2D35),
                    child: Center(
                      child: ToggleButtons(
                        splashColor: Colors.transparent,
                        constraints: BoxConstraints(
                          minWidth: 180,
                          minHeight: 30,
                        ),
                        renderBorder: false,
                        onPressed: (index) {
                          setState(() {
                            if (oldindex != index) {
                              _togglelist = List.generate(
                                _togglelist.length,
                                (i) => i == index,
                              );
                              box.put("kakotoggle", _togglelist);
                              oldindex = index;
                              graphlengh > 7 ? _changemonth(0) : _changeweek(0);
                            }
                          });
                        },
                        isSelected: _togglelist,
                        borderRadius: BorderRadius.circular(10),
                        fillColor: Color.fromARGB(255, 212, 255, 95),
                        children: [
                          Text(
                            'Push up',
                            style: TextStyle(
                              color: Colors.black /* Labels-Primary */,
                              fontSize: 13,
                              fontFamily: 'SF Pro',
                              fontWeight: _togglelist[0]
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                          Text(
                            'Sit up',
                            style: TextStyle(
                              color: Colors.black /* Labels-Primary */,
                              fontSize: 13,
                              fontFamily: 'SF Pro',
                              fontWeight: _togglelist[1]
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Flexible(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () =>
                            graphlengh > 7 ? _changemonth(-1) : _changeweek(-1),
                      ),
                      SizedBox(
                        width: 200,
                        child: Text(
                          "${DateFormat("dd").format(firstday)}~${DateFormat("dd").format(firstday.add(graphlengh > 7 ? Duration(days: graphlengh - 1) : (Duration(days: 6))))}",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            graphlengh > 7 ? _changemonth(1) : _changeweek(1),
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
                  child: SizedBox(
                    height: 500,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: GestureDetector(
                        onHorizontalDragEnd: (details) {
                          if (details.primaryVelocity! > 0) {
                            _changeweek(-1);
                          } else if (details.primaryVelocity! < 0) {
                            _changeweek(1);
                          }
                        },
                        // --- ピンチジェスチャー検出ハンドラ ---
                        onScaleStart: (details) {
                          // ピンチ開始時のスケール値を保存
                          _pinchStartScale = 1.0;
                        },
                        onScaleUpdate: (details) {
                          // ジェスチャー開始からのスケール変化量を計算
                          final double delta = details.scale - _pinchStartScale;
                          //.scaleはピンチの拡大率、1.0が基準だからpinch開始時のscaleを引く
                          // 1回のピンチで1回だけ処理（しきい値を使用）
                          if (!_pinchHandled) {
                            if (delta > 0.05) {
                              //0.05はデッドゾーンを決めている
                              // ピンチアウト（拡大）：次の週へ
                              _pinchHandled = true;
                              _changeweek(0);
                            } else if (delta < -0.05) {
                              // ピンチイン（縮小）：次の月へ
                              _pinchHandled = true;
                              _changemonth(0);
                            }
                          }
                        },
                        onScaleEnd: (details) {
                          // 新しいピンチジェスチャーを許可するためフラグをリセット
                          _pinchHandled = false;
                        },
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
                                maxValue(
                                  _togglelist[0] ? pushupcount : situpcount,
                                ) +
                                5,
                            barTouchData: BarTouchData(
                              enabled: true,
                              touchTooltipData: BarTouchTooltipData(
                                tooltipBgColor: Colors.black87,
                                getTooltipItem:
                                    (group, groupIndex, rod, rodIndex) {
                                      return BarTooltipItem(
                                        "${rod.toY.toInt()}${t("reps")}",
                                        //rodは一本の棒を表すオブジェクト、そのtoYを引き出している
                                        TextStyle(color: Colors.white),
                                      );
                                    },
                              ),
                            ),
                            //棒のタッチが有効になる
                            titlesData: FlTitlesData(
                              //titlesDataはグラフの軸ラベルやタイトルの表示方法をまとめた設定
                              leftTitles: AxisTitles(
                                //Y軸らべる
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30, //左側の余白
                                  getTitlesWidget: (double value, _) {
                                    int tt = value.toInt();
                                    int kk =
                                        maxValue(
                                              _togglelist[0]
                                                  ? pushupcount
                                                  : situpcount,
                                            ) >
                                            110
                                        ? 100
                                        : 10;
                                    if (tt % kk == 0 && tt != 0)
                                      return Text(
                                        '${tt}',
                                        style: TextStyle(color: Colors.white),
                                      );
                                    else
                                      return SizedBox.shrink();
                                  },
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
                                    DateTime daynow = firstday.add(
                                      Duration(days: value.toInt()),
                                    );
                                    if (graphlengh > 7) {
                                      if (daynow.day % 5 == 0)
                                        return Text(
                                          "${DateFormat("dd").format(daynow)}", //days.lengthは７
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                          ),
                                        );
                                      else
                                        return SizedBox.shrink();
                                    } else {
                                      return Text(
                                        "${DateFormat("dd").format(daynow)}.${DateFormat('E').format(daynow)}", //days.lengthは７
                                        //value.toIntで小数を正数に変換
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      );
                                    }
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
                          swapAnimationDuration: Duration(milliseconds: 1000),
                          swapAnimationCurve: Curves.easeOutCubic,
                          //アニメーション時の動きを決める
                        ),
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

// ピンチジェスチャーの状態
double _pinchStartScale = 1.0; // ピンチ開始時のスケール値を保存
bool _pinchHandled = false;    // ピンチごとに一度だけ処理を行うためのフラグ