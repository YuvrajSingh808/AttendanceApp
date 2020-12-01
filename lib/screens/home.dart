import 'dart:async';
import 'package:AttendanceApp/screens/screens.dart';
import 'package:AttendanceApp/screens/settings.dart';
import 'package:flutter/material.dart';
import 'package:tf_speech/tf_speech.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:camera/camera.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key, @required this.cameraDescription}) : super(key: key);

  final CameraDescription cameraDescription;
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer timer;
  var speech;

  @override
  void initState() {
    super.initState();
  }

  _startSpeech() async {
    speech = TfSpeech();
    if (mounted)
      await for (var result in speech.stream) {
        // print(result);
        if (result['left'] > 0.75 && result['_unknown_'] < 0.5) {
          print('left: ${result['left']}');
          speech.close();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TakeImage(
                cameraDescription: widget.cameraDescription,
                choice: 'markin',
              ),
            ),
          );
        } else if (result['right'] > 0.75 && result['_unknown_'] < 0.5) {
          print(result['right']);
          speech.close();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TakeImage(
                cameraDescription: widget.cameraDescription,
                choice: 'markout',
              ),
            ),
          );
        }
      }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _startSpeech(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return SafeArea(
          child: Scaffold(
            backgroundColor: Color.fromRGBO(219, 213, 213, 1),
            body: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  SvgPicture.asset('assets/topCircle.svg'),
                  Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: SvgPicture.asset(
                      'assets/bottomCircle.svg',
                      alignment: Alignment.bottomCenter,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                          icon: Icon(Icons.settings),
                          onPressed: () async{
                            await speech.close();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => SettingScreen(),
                              ),
                            );
                          })
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset('assets/bro.svg'),
                      SizedBox(
                        height: 50,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Ink(
                            height: 130,
                            width: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Color.fromRGBO(213, 107, 107, 0.92),
                            ),
                            // margin: EdgeInsets.all(0),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TakeImage(
                                      cameraDescription:
                                          widget.cameraDescription,
                                      choice: 'markin',
                                    ),
                                  ),
                                );
                              },
                              child: Stack(
                                children: [
                                  Positioned(
                                    right: -3,
                                    top: -4,
                                    child: SvgPicture.asset(
                                      'assets/Subtract.svg',
                                      alignment: Alignment.topRight,
                                    ),
                                  ),
                                  Positioned(
                                    left: 20,
                                    top: 40,
                                    child: SvgPicture.asset(
                                      'assets/arrow.svg',
                                      alignment: Alignment.center,
                                      width: 23.77,
                                      height: 30.33,
                                    ),
                                  ),
                                  Positioned(
                                    left: 18,
                                    top: 80,
                                    child: Text(
                                      'Mark in',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 20,
                                          color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Ink(
                            height: 130,
                            width: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Color.fromRGBO(36, 41, 92, 0.92),
                            ),
                            // margin: EdgeInsets.all(0),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TakeImage(
                                      cameraDescription:
                                          widget.cameraDescription,
                                      choice: 'markout',
                                    ),
                                  ),
                                );
                              },
                              child: Stack(
                                children: [
                                  Positioned(
                                    right: -3,
                                    top: -4,
                                    child: SvgPicture.asset(
                                      'assets/SubtractBlue.svg',
                                      alignment: Alignment.topRight,
                                    ),
                                  ),
                                  Positioned(
                                    left: 20,
                                    top: 40,
                                    child: SvgPicture.asset(
                                      'assets/off.svg',
                                      alignment: Alignment.center,
                                      width: 23.77,
                                      height: 30.33,
                                    ),
                                  ),
                                  Positioned(
                                    left: 18,
                                    top: 80,
                                    child: Text(
                                      'Mark out',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Hero(
                    tag: 'heading',
                    child: Container(
                      padding: EdgeInsets.only(top: 150),
                      alignment: Alignment.topCenter,
                      child: Text(
                        'Attendance App',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color.fromRGBO(36, 41, 92, 1)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
