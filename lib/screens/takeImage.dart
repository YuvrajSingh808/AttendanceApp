import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:AttendanceApp/screens/markAttendance.dart';
import '../shared/facePainter.dart';
import '../services/camera.service.dart';
import '../services/facenet.service.dart';
import '../services/ml_vision_service.dart';
import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

import 'screens.dart';

class TakeImage extends StatefulWidget {
  final CameraDescription cameraDescription;
  final String choice;

  const TakeImage(
      {Key key, @required this.cameraDescription, @required this.choice})
      : super(key: key);

  @override
  TakeImageState createState() => TakeImageState();
}

class TakeImageState extends State<TakeImage> {
  String imagePath;
  Face faceDetected;
  Size imageSize;

  bool _detectingFaces = false;
  bool pictureTaked = false;

  Future _initializeControllerFuture;
  bool cameraInitializated = false;

  // switchs when the user press the camera
  bool _saving = false;

  // service injection
  MLVisionService _mlVisionService = MLVisionService();
  CameraService _cameraService = CameraService();
  FaceNetService _faceNetService = FaceNetService();
  Timer timer;
  int time = 5;

  @override
  void initState() {
    super.initState();

    /// starts the camera & start framing faces
    _start();
    timer = Timer.periodic(
      Duration(seconds: 1),
      (Timer timer) => setState(
        () {
          if (time == 1) {
            onShot();
            timer.cancel();
          } else {
            time--;
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _cameraService.dispose();
    timer.cancel();
    super.dispose();
  }

  _start() async {
    _initializeControllerFuture =
        _cameraService.startService(widget.cameraDescription);
    await _initializeControllerFuture;

    setState(() {
      cameraInitializated = true;
    });

    _frameFaces();
  }

  Future<void> onShot() async {
    print('onShot performed');

    if (faceDetected == null) {
      showDialog(
        context: context,
        child: AlertDialog(
          content: Text('No face detected!'),
        ),
      );
      Timer(Duration(seconds: 3), () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              cameraDescription: widget.cameraDescription,
            ),
          ),
          (Route<dynamic> route) => false,
        );
      });
      return false;
    } else {
      imagePath =
          join((await getTemporaryDirectory()).path, '${DateTime.now()}.png');

      _saving = true;

      await Future.delayed(Duration(milliseconds: 500));
      await _cameraService.cameraController.stopImageStream();
      await Future.delayed(Duration(milliseconds: 200));
      await _cameraService.takePicture(imagePath);

      setState(() {
        pictureTaked = true;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MarkAttendance(
            currPredictedData: _faceNetService.predictedData,
            cameraDescription: widget.cameraDescription,
            choice: widget.choice,
          ),
        ),
      );
    }
  }

  /// draws rectangles when detects faces
  _frameFaces() {
    imageSize = _cameraService.getImageSize();

    _cameraService.cameraController.startImageStream((image) async {
      if (_cameraService.cameraController != null) {
        // if its currently busy, avoids overprocessing
        if (_detectingFaces) return;

        _detectingFaces = true;

        try {
          List<Face> faces = await _mlVisionService.getFacesFromImage(image);
          print("Faces = " + "${faces.length}");
          if (faces.length > 0) {
            setState(() {
              faceDetected = faces[0];
            });

            if (_saving) {
              _faceNetService.setCurrentPrediction(image, faceDetected);
              setState(() {
                _saving = false;
              });
            }
          } else {
            setState(() {
              faceDetected = null;
            });
          }

          _detectingFaces = false;
        } catch (e) {
          print(e);
          _detectingFaces = false;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double mirror = math.pi;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (pictureTaked) {
              return Container(
                width: width,
                child: Transform(
                  alignment: Alignment.center,
                  child: Image.file(
                    File(imagePath),
                  ),
                  transform: Matrix4.rotationY(mirror),
                ),
              );
            } else {
              return Transform.scale(
                scale: 1.0,
                child: AspectRatio(
                  aspectRatio: MediaQuery.of(context).size.aspectRatio,
                  child: OverflowBox(
                    alignment: Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.fitHeight,
                      child: Container(
                        width: width,
                        height: width /
                            _cameraService.cameraController.value.aspectRatio,
                        child: Stack(
                          fit: StackFit.expand,
                          children: <Widget>[
                            CameraPreview(_cameraService.cameraController),
                            CustomPaint(
                              painter: FacePainter(
                                  face: faceDetected, imageSize: imageSize),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Text('$time'),
        backgroundColor: Color.fromRGBO(213, 107, 107, 1),
      ),
    );
  }
}
