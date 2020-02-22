import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'home/home.dart';

void main() {
  runApp(MyApp());
  setStatusBar();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => VerificationUtils())],
        child: Consumer<VerificationUtils>(builder: (context, counter, _) {
          return MaterialApp(
              title: 'Flutter Demo',
              theme: ThemeData(
                  primarySwatch: Colors.blue,
                  // TextField cursor color
                  cursorColor: Color(0xFFFF6F00)),
              home: HomePage(title: 'Flutter Demo Home Page'));
        }));
  }
}

void setStatusBar() {
  SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
      statusBarColor: Color(0xFF000000),
      statusBarIconBrightness: Brightness.light);
  SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
}

class VerificationUtils with ChangeNotifier {
  bool _isVerificationSucceeded = false;

  bool get isVerificationSucceeded => _isVerificationSucceeded;

  void startVerification() {
    _isVerificationSucceeded = _isVerificationSucceeded ? false : true;
    notifyListeners();
  }
}
