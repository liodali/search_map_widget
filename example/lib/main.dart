import 'package:flutter/material.dart';
import 'package:map_search_widget/map_search_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return AdvancedSearchMap(
      map: const Center(
        child: Text("map"),
      ),
      bottomSearchInformationWidget: ListView.builder(
        shrinkWrap: true,
        itemExtent: 50,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (ctx, index) {
          return ListTile(
            title: Text("item $index"),
          );
        },
        itemCount: 20,
      ),
      topSearchInformationWidget: Column(
        children: [
          const SizedBox(
            height: 32,
          ),
          SizedBox(
            height: 56,
            child: Row(
              children: [
                TextButton(
                  onPressed: () {},
                  child: const Icon(Icons.close),
                ),
                const Text("Search"),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              right: 16,
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 96,
                ),
                Expanded(
                  child: Column(
                    children: const [
                      TextField(
                        decoration: InputDecoration(
                          label: Text("start"),
                        ),
                      ),
                      TextField(
                        decoration: InputDecoration(
                          label: Text("destination"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      bottomElevation: 8.0,
      bottomSearchRadius: 24.0,
      maxBottomSearchSize: 0.80,
    );
  }
}
