import 'package:flutter/material.dart'; // FlutterのUI部品を使うためのパッケージをインポート
import 'package:intl/date_time_patterns.dart';
import 'package:intl/intl.dart'; // 日付フォーマット用パッケージをインポート

import 'package:proximity_sensor/proximity_sensor.dart'; // 近接センサーを使うためのパッケージをインポート
import 'package:table_calendar/table_calendar.dart'; // カレンダー表示用パッケージをインポート
import 'dart:async'; // StreamSubscription用

import 'package:hive/hive.dart'; // Hive（ローカルDB）を使うためのパッケージをインポート
import 'package:hive_flutter/hive_flutter.dart'; // HiveのFlutter用パッケージをインポート
part 'main.g.dart'; // Hive Generator用（TypeAdapter自動生成ファイル）

// infoクラス: 運動名(subject)と回数(count)を保持するデータモデル
@HiveType(typeId: 0) // Hive用の型IDを指
class info {
  @HiveField(0) // Hiveで保存するフィールド番号
  int pushupcount; // 運動名（例：腕立て伏せ）
  @HiveField(1) // Hiveで保存するフィールド番号
  int situpcount; // 回数

  info(this.pushupcount, this.situpcount); // コンストラクタ
}

late Box box; // HiveのBox（データ保存領域）をグローバル変数として宣言
late List<dynamic> highlightDays = [
];

void main() async {
  // Hive初期化 & info型の保存を可能にする
  await Hive.initFlutter(); // Hiveの初期化（Flutter用）
  Hive.registerAdapter(infoAdapter()); // info型のアダプターを登録（これがないと保存時にクラッシュ）
  box = await Hive.openBox('app_info'); // 'pushup_info'という名前のBoxを開く（なければ作成）
  runApp(const PushApp()); // アプリのエントリーポイント。PushAppウィジェットを起動
}

class AlertDialogSample extends StatelessWidget { // 日付選択時に表示するダイアログ
  const AlertDialogSample(this.selectedDay); // コンストラクタ
  final DateTime selectedDay; // 選択された日付

