import 'package:push_app/main.dart';
import 'package:table_calendar/table_calendar.dart'; // カレンダー表示用パッケージをインポート
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:push_app/widgets/widgets.dart';
import 'package:push_app/screens/screens.dart';
import 'package:intl/intl.dart'; // 日付フォーマット用パッケージをインポート

class Calendar extends StatefulWidget {
  // カレンダー画面（状態を持つ）
  const Calendar({super.key}); // コンストラクタ

  @override
  State<Calendar> createState() => _CalendarState(); // 状態管理クラスを生成
}

class _CalendarState extends State<Calendar> {
  // Calendar画面の状態管理クラス

  late List<dynamic> highlightDays;

  // _focusedDayは、カレンダーで表示している月の基準日（どの月を表示するかを決める日付）。
  DateTime _focusedDay = DateTime.now(); // 現在フォーカスされている日付
  // _selectedDayは、ユーザーが実際に選択した日付。
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

  void _demohighlight() {
    DateTime now = DateTime.now();
    List<dynamic> demoDays = [];
    int pushupc;
    int situpc;
    for (int ii = 0; ii < 50; ii += 2) {
      DateTime ago = now.subtract(Duration(days: ii));
      String key = DateFormat('yyyy-MM-dd').format(ago); // 日付をキーに変
      demoDays.add(DateTime(ago.year, ago.month, ago.day));
      pushupc = ii + 50;
      situpc = 50 - ii;
      late info infoObject;
      infoObject = info(pushupc, situpc, Duration.zero, Duration.zero);
      box.put(key, infoObject); // Hiveに保存
    }

    box.put('highlight', demoDays);
  }

