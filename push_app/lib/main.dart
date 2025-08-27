import 'package:flutter/material.dart'; //flutterのUI部品を使うためのパッケージをインポート
import 'package:intl/intl.dart'; // 日付フォーマット用パッケージをインポート

import 'package:proximity_sensor/proximity_sensor.dart'; // 近接センサーを使うためのパッケージをインポート
import 'package:table_calendar/table_calendar.dart'; // カレンダー表示用パッケージをインポート

import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';

class info{
  String subject;
  int count;

  info(this.subject, this.count);
}

class AlertDialogSample extends StatelessWidget {
  const AlertDialogSample(this.selectedDay);
  final DateTime selectedDay;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFD5FF5F),
      title: Text(
        "${DateFormat('  yyyy.M.d').format(selectedDay)}",
        textAlign: TextAlign.left,
        style: TextStyle(
          color: const Color(0xFF14151A) /* 背景 */,
          fontSize: 32,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
        ),
      ),
      // content: Icon(Icons.circle),//まるばつくん
      actions: <Widget>[
        Container(
          width: 250,
          height: 200,
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  width: 250,
                  height: 200,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFD5FF5F) /* メインテーマ */,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 20,
                top: 47,
                child: Text(
                  '腕立て伏せ：25回\n腹筋：50回',
                  style: TextStyle(
                    color: const Color(0xFF14151A) /* 背景 */,
                    fontSize: 25,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Positioned(
              //   left: 40,
              //   top: 33,
              //   child: SizedBox(
              //     width: 239,
              //     height: 61,
              //     child: Text(
              //       '2025.6.16',
              //       style: TextStyle(
              //         color: const Color(0xFF14151A) /* 背景 */,
              //         fontSize: 32,
              //         fontFamily: 'Inter',
              //         fontWeight: FontWeight.w600,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
        // Column(
        //   crossAxisAlignment: CrossAxisAlignment.center,
        //   children: <Widget>[
        //     TextButton(
        //       child: Text('Back'),
        //       onPressed: () {
        //         Navigator.pop(context);
        //       },
        //     ),
        //   ]
        // )
      ],
    );
  }
}
void main() {
  runApp(const PushUpApp()); // アプリのエントリーポイント。PushUpAppウィジェットを起動
}

class PushUpApp extends StatelessWidget {
  // アプリ全体のウィジェット（Stateless: 状態を持たない）
  const PushUpApp({super.key}); // コンストラクタ（keyはウィジェットの識別用）

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // マテリアルデザインのアプリを構築
      title: '腕立てカウンター', // アプリのタイトル
      home: Calendar(), // メイン画面としてCalendarウィジェットを表示
    );
  }
}

class Calendar extends StatefulWidget {
  // 状態を持つ画面ウィジェット
  const Calendar({super.key}); // コンストラクタ

  @override
  State<Calendar> createState() => _CalendarState(); // 状態管理クラスを生成
}

class _CalendarState extends State<Calendar> {
  // Calendar画面の状態管理クラス
  DateTime _focusedDay = DateTime.now(); // 現在フォーカスされている日付
  DateTime? _selectedDay; // 選択された日付（未選択ならnull）

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 画面のレイアウトを定義
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.centerLeft, // ← 強制的に左寄せ
          child: Column(
            children: [ // 上の余白
              Text(
                '   Target number of reps\n',
                style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),),
              ]
          ),
        ),
        titleSpacing: 0, // ← 左余白をなくす
        backgroundColor: Color(0xFF2D2D35), // AppBarの背景色
      ),

      body: Padding(
        padding: const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0), // 画面の余白を設定
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2000, 1, 1), // カレンダーの開始日
              lastDay: DateTime.utc(2200, 12, 31), // カレンダーの終了日
              focusedDay: _focusedDay, // 現在フォーカスされている日付
              selectedDayPredicate: (day) =>
                  isSameDay(_selectedDay, day), // 選択判定
              onDaySelected: (selectedDay, focusedDay) {
                showDialog<void>(
                  context: context,
                  builder: (_) {
                    return AlertDialogSample(selectedDay);
                  }
                );
                // 日付選択時の処理
                setState(() {
                  _selectedDay = selectedDay; // 選択日を更新
                  _focusedDay = focusedDay; // フォーカス日を更新
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => NextPage('KBOY')),
                  // );
                });
              },
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Colors.deepPurple, // 選択日の背景色
                  shape: BoxShape.circle, // 選択日の形状
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.orangeAccent, // 今日の背景色
                  shape: BoxShape.circle, // 今日の形状
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false, // フォーマット切替ボタン非表示
                titleCentered: true, // タイトル中央揃え
              ),
            ),
            const SizedBox(height: 20), // 余白
            OutlinedButton( // ボタンウィジェット
              onPressed: () { // ボタン押下時の処理
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PushUpCounterScreen(),
                  ), // PushUpCounterScreenへ遷移
                );
              },
              child: const Text('Start',style: TextStyle(fontSize: 50.0,),), // ボタンのラベル
            ),
          ],
        ),
      ),
    );
  }
}