  @override
  Widget build(BuildContext context) { // ダイアログのUIを構築
    int pushupcount,situpcount;
    
      try {
        final key = DateFormat('yyyy-MM-dd').format(selectedDay); // 日付をキーに変換
        final infoData = box.get(key); // Hiveからデータ取得
        pushupcount = infoData?.pushupcount ?? 0;
        situpcount = infoData?.situpcount ?? 0; // データがなければ0
      } catch (e) {
        pushupcount = 0;
        situpcount = 0;
      }
    return AlertDialog(
      backgroundColor: const Color(0xFFD5FF5F), // ダイアログの背景色
      title: Text(
        "${DateFormat(' yyyy.M.d').format(selectedDay)}", // 選択日を表示
        textAlign: TextAlign.left, // 左寄せ
        style: TextStyle(
          color: const Color(0xFF14151A), // 文字色
          fontSize: 32, // 文字サイズ
          fontFamily: 'Inter', // フォント
          fontWeight: FontWeight.w600, // 太字
        ),
      ),
      // content: Icon(Icons.circle), // アイコン（未使用）
      actions: [
        Align(
          alignment: Alignment.topLeft,
          child: Text(
            '  Push-up：$pushupcount回\n  Sit-up    ：$situpcount回', // サンプルデータ（本来は保存データを表示する）
            style: TextStyle(
              color: const Color(0xFF14151A), // 文字色
              fontSize: 20, // 文字サイズ
              fontFamily: 'Inter', // フォント
            fontWeight: FontWeight.w500, // 太字
            ),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }
}

class PushApp extends StatelessWidget { // アプリ全体のウィジェット（Stateless: 状態を持たない）
  const PushApp({super.key}); // コンストラクタ（keyはウィジェットの識別用）

  @override
  Widget build(BuildContext context) { // アプリのUI構築
    return const MaterialApp(
      title: 'PushApp', // アプリのタイトル
      home: Calendar(), // メイン画面としてCalendarウィジェットを表示
    );
  }
}

class Calendar extends StatefulWidget { // カレンダー画面（状態を持つ）
  const Calendar({super.key}); // コンストラクタ

  @override
  State<Calendar> createState() => _CalendarState(); // 状態管理クラスを生成
}

class _CalendarState extends State<Calendar> { // Calendar画面の状態管理クラス



  DateTime _focusedDay = DateTime.now(); // 現在フォーカスされている日付
  DateTime? _selectedDay; // 選択された日付（未選択ならnull）

  int _pushUpGoalCount = box.get('pushUpGoalCount', defaultValue: 20); // 腕立て伏せの目標回数
  int _sitUpGoalCount = box.get('sitUpGoalCount', defaultValue: 20);  // 腹筋の目標回数

  bool _isPushUpEditing = false; // 腕立て伏せ編集モード
  bool _isSitUpEditing = false;  // 腹筋編集モード

  TextEditingController _pushUpController = TextEditingController(); // 腕立て伏せ編集用コントローラー
  TextEditingController _sitUpController = TextEditingController();  // 腹筋編集用コントローラー

    
  @override
  void dispose() { // ウィジェット破棄時の処理
    _pushUpController.dispose(); // コントローラーの破棄
    _sitUpController.dispose();  // コントローラーの破棄
    super.dispose();
  }

  void _startPushUpEditing() { // 編集モード開始
    setState(() {
      _isPushUpEditing = true; // 編集モードON
      _isSitUpEditing = false; // 腹筋編集モードOFF
      _pushUpController.text = _pushUpGoalCount.toString(); // 現在の目標回数をテキストフィールドにセット
    });
  }

  void _startSitUpEditing() { // 編集モード開始
    setState(() {
      _isSitUpEditing = true; // 編集モードON
      _isPushUpEditing = false; // 腕立て伏せ編集モードOFF
      _sitUpController.text = _sitUpGoalCount.toString(); // 現在の目標回数をテキストフィールドにセット
    });
  }

  void _submitPushUpEditing() { // 編集内容を確定
    final input = _pushUpController.text; // 入力値取得
    final parsed = int.tryParse(input); // 整数に変換
    if (parsed != null && parsed > 0) { // 正の整数なら
      setState(() {
        _pushUpGoalCount = parsed; // 目標回数を更新
        box.put('pushUpGoalCount', parsed);
        _isPushUpEditing = false; // 編集モードOFF
      });
    } else {
      // 無効な入力の場合、アラート表示（SnackBar）
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('正の整数を入力してください')),
      );
    }
  }

  void _submitSitUpEditing() { // 編集内容を確定
    final input = _sitUpController.text; // 入力値取得
    final parsed = int.tryParse(input); // 整数に変換
    if (parsed != null && parsed > 0) { // 正の整数なら
      setState(() {
        _sitUpGoalCount = parsed; // 目標回数を更新
        box.put('sitUpGoalCount', parsed);
        _isSitUpEditing = false; // 編集モードOFF
      });
    } else {
      // 無効な入力の場合、アラート表示（SnackBar）
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('正の整数を入力してください')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    highlightDays = box.get("highlight") ?? []; // 画面のUI構築
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: 150, // AppBarの高さ
        backgroundColor: Color(0xFF2D2D35), // AppBarの背景色
        titleSpacing: 0, // タイトルの余白
        title: Padding(
          padding: const EdgeInsets.only(left: 30), // 左に余白追加
          child:Align(
            alignment: Alignment.centerLeft, // 左寄せ
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // 左寄せ
              children: [
                Text(
                  'Target number of reps', // 目標回数ラベル
                  style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
                ),    
                _isPushUpEditing // 編集モードかどうかで表示切替
                ? Row(children: [
                  Text("Push-up:  ", style: TextStyle(color: Colors.white70, fontSize: 20),),
                  SizedBox(
                    width: 60,
                    child: 
                    TextField(
                      controller: _pushUpController, // 入力コントローラー
                      autofocus: true, // 自動フォーカス
                      keyboardType: TextInputType.number, // 数値入力
                      style: TextStyle(color: Colors.white70, fontSize: 20,), // テキストスタイル
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)), // 下線
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)), // フォーカス時の下線
                        isDense: true, // コンパクト表示
                        contentPadding: EdgeInsets.symmetric(vertical: 8), // パディング
                      ),
                      onSubmitted: (_) => _submitPushUpEditing(), // Enterで確定
                    ),
                  ),
                  Text('reps', style: TextStyle(color: Colors.white70, fontSize: 20),),
                  IconButton(
                    icon: Icon(Icons.check, color: Colors.white), // 確定ボタン
                    onPressed: _submitPushUpEditing, // 確定処理
                  ),
                ])
                : Row(children: [
                  Text(
                    'Push-up:  $_pushUpGoalCount reps', // 目標回数表示
                    style: TextStyle(color: Colors.white70, fontSize: 20),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.white), // 編集ボタン
                    onPressed: _startPushUpEditing, // 編集開始
                  ),
                ],),
                _isSitUpEditing // 編集モードかどうかで表示切替
                ? Row(children: [
                  Text('Sit-up:  ', style: TextStyle(color: Colors.white70, fontSize: 20),),
                  SizedBox(
                    width: 60,
                      child: TextField(
                      controller: _sitUpController, // 入力コントローラー
                      autofocus: true, // 自動フォーカス
                      keyboardType: TextInputType.number, // 数値入力
                      style: TextStyle(color: Colors.white70, fontSize: 20,), // テキストスタイル
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)), // 下線
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)), // フォーカス時の下線
                        isDense: true, // コンパクト表示
                        contentPadding: EdgeInsets.symmetric(vertical: 8), // パディング
                      ),
                      onSubmitted: (_) => _submitSitUpEditing(), // Enterで確定
                    ),
                  ),
                  Text('reps', style: TextStyle(color: Colors.white70, fontSize: 20),),
                  IconButton(
                    icon: Icon(Icons.check, color: Colors.white), // 確定ボタン
                    onPressed: _submitSitUpEditing, // 確定処理
                  ),
                ])
                : Row(children: [
                  Text(
                    'Sit-up:  $_sitUpGoalCount reps', // 目標回数表示
                    style: TextStyle(color: Colors.white70, fontSize: 20),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.white), // 編集ボタン
                    onPressed: _startSitUpEditing, // 編集開始
                  ),
                ],)
              ]
            ),
          ),
        ),
      ),

      body: Stack(
        children: [ // 背景色を置く
          Container(
            color: Colors.black, // 背景色
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0), // 画面の余白を設定        
            child: Column(
              children: [
                SizedBox(height: 50), // 余白
                TableCalendar(
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      // 特定の日付リストに含まれていたら装飾変更
                      if (highlightDays.any((d) => isSameDay(d, day))) {
                        return Center(
                          child: Icon(
                            Icons.check,
                            color: const Color.fromARGB(255, 212, 255, 95),
                            size: 50,
                          ),
                        );
                      }
                      return null; // それ以外はデフォルト表示
                    },
                  ),
                  firstDay: DateTime.utc(2000, 1, 1), // カレンダーの開始日
                  lastDay: DateTime.utc(2200, 12, 31), // カレンダーの終了日
                  focusedDay: _focusedDay, // 現在フォーカスされている日付
                  selectedDayPredicate: (day) =>
                      isSameDay(_selectedDay, day), // 選択判定
                  onDaySelected: (selectedDay, focusedDay) { // 日付選択時の処理
                    setState(() {
                      _selectedDay = selectedDay; // 選択日を更新
                      _focusedDay = focusedDay; // フォーカス日を更新
                    });
                    showDialog<void>(
                      context: context,
                      builder: (_) {
                        return AlertDialogSample(selectedDay); // ダイアログ表示
                      }
                    );
                  },
                  calendarStyle: CalendarStyle(
                    defaultTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),  // 通常の日付の文字色
                    weekendTextStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.w700), // 土日の文字色
                    selectedDecoration: isSameDay(_selectedDay, DateTime.now())
                      ? BoxDecoration(
                        color: Color.fromARGB(134, 212, 255, 95), // 選択日の背景色   
                        shape: BoxShape.circle, // 選択日の形状
                      ) 
                      : BoxDecoration(), 
                    selectedTextStyle: isSameDay(_selectedDay, DateTime.now())
                      ? TextStyle(color: const Color.fromARGB(255, 212, 255, 95),fontWeight: FontWeight.w700)
                      : TextStyle(color: Colors.white, fontWeight: FontWeight.w700), // 選択日の装飾（未設定）
                    todayDecoration: BoxDecoration(
                      color:Color.fromARGB(134, 212, 255, 95), // 今日の背景色
                      shape: BoxShape.circle, // 今日の形状
                    ),
                    todayTextStyle: TextStyle(color: const Color.fromARGB(255, 212, 255, 95),fontWeight: FontWeight.w700), // 今日の日付の文字色
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false, // フォーマット切替ボタン非表示
                    titleCentered: true, // 月タイトル中央揃え
                        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20,fontWeight: FontWeight.w700), // 月タイトル
                        leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white), // 左矢印
                        rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white), // 右矢印
                        ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.w700), // 平日
                    weekendStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.w700), // 土日
                  ),
                ),
                const SizedBox(height: 50), // 余白
                ElevatedButton( // ボタンウィジェット
                  onPressed: () { // ボタン押下時の処理
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SelectScreen(), // PushUpCounterScreenへ遷移
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 212, 255, 95), // ボタンの背景色
                    padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15), // ボタンの内側の余白
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50), // ボタンの角を丸くする
                    ),
                  ),
                  child: const Text('Start',style: TextStyle(fontSize: 30.0, color: Colors.black),), // ボタンのラベル
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SelectScreen extends StatefulWidget { // 運動選択画面（状態を持つ）
  const SelectScreen({super.key}); // コンストラクタ

  @override
  State<SelectScreen> createState() => _SelectScreenState(); // 状態管理クラスを生成
}

