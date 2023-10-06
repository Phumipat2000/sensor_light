// ignore_for_file: library_private_types_in_public_api, unnecessary_string_interpolations, avoid_unnecessary_containers, unnecessary_new, prefer_const_constructors, deprecated_member_use, avoid_print

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:light/light.dart';
import 'dart:async';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'dart:convert';
import 'package:json_table/json_table.dart';
import 'units/json.dart';
import 'units/theme.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: Consumer<ThemeNotifier>(
        builder: (context, ThemeNotifier notifier, child) {
          return MaterialApp(
            title: 'Sensor Light',
            theme: notifier.darkTheme ? dark : light,
            debugShowCheckedModeBanner: false,
            home: const HomePage(),
          );
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Light _light;

  String _luxString = 'unknown';
  StreamSubscription _subscription;

  //json for table data
  final String jsonSample =
      '[{"site":"Bedroom","level":"150"}, {"site":"Office room","level":"300-500"},'
      '{"site":"Living room","level":"150-300"},{"site":"Dining room","level":"300-500"},'
      '{"site":"Kitchen","level":"300-500"},{"site":"Bathroom","level":"100-300"}]';
  bool toggle = true;

  void onData(int luxValue) async {
    print("lux value: $luxValue");
    setState(() {
      _luxString = "$luxValue";
    });
  }

  void stopListening() {
    _subscription.cancel();
  }

  void startListening() {
    _light = new Light();
    try {
      _subscription = _light.lightSensorStream.listen(onData);
    } on LightException catch (exception) {
      print(exception);
    }
  }

  @override
  void initState() {
    super.initState();
    initPlatFormState();
  }

  Future<void> initPlatFormState() async {
    startListening();
  }

  @override
  Widget build(BuildContext context) {
    double level = double.tryParse('$_luxString') ?? 0.0;
    var json = jsonDecode(jsonSample);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Light'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Consumer<ThemeNotifier>(
              builder: (context, notifier, child) => SwitchListTile(
                title: const Text("Dark Mode"),
                onChanged: (val) {
                  notifier.toogleTheme();
                },
                value: notifier.darkTheme,
              ),
            ),

            const SizedBox(
              height: 10.0,
            ),
            Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Container(
                        height: 50,
                        width: 50,
                        padding: const EdgeInsets.only(right: 100.0),
                        child: Icon(
                          FontAwesomeIcons.lightbulb,
                          size: 45.0,
                          color: Colors.green[500],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    alignment: Alignment.center,
                    color: Colors.transparent,
                    child: new CircularPercentIndicator(
                      radius: 240.0,
                      lineWidth: 25.0,
                      percent: (level <= 999) ? level / 1000 : 0.0,
                      center: Container(
                        margin: const EdgeInsets.only(top: 40.0),
                        padding: const EdgeInsets.only(top: 10.0),
                        child: new Text(
                          "$_luxString\n",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 40.0),
                        ),
                      ),
                      footer: new Text(
                        "Lumen level per M²(LUX)",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17.0),
                      ),
                      circularStrokeCap: CircularStrokeCap.round,
                      progressColor: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            //json datatable
            Container(
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Container(
                  margin: const EdgeInsets.only(left: 50.0),
                  padding: const EdgeInsets.all(16.0),
                  child: toggle
                      ? Column(
                          children: <Widget>[
                            JsonTable(
                              json,
                              showColumnToggle: true,
                              tableHeaderBuilder: (String header) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 4.0),
                                  decoration: BoxDecoration(
                                      border: Border.all(width: 0.5),
                                      color: Colors.blue[300]),
                                  child: Text(
                                    header,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline4
                                        .copyWith(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14.0,
                                            color: Colors.black87),
                                  ),
                                );
                              },
                              tableCellBuilder: (value) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0, vertical: 2.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 0.5,
                                        color: Colors.grey.withOpacity(0.5)),
                                  ),
                                  child: Text(
                                    value,
                                    textAlign: TextAlign.left,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline4
                                        .copyWith(fontSize: 14.0),
                                  ),
                                );
                              },
                              allowRowHighlight: true,
                              rowHighlightColor:
                                  Colors.yellow[500].withOpacity(0.7),
                            ),
                            const SizedBox(
                              height: 40.0,
                            ),
                          ],
                        )
                      : Center(
                          child: Text(getPrettyJSONString(jsonSample)),
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
