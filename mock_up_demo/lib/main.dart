import 'package:flutter/material.dart';

import './models/timeZone.dart';
import 'package:mock_up_demo/databaseHelper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mock up demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Mock up demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final dbHelper = DataBaseHelper.instance;
  List<TimeZone> timeZones = [];

  int _counter = DateTime.now().hour;

  int _mainZone = 0;

  TextEditingController newTimeZoneController = TextEditingController();

  void _incrementCounter() {
    setState(() {
      _counter++;
      if(timeZones.length>0)
      _update(1);
      
      if (_counter == 24) _counter = 0;
    });
  }

  void _decrementCounter() {
    setState(() {
      _counter--;
      if(timeZones.length>0)
      _update(-1);
      if (_counter == -1) _counter = 23;
    });
  }

  void _incrementZone() {
    setState(() {
      _mainZone++;
      if(timeZones.length>0)
      _update(-1);
      if (_mainZone == 13) _mainZone = -11;
    });
  }

  void _decrementZone() {
    setState(() {
      _mainZone--;
      if(timeZones.length>0)
      _update(1);
      if (_mainZone == -12) _mainZone = 12;
    });
  }

  String getZone(int timeZone) {
    if (timeZone == 0) {
      return "UTC";
    } else {
      if (timeZone > 0) {
        return "UTC+" + timeZone.toString();
      } else {
        return "UTC" + timeZone.toString();
      }
    }
  }

  Color getColor(int time) {
    if (time >= 10 && time < 14) {
      return Colors.orange[300];
    }
    if (time >= 6 && time < 10) {
      return Colors.yellow[300];
    }
    if (time >= 14 && time < 18) {
      return Colors.red[300];
    }
    if (time >= 2 && time < 6) {
      return Colors.green[300];
    }
    if (time >= 18 && time < 22) {
      return Colors.purple[300];
    }
    if (time >= 22 || time < 2) {
      return Colors.blue[300];
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Comparison'),
              Tab(text: 'Add new'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Column(
              children: <Widget>[
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        color: Colors.grey,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            RaisedButton(
                              child: Text('Move West'),
                              onPressed: () {
                                _decrementZone();
                              },
                            ),
                            Container(
                              child: Text("Main Time Zone"),
                              padding: EdgeInsets.only(right: 20, left: 20),
                            ),
                            RaisedButton(
                              child: Text('Move East'),
                              onPressed: () {
                                _incrementZone();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  color: getColor(_counter),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text("Maintimezone(${getZone(_mainZone)}): $_counter:00"),
                      Container(
                        padding: EdgeInsets.only(left: 60),
                      ),
                      FloatingActionButton(
                        onPressed: _incrementCounter,
                        tooltip: 'Increment Time',
                        child: Icon(Icons.add),
                      ),
                      FloatingActionButton(
                        onPressed: _decrementCounter,
                        tooltip: 'Decrement Time',
                        child: Icon(Icons.remove),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: timeZones.length + 1,
                    itemBuilder: (BuildContext context, int index) {
                      if (index == timeZones.length) {
                        return BottomAppBar(
                          color: Colors.grey,
                          child: RaisedButton(
                            color: Colors.grey,
                                child: Text('Delete Last Zone'),
                                onPressed: () {
                                  _delete();
                                  _queryAll();
                                },
                              ),
                        );
                      }
                      return Container(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  height: 60,
                                  padding: EdgeInsets.all(10),
                                  color: getColor(timeZones[index].time),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                          "Timezone ${timeZones[index].id} (${getZone(timeZones[index].zone)}): ${timeZones[index].time}:00"),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(20),
                    child: TextField(
                      controller: newTimeZoneController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Enter bettween -11 & 12',
                      ),
                    ),
                  ),
                  
                  RaisedButton(
                                child: Text('Add new'),
                                onPressed: () {
                                  int NTZ=int.parse(newTimeZoneController.text);
                                  _insert(NTZ);
                                  _queryAll();
                                },
                              ),
                ],

            ),
          ],
        ),
      ),
    );
  }

  void _insert(NTZ) async {
    Map<String, dynamic> row = {
      DataBaseHelper.colZone: NTZ,
      DataBaseHelper.colTime: (_counter+(NTZ-_mainZone))%24,
    };
    TimeZone tz = TimeZone.fromMap(row);
    final id = await dbHelper.insert(tz);
  }

  void _queryAll() async {
    final allRows = await dbHelper.queryAllRows();
    timeZones.clear();
    allRows.forEach((row) => timeZones.add(TimeZone.fromMap(row)));

    setState(() {});
  }

  void _delete() async {
    int id = timeZones.length;
    final rowsDeleted = await dbHelper.delete(id);
  }

  void _update(int i) async {
    
    timeZones.forEach((element) async { 
      element.time+=i;
      if (element.time >= 24) element.time = element.time-24;
      else if (element.time <= -1) element.time = element.time+24;
      final rowsAffected = await dbHelper.update(element);
    });
    
  }

  


}
