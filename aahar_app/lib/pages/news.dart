import 'package:flutter/material.dart';

class News extends StatefulWidget {
  const News({super.key});

  @override
  State<News> createState() => _NewsState();
}

class _NewsState extends State<News> {
  PageController pageController = PageController(
    initialPage: 0,
    viewportFraction: 0.90,
  );

  int _selectedOption = 0; // 0 for National News, 1 for International News

  // Sample data for news
  final List<String> nationalNews = [
    "National News 1",
    "National News 2",
    "National News 3",
    "National News 4",
  ];

  final List<String> internationalNews = [
    "International News 1",
    "International News 2",
    "International News 3",
    "International News 4",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 17,
                child: PageView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: 4,
                  padEnds: true,
                  physics: const BouncingScrollPhysics(
                    decelerationRate: ScrollDecelerationRate.fast,
                  ),
                  controller: pageController,
                  itemBuilder: (context, index) {
                    // Display the news based on the selected option
                    String newsText = _selectedOption == 0
                        ? nationalNews[index]
                        : internationalNews[index];
                    return Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: Card(
                          surfaceTintColor:
                              Theme.of(context).colorScheme.primary,
                          child: Center(
                            child: Text(
                              newsText,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          // Floating buttons overlay
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton.extended(
                  heroTag: "btn1",
                  backgroundColor: _selectedOption == 0
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surface,
                  label: const Text(
                    "National",
                  ),
                  icon: const Icon(Icons.home),
                  onPressed: () {
                    setState(() {
                      _selectedOption = 0;
                    });
                  },
                ),
                const SizedBox(width: 8),
                FloatingActionButton.extended(
                  heroTag: "btn2",
                  backgroundColor: _selectedOption == 1
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surface,
                  label: const Text(
                    "International",
                  ),
                  icon: const Icon(Icons.public),
                  onPressed: () {
                    setState(() {
                      _selectedOption = 1;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
