import 'package:flutter/material.dart';
import 'package:push_app/main.dart';
import 'package:proximity_sensor/proximity_sensor.dart'; // 近接センサーを使うためのパッケージをインポート
import 'dart:async'; // StreamSubscription用
import 'package:intl/intl.dart'; // 日付フォーマット用パッケージをインポート
import 'package:push_app/screens/screens.dart';

class CounterScreen extends StatefulWidget {
  // 腕立てカウンター画面（状態を持つ）
  CounterScreen(this.subject, this.selectedIndex);
  final String subject; // コンストラクタ
  final int selectedIndex;

  @override
  State<CounterScreen> createState() =>
      _CounterScreenState(subject, selectedIndex); // 状態管理クラスを生成
}

class _CounterScreenState extends State<CounterScreen> {
  // 状態管理クラス
  _CounterScreenState(this.subject, this.selectedIndex);
  String subject;
  int selectedIndex;
  late Duration time = Duration.zero, goaltime;
  late int count, goalcount;

  bool _isNear = false; // 近接センサーが近いかどうかを保持
  late Stream<bool> _proximityStream; // 近接センサーの状態を監視するストリーム
  late StreamSubscription<bool> _proximitySubscription; // 購読用変数

  final Stopwatch _stopwatch = Stopwatch(); //経過時間を測る
  late Timer _timer; //１秒ごとにUI更新
  String elapsedTime = "00:00"; //表示用の文字列

  @override
  void initState() {
    //ページを開いた時に一度だけ実行する関数
    super.initState();
    _startListening();

    final key = DateFormat('yyyy-MM-dd').format(DateTime.now()); // 日付をキーに変換
    final infoData = box.get(key); // Hiveからデータ取得

    // カウント取得（subjectによって分岐）
    if (subject == 'Push-up') {
      count = infoData?.pushupcount ?? 0;
      time = infoData?.pushuptime ?? Duration.zero;
    } else {
      count = infoData?.situpcount ?? 0;
      time = infoData?.situptime ?? Duration.zero;
    }

    // 目標回数取得（subjectによって分岐、なければ20）
    goalcount =
        box.get(
          subject == 'Push-up' && selectedIndex == 0
              ? "pushUpGoalCount"
              : "sitUpGoalCount",
        ) ??
        20;
    goaltime = parseDuration(
      box.get(
        subject == 'Push-up' && selectedIndex == 1
            ? "pushUpGoalTime"
            : "sitUpGoalTime",
      ),
    );

    _stopwatch.start(); //ストップウォッチ開始
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      //１秒ごとに実行
      setState(() {
        elapsedTime = formatDuration(
          _stopwatch.elapsed,
        ); /*elapsedTimeを更新（１秒ごと）、_stopwatch.elapsedを_formatDurationに渡して
              mm:ss形式の文字列に変換、そしてelapsedTime（文字列型）に代入*/
      });
    });
  }

  void _startListening() {
    _proximityStream = ProximitySensor.events.map((event) => event > 0);
    _proximitySubscription = _proximityStream.listen((isNear) {
      if (isNear && !_isNear) {
        setState(() {
          count++;
        });
      }
      _isNear = isNear; //過去データ
    });
  }

  @override
  void dispose() {
    _proximitySubscription.cancel(); // センサー購読を停止
    super.dispose();
    _proximitySubscription.cancel();
    _timer.cancel();
    _stopwatch.stop();
  }

  Future<void> setdata() async {
    // データ保存処理
    late int anotherCount;
    late Duration anotherTime;
    final key = DateFormat('yyyy-MM-dd').format(DateTime.now()); // 日付をキーに変換
    try {
      final infoData = box.get(key); // Hiveからデータ取得
      if (subject == 'Push-up') {
        anotherCount = infoData?.situpcount ?? 0;
        anotherTime = infoData?.situptime ?? Duration.zero;
      } else {
        anotherCount = infoData?.pushupcount ?? 0; // データがなければ0
        anotherTime = infoData?.pushuptime ?? Duration.zero; // データがなければ0
      }
    } catch (e) {
      anotherCount = 0;
    }

    late info infoObject;
    if (subject == 'Push-up') {
      infoObject = info(count, anotherCount, time, anotherTime);
    } else {
      infoObject = info(anotherCount, count, anotherTime, time);
    }
    box.put(key, infoObject); // Hiveに保存
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // 背景色を黒に設定
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 中央揃え
          children: [
            Text(
              '$subject', // タイトル表示
              style: const TextStyle(
                fontSize: 32,
                color: Colors.white,
              ), // 文字サイズと色
            ),
            const SizedBox(height: 20), // 余白
            if (selectedIndex == 0) ...[
              SizedBox(
                width: double.infinity,
                child: Text(
                  '$count', // 回数を表示
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFFD5FF5F), // メインテーマ色
                    fontSize: 128, // 文字サイズ
                    fontFamily: 'Inter', // フォント
                    fontWeight: FontWeight.w600, // 太字
                  ),
                ),
              ),
              const SizedBox(height: 40), // 余白
              SizedBox(
                //説明文
                width: 304,
                height: 69,
                child: subject == 'Push-up'
                    ? Text(
                        'スマホを地面に置いて、\n胸を近づけるとカウントされます', // 説明文
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white, // 文字色
                          fontSize: 14, // 文字サイズ
                          fontFamily: 'Inter', // フォント
                          fontWeight: FontWeight.w600, // 太字
                        ),
                      )
                    : Text(
                        'スマホを地面に置いて、\n背中を近づけるとカウントされます', // 説明文
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white, // 文字色
                          fontSize: 14, // 文字サイズ
                          fontFamily: 'Inter', // フォント
                          fontWeight: FontWeight.w600, // 太字
                        ),
                      ),
              ),
              if (count >= goalcount)
                ElevatedButton(
                  // ボタンウィジェット
                  onPressed: () {
                    setdata();
                    // ボタン押下時の処理
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResultScreen(),
                      ), // 結果画面へ遷移
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(
                      255,
                      212,
                      255,
                      95,
                    ), // ボタンの背景色
                    padding: const EdgeInsets.symmetric(
                      horizontal: 100,
                      vertical: 15,
                    ), // ボタンの内側の余白
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50), // ボタンの角を丸くする
                    ),
                  ),
                  child: const Text(
                    'Finish',
                    style: TextStyle(fontSize: 30.0, color: Colors.black),
                  ), // ボタンのラベル
                ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: Text(
                  elapsedTime,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFFD5FF5F), // メインテーマ色
                    fontSize: 128, // 文字サイズ
                    fontFamily: 'Inter', // フォント
                    fontWeight: FontWeight.w600, // 太字
                  ),
                ),
              ),
              if (_stopwatch.elapsed + time >= goaltime)
                ElevatedButton(
                  // ボタンウィジェット
                  onPressed: () {
                    time += _stopwatch.elapsed;
                    setdata();
                    // ボタン押下時の処理
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResultScreen(),
                      ), // 結果画面へ遷移
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(
                      255,
                      212,
                      255,
                      95,
                    ), // ボタンの背景色
                    padding: const EdgeInsets.symmetric(
                      horizontal: 100,
                      vertical: 15,
                    ), // ボタンの内側の余白
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50), // ボタンの角を丸くする
                    ),
                  ),
                  child: const Text(
                    'Finish',
                    style: TextStyle(fontSize: 30.0, color: Colors.black),
                  ), // ボタンのラベル
                ),
              const SizedBox(height: 40), // 余白
            ],
          ],
        ),
      ),
    );
  }
}
