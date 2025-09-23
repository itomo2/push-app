import 'package:push_app/main.dart';
import 'package:table_calendar/table_calendar.dart'; // カレンダー表示用パッケージをインポート
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:push_app/widgets/widgets.dart';
import 'package:push_app/screens/screens.dart';

class Calendar extends StatefulWidget {
  // カレンダー画面（状態を持つ）
  const Calendar({super.key}); // コンストラクタ

  @override
  State<Calendar> createState() => _CalendarState(); // 状態管理クラスを生成
}

class _CalendarState extends State<Calendar> {
  // Calendar画面の状態管理クラス

  DateTime _focusedDay = DateTime.now(); // 現在フォーカスされている日付
  DateTime? _selectedDay; // 選択された日付（未選択ならnull）

  int _pushUpGoalCount = box.get(
    'pushUpGoalCount',
    defaultValue: 20,
  ); // 腕立て伏せの目標回数
  int _sitUpGoalCount = box.get('sitUpGoalCount', defaultValue: 20); // 腹筋の目標回数

  bool _isPushUpEditing = false; // 腕立て伏せ編集モード
  bool _isSitUpEditing = false; // 腹筋編集モード

  TextEditingController _pushUpController =
      TextEditingController(); // 腕立て伏せ編集用コントローラー
  TextEditingController _sitUpController =
      TextEditingController(); // 腹筋編集用コントローラー

  late String pushupt;
  late String situpt;

  late Duration _nwdurationpush;
  late Duration _nwdurationsit;

  @override
  void initState() {
    super.initState();
    pushupt = box.get('pushUpGoalTime');
    situpt = box.get('sitUpGoalTime');
    _nwdurationpush = parseDuration(pushupt);
    _nwdurationsit = parseDuration(situpt);
  }

  @override
  void dispose() {
    // ウィジェット破棄時の処理
    _pushUpController.dispose(); // コントローラーの破棄
    _sitUpController.dispose(); // コントローラーの破棄
    super.dispose();
  }

  void _startPushUpEditing() {
    // 編集モード開始
    setState(() {
      _isPushUpEditing = true; // 編集モードON
      _isSitUpEditing = false; // 腹筋編集モードOFF
      _pushUpController.text = _pushUpGoalCount
          .toString(); // 現在の目標回数をテキストフィールドにセット
    });
  }

  void _startSitUpEditing() {
    // 編集モード開始
    setState(() {
      _isSitUpEditing = true; // 編集モードON
      _isPushUpEditing = false; // 腕立て伏せ編集モードOFF
      _sitUpController.text = _sitUpGoalCount
          .toString(); // 現在の目標回数をテキストフィールドにセット
    });
  }