class _SelectScreenState extends State<SelectScreen> {// 状態管理クラス
  bool _isChecked1 = true; // 1つ目のチェック状
  bool _isChecked2 = false;
  late String subject;

  @override
  Widget build(BuildContext context) { // 画面のUI構築
    return Scaffold(
      backgroundColor: const Color(0xFFD5FF5F), // 背景色を黒に設定
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center, // 中央揃え,
        children: [
          const Text(
            'Select Exercise', // タイトル表示
            style: TextStyle(fontSize: 32, color: Colors.black, fontWeight: FontWeight.w700), // 文字サイズと色
          ),
          const SizedBox(height: 40), 
          Theme(
            data: Theme.of(context).copyWith(
              splashColor: const Color.fromARGB(19, 0, 0, 0), // チェックボックスの枠線の色
            ),
              child: CheckboxListTile(
              title: const Text("Push-up"),
              activeColor: Colors.black,
              value: _isChecked1,
              onChanged: (bool? value) {
                setState(() {
                  _isChecked1 = true;
                  _isChecked2 = false;
                });
              },
            ),
          ),
          Theme(
            data: Theme.of(context).copyWith(
              splashColor: const Color.fromARGB(19, 0, 0, 0), // チェックボックスの枠線の色
            ),
            child: CheckboxListTile(
              title: const Text("Sit-up"),
              activeColor: Colors.black,
              value: _isChecked2,
              onChanged: (bool? value) {
                setState(() {
                  _isChecked2 = true;
                  _isChecked1 = false;
                });
              },
            ),
          ),
          SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black, // ボタンの背景色
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20), // ボタンの内側の余白
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30), // ボタンの角を丸くする
              ),
            ),
            onPressed: () { //ボタン押下時の処理
              subject = _isChecked1 ?"pushup" : "situp";
               Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => CounterScreen(subject)), // カウンター画面へ遷移
                  (Route<dynamic> route) => false, // 履歴を全て消す
                );
            },
            child: 
            const Text("Let's training!",style: TextStyle(fontSize: 20.0,color: Colors.white),), // ボタンのラベル
          ),
        ],
      ),
    );
  }
}

