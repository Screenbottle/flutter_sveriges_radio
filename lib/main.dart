import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_sveriges_radio/API.dart';
import "package:flutter_sveriges_radio/models/schedule.dart";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'P3 Tablå',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'P3 Tablå Hemsida'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      backgroundColor: Color.fromRGBO(0, 109, 170, 1),
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(child: Image.network('https://static-cdn.sr.se/images/164/2186756_512_512.jpg?preset=api-default-square'),
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            
            
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const RadioSchedulePage(title: 'P3 Tablå')));
                },
                child: Text('Visa Dagens Tablå för P3', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),))
          ],
        ),
      ),
    );
  }
}

class RadioSchedulePage extends StatefulWidget {
  const RadioSchedulePage({super.key, required this.title});

  final String title;

  @override
  State<RadioSchedulePage> createState() => _RadioScheduleState();
}

class _RadioScheduleState extends State<RadioSchedulePage> {
  ScrollController _controller = ScrollController();
  List<Program> _schedule = [];

  int _totalPages = 1;
  int _page = 1;

  void _fetchFirstPage() async {
    final response = await API.getData(_page);
    setState(() {
      _schedule = response.schedule;
      _totalPages = response.pagination.totalPages;
      _page = response.pagination.page;
    });
    print(_totalPages);
    print(_page);
  }

  void _fetchOtherPage() async {
    if (_page < _totalPages) {
      final response = await API.getData(_page);
      setState(() {
        _schedule.addAll(response.schedule);
        _page = response.pagination.page;
      });
    }
  }

  void _setupScrollController() {
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_controller.offset >= _controller.position.maxScrollExtent) {
      _page++;
      _fetchOtherPage();
    }
  }

  @override
  void initState() {
    _fetchFirstPage();
    _setupScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(0, 109, 170, 1),
      appBar: AppBar(
        title: Text('Dagens program i P3'),
      ),
      body: Builder(
        builder: (context) {
          if (_schedule.isEmpty) {
            return (const Center(
              child: CircularProgressIndicator(),
            ));
          }
          return (buildScheduleList(_schedule));
        },
      ),
    );
  }

  DateTime _parseDate(String jsonDate) {
    // Extract the milliseconds from the JSON date string
    String millisecondsString = jsonDate.replaceAll(RegExp(r'[^0-9]'), '');
    int milliseconds = int.parse(millisecondsString);

    // Convert milliseconds since epoch to DateTime
    return DateTime.fromMillisecondsSinceEpoch(milliseconds);
  }

  String _formatTime(String time) {
    // Format hours and minutes with leading zeros if necessary
    return time.toString().padLeft(2, '0');
  }

  Widget buildScheduleList(List<Program> schedule) {
    return ListView.builder(
        controller: _controller,
        itemCount: schedule.length,
        itemBuilder: ((context, index) {
          final program = schedule[index];
          print(_parseDate(program.startTimeUTC).hour);
          final startDateTime = _parseDate(program.startTimeUTC);
          final endDateTime = _parseDate(program.endTimeUTC);

          return Container(
            color: const Color.fromRGBO(185, 214, 242, 1),
            width: double.maxFinite,
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            child: ExpansionTile(
              leading: Container(
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                  height: 100,
                  child: Image.network(
                      program.imageUrl ?? program.defaultImageUrl)),
              title: Text(program.title + (' ${program.subtitle ?? ''}'), style: TextStyle(fontWeight: FontWeight.bold),),
              subtitle: Text('${_formatTime(startDateTime.hour.toString())}:${_formatTime(startDateTime.minute.toString())} - ${_formatTime(endDateTime.hour.toString())}:${_formatTime(endDateTime.minute.toString())}'),
              children: [
                Text(program.description),
              ],
            ),
          );

          /*return Container(
            color: const Color.fromRGBO(185, 214, 242, 1),
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            height: 100,
            width: double.maxFinite,
            child: Row(
              children: [
                Expanded(
                    flex: 1,
                    child: Image.network(
                        program.imageUrl ?? program.defaultImageUrl)),
                SizedBox(width: 10),
                Expanded(flex: 3, child: Text(program.title + (' ${program.subtitle ?? ''}')))
              ],
            ),
          );*/
        }));
  }
}
