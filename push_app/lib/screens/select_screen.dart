import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:push_app/main.dart';
import 'screens.dart';

class SelectScreen extends StatefulWidget {
  // 運動選択画面（状態を持つ）
  const SelectScreen({super.key}); // コンストラクタ

  @override
  State<SelectScreen> createState() => _SelectScreenState(); // 状態管理クラスを生成
}

class _SelectScreenState extends State<SelectScreen> {
  // 状態管理クラス
  bool _isChecked1 = true; // 1つ目のチェック状
  bool _isChecked2 = false;
  late String subject;
  final List<String> exercisestype = [t('counter'), t('stopwatch')];
  late int selectedIndex;

  void initState() {
    super.initState();
    selectedIndex = box.get('kakotore', defaultValue: 0);
  }

  @override
  Widget build(BuildContext context) {
    // 画面のUI構築
    return Scaffold(
      backgroundColor: const Color(0xFFD5FF5F), // 背景色を黒に設定
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center, // 中央揃え,
        children: [
          SizedBox(
            height: 200,
            child: CupertinoPicker(
              // iOS風の縦スクロールホイールを作るウィジェット

              // 初期表示位置を設定するコントローラ
              scrollController: FixedExtentScrollController(
                initialItem: selectedIndex, // 初期選択項目のインデックス
              ),

              itemExtent: 50, // 各項目の高さ（ピクセル単位）
              // ユーザーが選択項目を変更した時に呼ばれるコールバック
              onSelectedItemChanged: (index) {
                setState(() {
                  selectedIndex = index; // 選択されたインデックスを更新
                  box.put('kakotore', selectedIndex);
                });
              },

              // 表示する項目のリストを作成
              children: exercisestype
                  .map(
                    (exercise) => Center(
                      //exerciseにリストの各要素が代入される
                      child: Text(exercise, style: TextStyle(fontSize: 24)),
                    ),
                  )
                  .toList(),
            ),
          ),
          Theme(
            data: Theme.of(context).copyWith(
              splashColor: const Color.fromARGB(19, 0, 0, 0), // チェックボックスの枠線の色
            ),
            child: CheckboxListTile(
              title: Text(t("push-up")),
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
              title: Text(t("sit-up")),
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
              padding: const EdgeInsets.symmetric(
                horizontal: 50,
                vertical: 20,
              ), // ボタンの内側の余白
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30), // ボタンの角を丸くする
              ),
            ),
            onPressed: () {
              //ボタン押下時の処理
              subject = _isChecked1 ? 'Push-up' : 'Sit-up';
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => CounterScreen(subject, selectedIndex),
                ), // カウンター画面へ遷移
                (Route<dynamic> route) => false, // 履歴を全て消す
              );
            },
            child: const Text(
              "Let's training!",
              style: TextStyle(fontSize: 20.0, color: Colors.white),
            ), // ボタンのラベル
          ),
        ],
      ),
    );
  }
}
