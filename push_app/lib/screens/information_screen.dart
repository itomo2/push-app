import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'screens.dart';

class Information extends StatefulWidget {
  const Information({Key? key}) : super(key: key);

  @override
  State<Information> createState() => _InformationState();
}

class _InformationState extends State<Information> {
  List<PageViewModel> getPages() {
    return [
      PageViewModel(
        title: "Title",
        body: "body",
        image: Center(child: Container(height: 100)),
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
        title: "Title",
        body: "body",
        image: Center(child: Container(height: 100)),
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
    return IntroductionScreen(
      pages: getPages(),
      onDone: () async {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const Calendar()));
      },
      onSkip: () async {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const Calendar()));
      },
      showSkipButton: true,
      skip: const Text('スキップ', style: TextStyle(color: Colors.white)),
      next: const Icon(Icons.arrow_forward, color: Colors.white),
      done: const Text(
        "スタート",
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
    );
  }
}