class CounterScreen extends StatefulWidget { // 腕立てカウンター画面（状態を持つ）
  CounterScreen(this.subject);
  String subject; // コンストラクタ

  @override
  State<CounterScreen> createState() => _CounterScreenState(subject); // 状態管理クラスを生成
}

class _CounterScreenState extends State<CounterScreen> { // 状態管理クラス
  _CounterScreenState(this.subject);
  String subject;
  late int count, goalcount;

  bool _isNear = false; // 近接センサーが近いかどうかを保持
  late Stream<bool> _proximityStream; // 近接センサーの状態を監視するストリーム
  late StreamSubscription<bool> _proximitySubscription; // 購読用変数

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() {
    _proximityStream = ProximitySensor.events.map((event) => event > 0);
    _proximitySubscription = _proximityStream.listen((isNear) {
      if (isNear && !_isNear) {
        setState(() {
          count++;
          setdata();
        });
      }
      _isNear = isNear;
    });
  }

  @override
  void dispose() {
    _proximitySubscription.cancel(); // センサー購読を停止
    super.dispose();
  }

  Future<void> setdata() async { // データ保存処理
    late int anotherCount;
    final key = DateFormat('yyyy-MM-dd').format(DateTime.now()); // 日付をキーに変換
    try {
      final infoData = box.get(key); // Hiveからデータ取得
      if(subject == "pushup"){
        anotherCount = infoData?.situpcount ?? 0;
      }else{
        anotherCount = infoData?.pushupcount ?? 0; // データがなければ0
      }
    } catch (e) {
      anotherCount = 0;
    }

    late info infoObject;
    if(subject == 'pushup'){
      infoObject = info(count, anotherCount);
    }else{
      infoObject = info(anotherCount, count);
    }
    box.put(key, infoObject); // Hiveに保存
  }

