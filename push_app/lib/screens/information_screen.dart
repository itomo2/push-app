import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'screens.dart';
import '../main.dart';

class Information extends StatefulWidget {
  const Information({Key? key}) : super(key: key);

  @override
  State<Information> createState() => _InformationState();
}

class _InformationState extends State<Information> {
  List<PageViewModel> getPages() {
    return [
      PageViewModel(
        title: t("page1 title"),
        body: "",
        image: Image.asset('assets/images/welcome.png'),
        decoration: const PageDecoration(
          titleTextStyle: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.w700,
          ),
          bodyTextStyle: TextStyle(fontSize: 20.0),
          pageColor: Color(0xFF2D2D35),
        ),
      ),
      PageViewModel(
        title: t("page2 title"),
        body: t("page2 body"),
        image: Image.asset('assets/images/calendar.png'),
        decoration: const PageDecoration(
          titleTextStyle: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.w700,
          ),
          bodyTextStyle: TextStyle(fontSize: 20.0),
          pageColor: Color(0xFF2D2D35),
        ),
      ),
      PageViewModel(
        title: t("page3 title"),
        body: t("page3 body"),
        image: Image.asset('assets/images/pushup.png'),
        decoration: const PageDecoration(
          titleTextStyle: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.w700,
          ),
          bodyTextStyle: TextStyle(fontSize: 20.0),
          pageColor: Color(0xFF2D2D35),
        ),
      ),
      PageViewModel(
        title: t("page4 title"),
        body: t("page4 body"),
        image: Image.asset('assets/images/kinnniku.png'),
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
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => Calendar()), // カレンダー画面へ戻る
              (Route<dynamic> route) => false, // 履歴を全て消す
            ); // カレンダー画面へ戻る
          },
          onSkip: () async {
            box.put('information', false);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => Calendar()), // カレンダー画面へ戻る
              (Route<dynamic> route) => false, // 履歴を全て消す
            ); // カレンダー画面へ戻る
          },
          showSkipButton: true,
          skip: const Text('Skip', style: TextStyle(color: Colors.white)),
          next: const Icon(Icons.arrow_forward, color: Colors.white),
          done: const Text(
            "Start!",
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
