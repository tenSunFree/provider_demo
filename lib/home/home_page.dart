import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var isProvideVerification = false;

  @override
  Widget build(BuildContext context) {
    var statusBarHeight = MediaQueryData.fromWindow(window).padding.top;
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(top: statusBarHeight),
        child: Column(
          children: <Widget>[
            showTitleBar(),
            showShadow(),
            showCertifiedPhoneText(),
            showTextField(),
            showFlatButton(),
          ],
        ),
      ),
    );
  }

  Container showFlatButton() {
    return Container(
        margin: EdgeInsets.only(left: 24, right: 24, top: 32),
        child: Row(children: <Widget>[
          FlatButton(
              padding: EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
              child: Text('重發驗證碼',
                  style: TextStyle(fontSize: 17, color: Color(0xFFFFFFFF))),
              color: Color(0xFFCCCCCC),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
              onPressed: () {}),
          Flexible(child: Container(), flex: 1),
          FlatButton(
              padding: EdgeInsets.only(top: 8, bottom: 8, left: 66, right: 66),
              child: Text('驗證',
                  style: TextStyle(fontSize: 17, color: Color(0xFFFFFFFF))),
              color:
                  isProvideVerification ? Color(0xFFFF6F00) : Color(0xFFCCCCCC),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
              onPressed: showLoadingDialog)
        ]));
  }

  Container showTextField() {
    return Container(
        margin: EdgeInsets.only(left: 24, right: 24),
        child: TextField(
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: 18, color: Color(0xFF373737)),
            inputFormatters: <TextInputFormatter>[
              // maximum word limit
              LengthLimitingTextInputFormatter(4),
            ],
            decoration: InputDecoration(
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFFF6F00))),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFFF6F00))),
                contentPadding: EdgeInsets.all(2),
                isDense: true,
                hintText: '請輸入驗證碼',
                hintStyle: TextStyle(fontSize: 18, color: Color(0xFFB2B2B2))),
            onChanged: _textFieldChanged,
            minLines: 1,
            maxLines: 1));
  }

  Container showCertifiedPhoneText() {
    return Container(
        margin: EdgeInsets.only(left: 24, top: 32, bottom: 32),
        alignment: Alignment.centerLeft,
        child: Text('為確保您是本人，需先認證您的手機',
            style: TextStyle(fontSize: 17, color: Color(0xFFFF802B))));
  }

  Container showShadow() => Container(height: 1, color: Color(0xFFE2E0E4));

  Container showTitleBar() {
    return Container(
        child: Stack(
          children: <Widget>[
            Container(
                alignment: Alignment.center,
                child: Text('手機認證',
                    style: TextStyle(fontSize: 17, color: Color(0xFF000000)))),
            Container(
                alignment: Alignment.centerLeft,
                child: InkWell(
                    onTap: () => showToast('click return'),
                    child: Container(
                        width: 60,
                        padding: EdgeInsets.only(top: 18, bottom: 18),
                        child: Image.asset('assets/icon/icon_return.png',
                            fit: BoxFit.contain)))),
          ],
        ),
        height: 60,
        color: Color(0xFF65660));
  }

  void setProvideVerification(bool isProvideVerification) {
    setState(() {
      this.isProvideVerification = isProvideVerification;
    });
  }

  void _textFieldChanged(String str) {
    if (str.length != 4) {
      setProvideVerification(false);
    } else {
      setProvideVerification(true);
    }
  }

  void showLoadingDialog() {
    if (!isProvideVerification) {
      return;
    }
    var progress = 0.0;
    var round = 0;
    StateSetter stateSetter;
    Timer.periodic(Duration(milliseconds: 50), (timer) {
      // Timer analog progress increased
      progress += 0.03;
      if (stateSetter != null) {
        stateSetter(() {});
      }
      if (progress > 1.05) {
        progress = 0;
        round++;
        stateSetter(() {});
      }
      if (round > 1) {
        timer.cancel();
        stateSetter = null;
        Navigator.of(context).pop();
        Provider.of<VerificationUtils>(context, listen: false)
            .startVerification();
        showMessageDialog();
      }
    });
    var statefulBuilder = StatefulBuilder(builder: (ctx, state) {
      stateSetter = state;
      return WillPopScope(
          // disable back key
          onWillPop: () async => false,
          child: Center(
              child: SizedBox(
                  width: 290,
                  height: 116,
                  child: Card(
                    elevation: 24,
                    child: Row(children: <Widget>[
                      Flexible(
                          child: Center(
                              child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation(Color(0xFFFF7600)),
                            value: progress,
                          )),
                          flex: 1),
                      Flexible(
                          child: Container(
                              child: Text("處理中，請稍後…",
                                  style: TextStyle(
                                      fontSize: 15, color: Color(0xFF525252)))),
                          flex: 2)
                    ]),
                  ))));
    });
    showDialog(
      context: context,
      builder: (ctx) => statefulBuilder,
      barrierDismissible: false,
    );
  }

  void showMessageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final verificationUtils = Provider.of<VerificationUtils>(context);
        return WillPopScope(
            // disable back key
            onWillPop: () async => false,
            child: AlertDialog(
                title: Text(
                  verificationUtils.isVerificationSucceeded ? '驗證成功' : '驗證碼無效',
                  style: TextStyle(fontSize: 16, color: Color(0xFF000000)),
                ),
                titlePadding:
                    EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 0),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('確認',
                          style: TextStyle(
                              fontSize: 15, color: Color(0xFFFF7600)))),
                ]));
      },
      barrierDismissible: false,
    );
  }
}

void showToast(String text) {
  Fluttertoast.showToast(
    msg: text,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIos: 1,
    backgroundColor: Color(0xCC4F4F4F),
    textColor: Color(0xFFFFFFFF),
    fontSize: 16,
  );
}
