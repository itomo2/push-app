import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'screens.dart';
import '../main.dart';

class graphInfo extends StatefulWidget {
  const graphInfo({Key? key}) : super(key: key);

  @override
  State<graphInfo> createState() => _graphInfoState();
}

class _graphInfoState extends State<graphInfo> {
  List<PageViewModel> getPages() {
    return [
      PageViewModel(
        title: t("explanation"),
        body: t("graph explanation"),
        image: Image.asset('assets/images/graph.png'),
        decoration: const PageDecoration(
          titleTextStyle: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.w700,
          ),
          bodyTextStyle: TextStyle(fontSize: 20.0),
          pageColor: Color(0xFF2D2D35),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IntroductionScreen(
          scrollPhysics: const BouncingScrollPhysics(),
          pages: getPages(),
          onDone: () async {
            box.put('information', false);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GraphScreen(month),
              ), // カレンダー画面へ戻る
            ); // カレンダー画面へ戻る
          },
          onSkip: () async {
            box.put('information', false);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GraphScreen(month),
              ), // カレンダー画面へ戻る
            ); // カレンダー画面へ戻る
          },
          next: const Icon(Icons.arrow_forward, color: Colors.white),
          done: const Text(
            "OK",
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
          ),
          dotsDecorator: DotsDecorator(
            size: const Size.square(10.0),
            activeSize: const Size(20.0, 10.0),
            activeColor: Theme.of(context).primaryColor,
            color: Colors.white,
            spacing: const EdgeInsets.symmetric(horizontal: 3.0),
            activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
            ),
          ),
        ),
      ),
    );
  }
}