  @override
  void initState() {
    super.initState();
    pushupt = box.get('pushUpGoalTime') ?? "00:00";
    situpt = box.get('sitUpGoalTime') ?? "00:00";
    _nwdurationpush = parseDuration(pushupt);
    _nwdurationsit = parseDuration(situpt);

    _demohighlight();
    highlightDays = box.get("highlight") ?? []; // 画面のUI構築
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
      situpt = formatDuration(_nwdurationsit);
      box.put("sitUpGoalTime", situpt);
      pushupt = formatDuration(_nwdurationpush);
      box.put("pushUpGoalTime", pushupt);
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
      situpt = formatDuration(_nwdurationsit);
      box.put("sitUpGoalTime", situpt);
      pushupt = formatDuration(_nwdurationpush);
      box.put("pushUpGoalTime", pushupt);
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: 150, // AppBarの高さ
        backgroundColor: Color(0xFF2D2D35), // AppBar背景色
        titleSpacing: 0, // タイトルの余白
        title: Padding(
          padding: const EdgeInsets.only(left: 20), // 左に余白追加
          child: Stack(
            children: [
              _isPushUpEditing || _isSitUpEditing
                  ? SizedBox.shrink()
                  : Positioned(
                      right: 20,
                      top: 10,
                      child: IconButton(
                        icon: Icon(Icons.menu, size: 40, color: Colors.white),
                        // メニューボタンが押されたときにカスタムダイアログを表示
                        onPressed: () => showMenuDialog(context, month),
                      ),
                    ),
              SizedBox(
                height: 140,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // 左寄せ
                  children: [
                    Text(
                      t("this month's goal"), // 目標回数ラベル
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 50,
                      child: Row(
                        children: [
                          Icon(Icons.circle, color: Colors.white, size: 10),
                          Text(
                            "  ${t("push-up")}:  ",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 20,
                            ),
                          ),
                          _isPushUpEditing
                              ? SizedBox(
                                  width: 25,
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
                                )
                              : Text(
                                  '$_pushUpGoalCount', // 目標回数表示
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 20,
                                  ),
                                ),
                          Text(
                            ' ${t("reps")}  ',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 20,
                            ),
                          ),
                          _isPushUpEditing
                              ? SizedBox.shrink()
                              : Text(
                                  '$pushupt',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 20,
                                  ),
                                ),
                          _isPushUpEditing
                              ? IconButton(
                                  icon: Icon(
                                    Icons.check,
                                    color: Colors.white,
                                  ), // 確定ボタン
                                  onPressed: () {
                                    _submitPushUpEditing();
                                  }, // 確定処理
                                )
                              : _isSitUpEditing
                              ? SizedBox.shrink()
                              : IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                  ), // 編集ボタン
                                  onPressed: _startPushUpEditing, // 編集開始
                                ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 50,
                      child: Row(
                        children: [
                          Icon(Icons.circle, color: Colors.white, size: 10),
                          Text(
                            "  ${t("sit-up")}:  ",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 20,
                            ),
                          ),
                          _isSitUpEditing
                              ? SizedBox(
                                  width: 25,
                                  child: TextField(
                                    controller: _sitUpController, // 入力コントローラー
                                    autofocus: true,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 20,
                                    ),
                                    decoration: InputDecoration(
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.white70,
                                        ),
                                      ),
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                    ),
                                    onSubmitted: (_) =>
                                        _submitSitUpEditing(), // Enterで確定
                                  ),
                                )
                              : Text(
                                  '$_sitUpGoalCount',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 20,
                                  ),
                                ),
                          Text(
                            ' ${t("reps")}  ',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 20,
                            ),
                          ),
                          _isSitUpEditing
                              ? SizedBox.shrink()
                              : Text(
                                  '$situpt',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 20,
                                  ),
                                ),
                          _isSitUpEditing
                              ? IconButton(
                                  icon: Icon(Icons.check, color: Colors.white),
                                  onPressed: _submitSitUpEditing,
                                )
                              : _isPushUpEditing
                              ? SizedBox.shrink()
                              : IconButton(
                                  icon: Icon(Icons.edit, color: Colors.white),
                                  onPressed: _startSitUpEditing,
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _isPushUpEditing || _isSitUpEditing
                  ? Positioned(
                      right: 0,
                      bottom: -25,
                      child: SizedBox(
                        height: 150,
                        width: 170,
                        child: CupertinoTimerPicker(
                          mode: CupertinoTimerPickerMode.ms,
                          initialTimerDuration: parseDuration(
                            _isPushUpEditing
                                ? box.get(
                                    "pushUpGoalTime",
                                    defaultValue: "00;00",
                                  )
                                : box.get(
                                    "sitUpGoalTime",
                                    defaultValue: "00:00",
                                  ),
                          ),
                          onTimerDurationChanged: (Duration newDuration) {
                            setState(() {
                              _isPushUpEditing
                                  ? _nwdurationpush = newDuration
                                  : _nwdurationsit = newDuration;
                            });
                          },
                        ),
                      ),
                    )
                  : SizedBox.shrink(),
            ],
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
                      if (highlightDays.any((d) => isSameDay(d, day)))
                        return Center(
                          child: Icon(
                            Icons.check,
                            color: const Color.fromARGB(255, 212, 255, 95),
                            size: 50,
                          ),
                        );
                      return null; // それ以外はデフォルト表示
                    },
                    selectedBuilder: (context, day, focusedDay) {
                      if (highlightDays.any((d) => isSameDay(d, focusedDay)) &&
                          !isSameDay(focusedDay, DateTime.now()))
                        return Center(
                          child: Icon(
                            Icons.check,
                            color: const Color.fromARGB(255, 212, 255, 95),
                            size: 50,
                          ),
                        );
                      return null;
                    },
                  ),
                  firstDay: DateTime.utc(2000, 1, 1), // カレンダーの開始日
                  lastDay: DateTime.utc(2100, 12, 31), // カレンダーの終了日
                  focusedDay: _focusedDay, // 現在フォーカスされている日付
                  selectedDayPredicate: (day) =>
                      isSameDay(_selectedDay, day), // 選択判定
                  onDaySelected: (selectedDay, focusedDay) {
                    // 日付選択時の処理
                    setState(() {
                      _selectedDay = selectedDay; // 選択日を更新
                      _focusedDay = focusedDay; // フォーカス日を更新
                      month = focusedDay.month;
                    });
                    showDialog<void>(
                      context: context,
                      builder: (_) {
                        return AlertDialogSample(selectedDay); // ダイアログ表示
                      },
                    );
                  },
                  onPageChanged: (focusedDay) {
                    setState(() {
                      month = focusedDay.month;
                      _focusedDay = focusedDay;
                    });
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
                        builder: (context) => const SelectScreen(),
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
