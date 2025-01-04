import 'package:flutter/material.dart';

class Farm extends StatefulWidget {
  const Farm({super.key});

  @override
  State<Farm> createState() => _FarmState();
}

class _FarmState extends State<Farm> with SingleTickerProviderStateMixin {
  final List<Tab> myTabs = <Tab>[
    Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.keyboard_double_arrow_down,
          ),
          Text('Set Crop'),
        ],
      ),
    ),
    Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.keyboard_double_arrow_up,
          ),
          Text('Get Crop'),
        ],
      ),
    ),
  ];
  late TabController _tabBarController;

  @override
  void initState() {
    super.initState();
    _tabBarController = TabController(vsync: this, length: myTabs.length);
  }

  @override
  void dispose() {
    _tabBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TabBar(
            dividerHeight: 0.2,
            indicatorSize: TabBarIndicatorSize.label,
            enableFeedback: true,
            indicatorWeight: 4,
            controller: _tabBarController,
            tabs: myTabs,
          ),
          SizedBox(
            height: 150,
            child: TabBarView(controller: _tabBarController, children: [
              Center(
                child: Text("1"),
              ),
              Center(
                child: Text("2"),
              ),
            ]),
          )
        ],
      ),
    );
  }
}
