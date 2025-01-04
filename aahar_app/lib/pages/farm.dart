import 'package:aahar_app/components/get_crop_tab.dart';
import 'package:aahar_app/components/set_cropt_tab.dart';
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
      body: SafeArea(
        child: Column(
          children: [
            // TabBar at the top
            TabBar(
              controller: _tabBarController,
              indicatorSize: TabBarIndicatorSize.label,
              indicatorWeight: 4,
              tabs: myTabs,
            ),

            // TabBarView dynamically taking up remaining space
            Expanded(
              child: TabBarView(
                controller: _tabBarController,
                children: [
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SetCropTab(),
                    ),
                  ),
                  Center(child: FetchFarmData()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
