import 'package:AttendanceApp/screens/home.dart';
import 'package:AttendanceApp/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';
import 'package:async/async.dart';

class InitialScreen extends StatefulWidget {
  InitialScreen({Key key}) : super(key: key);

  @override
  _InitialScreenState createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  FaceNetService _faceNetService = FaceNetService();

  MLVisionService _mlVisionService = MLVisionService();

  final AsyncMemoizer _memoizer = AsyncMemoizer();

  CameraDescription cameraDescription;

  bool loading = true;

  _startUp() async {
    await [
      Permission.camera,
      Permission.microphone,
    ].request();
    return this._memoizer.runOnce(() async {
      await Future.delayed(Duration(seconds: 3));
      _setLoading(true);

      List<CameraDescription> cameras = await availableCameras();

      /// takes the front camera
      cameraDescription = cameras.firstWhere(
        (CameraDescription camera) =>
            camera.lensDirection == CameraLensDirection.front,
      );

      // start the services
      await _faceNetService.loadModel();
      _mlVisionService.initialize();

      _setLoading(false);
    });
  }

  _setLoading(bool value) {
    setState(() {
      loading = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _startUp(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return HomeScreen(
            cameraDescription: cameraDescription,
          );
        } else {
          return LoadingScreen();
        }
      },
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            Hero(
              tag: 'heading',
              child: Container(
                // padding: EdgeInsets.only(top: 150),
                alignment: Alignment.center,
                child: Text(
                  'Attendance App',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Color.fromRGBO(36, 41, 92, 1),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