class PushUpCounterScreen extends StatefulWidget {
  // 状態を持つ画面ウィジェット
  const PushUpCounterScreen({super.key}); // コンストラクタ

  @override
  State<PushUpCounterScreen> createState() => _PushUpCounterScreenState(); // 状態管理クラスを生成
}

class _PushUpCounterScreenState extends State<PushUpCounterScreen> {
  // 状態管理クラス
  int _pushUpCount = 0; // 腕立ての回数を保持する変数
  bool _isNear = false; // 近接センサーが近いかどうかを保持
  late Stream<bool> _proximityStream; // 近接センサーの状態を監視するストリーム

  @override
  void initState() {
    super.initState();
    _startListening(); // 初期化時に近接センサーの監視を開始
  }

  void debugyou() {
    setState((){
      _pushUpCount++;
    });
    if (_pushUpCount == 2) {
          // 2回目で何か処理（例：メッセージ表示）をしたい場合
          // ここに処理を書く
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ResultScreen()),
          );
        }
  }

  void _startListening() {
    // proximity_sensorのStream<int>をboolに変換
    _proximityStream = ProximitySensor.events.map(
      (event) => event > 0,
    ); // センサー値が0より大きければtrue
    _proximityStream.listen((isNear) {
      // センサーの状態変化を監視
      if (isNear && !_isNear) {
        // 近づいた瞬間のみカウントアップ（ステップ関数）
        setState(() {
          _pushUpCount++; // 腕立て回数を増やす
        });
        // if (_pushUpCount == 2) {
        //   // 2回目で何か処理（例：メッセージ表示）をしたい場合
        //   // ここに処理を書く
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(builder: (context) => const ResultScreen()),
        //   );
        // }
      }
      _isNear = isNear; // 状態を更新（過去の状態として残しておく）
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 画面のレイアウトを定義
      backgroundColor: Colors.black, // 背景色を黒に設定
      body: Center(
        // 中央に配置
        child: Column(
          // 縦方向にウィジェットを並べる
          mainAxisAlignment: MainAxisAlignment.center, // 中央揃え
          children: [
            const Text(
              'Push-ups', // タイトル表示
              style: TextStyle(fontSize: 32, color: Colors.white), // 文字サイズと色
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 185,
              child: Text(
              '$_pushUpCount', // 腕立て回数を表示
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFFD5FF5F) /* メインテーマ */,
                  fontSize: 128,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ), // 余白
            const SizedBox(height: 40), // 余白
            SizedBox(
              width: 304,
              height: 69,
              child: Text(
                'スマホを地面に置いて、\n胸を近づけるとカウントされます',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white /* 文字 */,
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: debugyou, 
              child: Text('debug') 
            ),
          ],
        ),
      ),
    );
  }
}

class ResultScreen extends StatefulWidget {
  // 状態を持つ画面ウィジェット
  const ResultScreen({super.key}); // コンストラクタ

  @override
  State<ResultScreen> createState() => _ResultScreenState(); // 状態管理クラスを生成
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 画面のレイアウトを定義
      backgroundColor: const Color(0xFFD5FF5F), // 背景色を黒に設定
      body: Center(
        // 中央に配置
        child: Column(
          // 縦方向にウィジェットを並べる
          mainAxisAlignment: MainAxisAlignment.center, // 中央揃え
          children: [
            Icon(Icons.task_alt, size: 100, color: Colors.black,),
            SizedBox(
              height: 20,
            ),// タイトル表示
            const Text(
              "Finish!", // タイトル表示
              style: TextStyle(fontSize: 32, color: Colors.black), // 文字サイズと色
            ),
            const SizedBox(height: 20), // 余白
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // ボタンの背景色
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20), // ボタンの内側の余白
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // ボタンの角を丸くする
                ),
              ),
              // ボタンウィジェット
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Calendar()),
                  (Route<dynamic> route) => false,
                );
              },
              child: 
              const Text('Back to Calendar',style: TextStyle(fontSize: 20.0,color: Colors.white),), // ボタンのラベル
            ),
          ],
        ),
      ),
    );
  }
}
