import 'package:duration_picker/base_unit.dart';
import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Duration Picker Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Duration Picker Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Duration _durationMillisClock = const Duration(milliseconds: 1000);
  Duration _durationSecondsClock = const Duration(seconds: 60);
  Duration _durationMinutesClock = const Duration(minutes: 60);
  Duration _durationHoursClock = const Duration(hours: 24);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //PR added container  to show extent of gesture detector
            Expanded(
              child: Container(
                color: Colors.purple,
                child: DurationPicker(
                  duration: _durationMillisClock,
                  baseUnit: BaseUnit.millisecond,

                  onChange: (val) {
                    setState(() => _durationMillisClock = val);
                  },
                  // upperBound: const Duration(
                  //   seconds: 120,
                  // ),
                  // lowerBound: const Duration(
                  //   seconds: 5,
                  // ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.blueGrey,
                child: DurationPicker(
                  duration: _durationSecondsClock,
                  baseUnit: BaseUnit.second,

                  onChange: (val) {
                    setState(() => _durationSecondsClock = val);
                  },
                  // upperBound: const Duration(
                  //   seconds: 120,
                  // ),
                  // lowerBound: const Duration(
                  //   seconds: 5,
                  // ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.green,
                child: DurationPicker(
                  duration: _durationMinutesClock,
                  baseUnit: BaseUnit.minute,

                  onChange: (val) {
                    setState(() => _durationMinutesClock = val);
                  },
                  // upperBound: const Duration(
                  //   seconds: 120,
                  // ),
                  // lowerBound: const Duration(
                  //   seconds: 5,
                  // ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.deepOrangeAccent,
                child: DurationPicker(
                  duration: _durationHoursClock,
                  baseUnit: BaseUnit.hour,

                  onChange: (val) {
                    setState(() => _durationHoursClock = val);
                  },
                  upperBound: const Duration(
                    days: 2,
                  ),
                  lowerBound: const Duration(
                    days: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Builder(
        builder: (BuildContext context) => FloatingActionButton(
          onPressed: () async {
            final resultingDuration = await showDurationPicker(
              title: 'Pick Duration',
              context: context,
              initialTime: const Duration(seconds: 30),
              baseUnit: BaseUnit.second,
              upperBound: const Duration(seconds: 60),
              lowerBound: const Duration(seconds: 10),
              screenScaling: 1.5,//largeText
              onChangeCallback: (Duration val) {
                print('onChangeCallback: $val');
              },


            );
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Chose duration: $resultingDuration'),
              ),
            );
          },
          tooltip: 'Popup Duration Picker',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
