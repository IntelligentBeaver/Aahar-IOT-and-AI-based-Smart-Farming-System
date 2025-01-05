import 'dart:convert';
import 'package:aahar_app/components/secrets.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class News extends StatefulWidget {
  const News({super.key});

  @override
  State<News> createState() => _NewsState();
}

class _NewsState extends State<News> {
  List<Map<String, dynamic>> nationalArticleList = [];
  List<Map<String, dynamic>> internationalArticleList = [];
  bool _isLoading = true; // Track loading state
  bool _hasError = false; // Track error state

  @override
  void initState() {
    super.initState();
    findNationalResponse();
    findInternationalResponse();
  }

  // Fetch National News
  Future<void> findNationalResponse() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    final _nationalNewsUrl = nationalNewsUrl;

    try {
      setState(() {
        _isLoading = true;
        _hasError = false; // Reset error state
      });

      final response = await http.get(Uri.parse(_nationalNewsUrl), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> articles = data['data']['national_articles'];

        setState(() {
          nationalArticleList = articles.map((article) {
            return {
              'title': article['title'],
              'url': article['url'],
            };
          }).toList();
          _isLoading = false; // Stop loading on successful fetch
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true; // Set error state if response is not 200
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true; // Set error state on exception
      });
    }
  }

  // Fetch International News
  Future<void> findInternationalResponse() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    final _internationalNewsUrl = internationalNewsUrl;

    try {
      setState(() {
        _isLoading = true;
        _hasError = false; // Reset error state
      });

      final response =
          await http.get(Uri.parse(_internationalNewsUrl), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> intarticles = data['data']['filtered_results'];

        setState(() {
          internationalArticleList = intarticles.map((article) {
            return {
              'title': article['title'],
              'url': article['url'],
            };
          }).toList();
          _isLoading = false; // Stop loading on successful fetch
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true; // Set error state if response is not 200
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true; // Set error state on exception
      });
    }
  }

  // Function to launch URL in the browser
  // Open URL in the browser
  void openUrl(String url) async {
    final Uri uri = Uri.parse(url); // Convert the URL string to a Uri object

    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        // If launchUrl fails, show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open the link: $url')),
        );
      }
    } catch (e) {
      // Handle any errors
      debugPrint('Error launching URL: $url, Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  PageController pageController = PageController(
    initialPage: 0,
    viewportFraction: 0.90,
  );

  int _selectedOption = 0; // 0 for National News, 1 for International News

  @override
  Widget build(BuildContext context) {
    // Get the articles based on the selected option
    List<Map<String, dynamic>> currentArticles =
        _selectedOption == 0 ? nationalArticleList : internationalArticleList;

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 17,
                child: _isLoading
                    ? Center(
                        child:
                            CircularProgressIndicator(), // Show loading indicator
                      )
                    : _hasError
                        ? Center(
                            child: ElevatedButton(
                              onPressed: () {
                                // Retry fetching the data
                                if (_selectedOption == 0) {
                                  findNationalResponse();
                                } else {
                                  findInternationalResponse();
                                }
                              },
                              child: Text("Retry"),
                            ),
                          )
                        : PageView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount: currentArticles.isNotEmpty
                                ? currentArticles.length
                                : 1, // Show at least one placeholder if no articles
                            padEnds: true,

                            controller: pageController,
                            itemBuilder: (context, index) {
                              if (currentArticles.isEmpty) {
                                // Placeholder when no articles are available
                                return const Center(
                                  child: Text(
                                    "No news available at the moment.",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                );
                              }

                              // Display the article content
                              final article = currentArticles[index];
                              return Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: Card(
                                    elevation: 5,
                                    surfaceTintColor:
                                        Theme.of(context).colorScheme.primary,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            article['title'],
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 10),
                                          ElevatedButton(
                                            onPressed: () {
                                              // Open the URL in the browser
                                              openUrl(article['url']);
                                            },
                                            child: const Text("Read More"),
                                          ),
                                        ],
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
            left: 16,
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
