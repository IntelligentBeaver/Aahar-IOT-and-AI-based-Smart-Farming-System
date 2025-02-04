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

  // Separate loading and error states for National and International News
  bool _isNationalLoading = true;
  bool _hasNationalError = false;

  bool _isInternationalLoading = true;
  bool _hasInternationalError = false;

  int _selectedOption = 0; // 0 for National News, 1 for International News

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
        _isNationalLoading = true;
        _hasNationalError = false;
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
          _isNationalLoading = false;
        });
      } else {
        setState(() {
          _isNationalLoading = false;
          _hasNationalError = true;
        });
      }
    } catch (e) {
      setState(() {
        _isNationalLoading = false;
        _hasNationalError = true;
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
        _isInternationalLoading = true;
        _hasInternationalError = false;
      });

      final response =
          await http.get(Uri.parse(_internationalNewsUrl), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> intArticles = data['data']['filtered_results'];

        setState(() {
          internationalArticleList = intArticles.map((article) {
            return {
              'title': article['title'],
              'url': article['url'],
            };
          }).toList();
          _isInternationalLoading = false;
        });
      } else {
        setState(() {
          _isInternationalLoading = false;
          _hasInternationalError = true;
        });
      }
    } catch (e) {
      setState(() {
        _isInternationalLoading = false;
        _hasInternationalError = true;
      });
    }
  }

  // Open URL in the browser
  void openUrl(String url) async {
    final Uri uri = Uri.parse(url);

    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open the link: $url')),
        );
      }
    } catch (e) {
      debugPrint('Error launching URL: $url, Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> currentArticles =
        _selectedOption == 0 ? nationalArticleList : internationalArticleList;

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 17,
                child: _selectedOption == 0
                    ? _isNationalLoading
                        ? Center(child: CircularProgressIndicator())
                        : _hasNationalError
                            ? Center(
                                child: ElevatedButton(
                                  onPressed: findNationalResponse,
                                  child: const Text("Retry National News"),
                                ),
                              )
                            : buildArticleList(nationalArticleList)
                    : _isInternationalLoading
                        ? Center(child: CircularProgressIndicator())
                        : _hasInternationalError
                            ? Center(
                                child: ElevatedButton(
                                  onPressed: findInternationalResponse,
                                  child: const Text("Retry International News"),
                                ),
                              )
                            : buildArticleList(internationalArticleList),
              ),
            ],
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: Row(
              children: [
                FloatingActionButton.extended(
                  heroTag: "btn1",
                  backgroundColor: _selectedOption == 0
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surface,
                  label: const Text("National"),
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
                  label: const Text("International"),
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

  // Helper widget to display articles
  Widget buildArticleList(List<Map<String, dynamic>> articles) {
    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        return Padding(
          padding: const EdgeInsets.all(6.0),
          child: Card(
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                    onPressed: () => openUrl(article['url']),
                    child: const Text("Read More"),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
