import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'dart:async';

import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

String formatDate(DateTime d) {
  return d.toString().substring(0, 19);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}



class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  String _status = '?', _steps = '?';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  void onStepCount(StepCount event) {
    print(event);
    setState(() {
      _steps = event.steps.toString();
    });
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    print(event);
    setState(() {
      _status = event.status;
    });
  }

  void onPedestrianStatusError(error) {
    print('onPedestrianStatusError: $error');
    setState(() {
      _status = 'Pedestrian Status not available';
    });
    print(_status);
  }

  void onStepCountError(error) {
    print('onStepCountError: $error');
    setState(() {
      _steps = 'Step Count not available';
    });
  }
var s;
  var p;
  void initPlatformState() async{
   // bool i = await FlutterForegroundTask.isIgnoringBatteryOptimizations;
   // if(i== false) {
   //   FlutterForegroundTask.openIgnoreBatteryOptimizationSettings();
   //  Permission.ignoreBatteryOptimizations.request();
   // }
   //  var status = await Permission.ignoreBatteryOptimizations.status;
   //
   //  print("status: $status");
   //  if (status.isGranted) {
      if (await Permission.activityRecognition.request().isGranted) {
        _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
      p =  _pedestrianStatusStream
            .listen(onPedestrianStatusChanged);

        _stepCountStream = Pedometer.stepCountStream;
       s = _stepCountStream.listen(onStepCount);

      }else{

      }
    }

  //  if (!mounted) return;


  restart(){
    s.cancel();
    p.cancel();
    _pedestrianStatusStream.listen((event) { }).cancel();
    _stepCountStream.listen((event) { }).cancel();

  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Pedometer Example'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Steps Taken',
                style: TextStyle(fontSize: 30),
              ),
              Text(
                _steps,
                style: TextStyle(fontSize: 60),
              ),
              Divider(
                height: 100,
                thickness: 0,
                color: Colors.white,
              ),
              Text(
                'Pedestrian Status',
                style: TextStyle(fontSize: 30),
              ),
              Icon(
                _status == 'walking'
                    ? Icons.directions_walk
                    : _status == 'stopped'
                    ? Icons.accessibility_new
                    : Icons.error,
                size: 100,
              ),
              Center(
                child: Text(
                  _status,
                  style: _status == 'walking' || _status == 'stopped'
                      ? TextStyle(fontSize: 30)
                      : TextStyle(fontSize: 20, color: Colors.red),
                ),
              ),
              ElevatedButton(onPressed: (){
                restart();
              }, child: Text("Restart"))

            ],
          ),
        ),
      ),
    );
  }
}