  void _submitPushUpEditing() {
    // 編集内容を確定
    final input = _pushUpController.text; // 入力値取得
    final parsed = int.tryParse(input); // 整数に変換

    if (parsed != null && parsed > 0) {
      // 正の整数なら
      setState(() {
        _pushUpGoalCount = parsed; // 目標回数を更新
        _isPushUpEditing = false; // 編集モードOFF
      });
      box.put('pushUpGoalCount', parsed);
    } else {
      // 無効な入力の場合、アラート表示（SnackBar）
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('正の整数を入力してください')));
    }
  }

  void _submitSitUpEditing() {
    // 編集内容を確定
    final input = _sitUpController.text; // 入力値取得
    final parsed = int.tryParse(input); // 整数に変換

    if (parsed != null && parsed > 0) {
      // 正の整数なら
      setState(() {
        _sitUpGoalCount = parsed; // 目標回数を更新
        _isSitUpEditing = false; // 編集モードOFF
      });
      box.put('sitUpGoalCount', parsed);
    } else {
      // 無効な入力の場合、アラート表示（SnackBar）
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('正の整数を入力してください')));
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
          child: Align(
            alignment: Alignment.centerLeft, // 左寄せ
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // 左寄せ
              children: [
                Text(
                  "This month's goal", // 目標回数ラベル
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    _isPushUpEditing // 編集モードかどうかで表示切替
                        ? Row(
                            children: [
                              Icon(Icons.circle, color: Colors.white, size: 10),
                              Text(
                                "  Push-up:  ",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 20,
                                ),
                              ),
                              SizedBox(
                                width: 30,
                                child: TextField(
                                  controller: _pushUpController, // 入力コントローラー
                                  autofocus: true, // 自動フォーカス
                                  keyboardType: TextInputType.number, // 数値入力
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 20,
                                  ),
                                  decoration: InputDecoration(
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.white70,
                                      ),
                                    ), // フォーカス時の下線
                                    isDense: true, // コンパクト表示
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 8, //上下に８px
                                    ), //余白
                                  ),
                                  onSubmitted: (_) =>
                                      _submitPushUpEditing(), // Enterで確定
                                ),
                              ),
                              Text(
                                'reps',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 20,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                ), // 確定ボタン
                                onPressed: () {
                                  pushupt = formatDuration(_nwdurationpush);
                                  box.put("pushUpGoalTime", pushupt);
                                  _submitPushUpEditing();
                                }, // 確定処理
                              ),
                              SizedBox(
                                height: 150,
                                width: 170,
                                child: DefaultTextStyle(
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 20,
                                  ),
                                  child: CupertinoTimerPicker(
                                    mode: CupertinoTimerPickerMode.ms,
                                    initialTimerDuration: parseDuration(
                                      box.get(
                                        "pushUpGoalTime",
                                        defaultValue: "00:00",
                                      ),
                                    ),
                                    onTimerDurationChanged:
                                        (Duration newDuration) {
                                          setState(() {
                                            _nwdurationpush = newDuration;
                                          });
                                        },
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Icon(Icons.circle, color: Colors.white, size: 10),
                              Text(
                                '  Push-up:  $_pushUpGoalCount reps', // 目標回数表示
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 20,
                                ),
                              ),
                              Text(
                                '    $pushupt',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 20,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                ), // 編集ボタン
                                onPressed: _startPushUpEditing, // 編集開始
                              ),
                            ],
                          ),
                  ],
                ),
                _isSitUpEditing // 編集モードかどうかで表示切替
                    ? Row(
                        children: [
                          Icon(Icons.circle, color: Colors.white, size: 10),
                          Text(
                            "  Sit-up:  ",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(
                            width: 30,
                            child: TextField(
                              controller: _sitUpController, // 入力コントローラー
                              autofocus: true, // 自動フォーカス
                              keyboardType: TextInputType.number, // 数値入力
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 20,
                              ),
                              decoration: InputDecoration(
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white70),
                                ),
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                              ),
                              onSubmitted: (_) => _submitSitUpEditing(),
                            ),
                          ),
                          Text(
                            'reps',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 20,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.check, color: Colors.white),
                            onPressed: () {
                              situpt = formatDuration(_nwdurationsit);
                              box.put("sitUpGoalTime", situpt);
                              _submitSitUpEditing();
                            },
                          ),
                          SizedBox(
                            height: 150,
                            width: 170,
                            child: DefaultTextStyle(
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 20,
                              ),
                              child: CupertinoTimerPicker(
                                mode: CupertinoTimerPickerMode.ms,
                                initialTimerDuration: parseDuration(
                                  box.get(
                                    "sitUpGoalTime",
                                    defaultValue: "00:00",
                                  ),
                                ),
                                onTimerDurationChanged: (Duration newDuration) {
                                  setState(() {
                                    _nwdurationsit = newDuration;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Icon(Icons.circle, color: Colors.white, size: 10),
                          Text(
                            '  Sit-up:  $_sitUpGoalCount reps', // 目標回数表示
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            '    $situpt',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 20,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.edit,
                              color: Colors.white,
                            ), // 編集ボタン
                            onPressed: _startSitUpEditing, // 編集開始
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),

      body: Stack(
        children: [
          // 背景色を置く
          Container(
            color: Colors.black, // 背景色
          ),
          Padding(
            padding: const EdgeInsets.only(
              bottom: 16.0,
              left: 16.0,
              right: 16.0,
            ), // 画面の余白を設定
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
                  onDaySelected: (selectedDay, focusedDay) {
                    // 日付選択時の処理
                    setState(() {
                      _selectedDay = selectedDay; // 選択日を更新
                      _focusedDay = focusedDay; // フォーカス日を更新
                    });
                    showDialog<void>(
                      context: context,
                      builder: (_) {
                        return AlertDialogSample(selectedDay); // ダイアログ表示
                      },
                    );
                  },
                  calendarStyle: CalendarStyle(
                    defaultTextStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ), // 通常の日付の文字色
                    weekendTextStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ), // 土日の文字色
                    selectedDecoration: isSameDay(_selectedDay, DateTime.now())
                        ? BoxDecoration(
                            color: Color.fromARGB(134, 212, 255, 95), // 選択日の背景色
                            shape: BoxShape.circle, // 選択日の形状
                          )
                        : BoxDecoration(),
                    selectedTextStyle: isSameDay(_selectedDay, DateTime.now())
                        ? TextStyle(
                            color: const Color.fromARGB(255, 212, 255, 95),
                            fontWeight: FontWeight.w700,
                          )
                        : TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ), // 選択日の装飾（未設定）
                    todayDecoration: BoxDecoration(
                      color: Color.fromARGB(134, 212, 255, 95), // 今日の背景色
                      shape: BoxShape.circle, // 今日の形状
                    ),
                    todayTextStyle: TextStyle(
                      color: const Color.fromARGB(255, 212, 255, 95),
                      fontWeight: FontWeight.w700,
                    ), // 今日の日付の文字色
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false, // フォーマット切替ボタン非表示
                    titleCentered: true, // 月タイトル中央揃え
                    titleTextStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ), // 月タイトル
                    leftChevronIcon: Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                    ), // 左矢印
                    rightChevronIcon: Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                    ), // 右矢印
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ), // 平日
                    weekendStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ), // 土日
                  ),
                ),
                const SizedBox(height: 50), // 余白
                ElevatedButton(
                  // ボタンウィジェット
                  onPressed: () {
                    // ボタン押下時の処理
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const SelectScreen(), // PushUpCounterScreenへ遷移
                      ),
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
                    'Start',
                    style: TextStyle(fontSize: 30.0, color: Colors.black),
                  ), // ボタンのラベル
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