  void debugyou() { // デバッグ用ボタン（腕立て回数を増やす）
    setState((){
      count++; // 回数を増やす
      setdata();
    });
  }

  void debugyouyou() { // デバッグ用ボタン（腕立て回数を増やす）
    setState((){
      count--; // 回数を減らす
      setdata();
    });
  }

  @override
  Widget build(BuildContext context) { // 画面のUI構築
    final key = DateFormat('yyyy-MM-dd').format(DateTime.now()); // 日付をキーに変換
    final infoData = box.get(key); // Hiveからデータ取得

    // カウント取得（subjectによって分岐）
    count = (subject == "pushup")
        ? (infoData?.pushupcount ?? 0)
        : (infoData?.situpcount ?? 0);

    // 目標回数取得（subjectによって分岐、なければ20）
    goalcount = box.get(subject == "pushup" ? "pushUpGoalCount" : "sitUpGoalCount") ?? 20;

    return Scaffold(
      backgroundColor: Colors.black, // 背景色を黒に設定
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 中央揃え
          children: [
            Text(
              '$subject', // タイトル表示
              style: const TextStyle(fontSize: 32, color: Colors.white), // 文字サイズと色
            ),
            const SizedBox(height: 20), // 余白
            SizedBox(
              width: double.infinity ,
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
              width: 304,
              height: 69,
              child: subject == "pushup"?
                Text(
                  'スマホを地面に置いて、\n胸を近づけるとカウントされます', // 説明文
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white, // 文字色
                    fontSize: 14, // 文字サイズ
                    fontFamily: 'Inter', // フォント
                    fontWeight: FontWeight.w600, // 太字
                  ),
                ):
                Text(
                  'スマホを地面に置いて、\n背中を近づけるとカウントされます', // 説明文
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white, // 文字色
                    fontSize: 14, // 文字サイズ
                    fontFamily: 'Inter', // フォント
                    fontWeight: FontWeight.w600, // 太字
                  ),
                )
            ),
            if(count >= goalcount)
              ElevatedButton( // ボタンウィジェット
                onPressed: () { // ボタン押下時の処理
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ResultScreen()), // 結果画面へ遷移
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 212, 255, 95), // ボタンの背景色
                  padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15), // ボタンの内側の余白
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50), // ボタンの角を丸くする
                  ),
                ),
                child: const Text('Finish',style: TextStyle(fontSize: 30.0, color: Colors.black),), // ボタンのラベル
              ),
            ElevatedButton(
              onPressed: debugyou, // デバッグ用ボタン
              child: Text('debug+') // ボタンラベル
            ),
            ElevatedButton(
              onPressed: debugyouyou, // デバッグ用ボタン
              child: Text('debug-') // ボタンラベル
            ),
          ],
        ),
      ),
    );
  }
}

class ResultScreen extends StatefulWidget { // 結果画面（状態を持つ）
  ResultScreen({super.key}); // コンストラクタ 

  @override
  State<ResultScreen> createState() => _ResultScreenState(); // 状態管理クラスを生成
}

class _ResultScreenState extends State<ResultScreen> { // 状態管理クラス
  // _ResultScreenState({super.key}); // コンストラクタ

  @override
  Widget build(BuildContext context) { // 画面のUI構築
    return Scaffold(
      backgroundColor: const Color(0xFFD5FF5F), // 背景色
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 中央揃え
          children: [
            Icon(Icons.task_alt, size: 100, color: Colors.black,), // 完了アイコン
            SizedBox(
              height: 20,
            ),
            const Text(
              "Finish!", // 完了メッセージ
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
              onPressed: () { // ボタン押下時の処理 // データ保存sinai
                highlightDays.add(DateTime.now());
                box.put("highlight",highlightDays);
                debugPrint("$highlightDays");
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Calendar()), // カレンダー画面へ戻る
                  (Route<dynamic> route) => false, // 履歴を全て消す
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