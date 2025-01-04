import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FarmDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> farmData;

  const FarmDetailsScreen({super.key, required this.farmData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Farming Type: ${farmData['farmingType']}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Crops:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            ...farmData['crops'].map<Widget>((crop) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Crop Name: ${crop['cropName']}'),
                  Text('Planting Date: ${crop['plantingDate']}'),
                  Text('Harvesting Date: ${crop['harvestingDate']}'),
                  Text('Quantity: ${crop['quantity']}'),
                  Text('Amount: ${crop['amount']}'),
                  const Divider(),
                ],
              );
            }).toList(),
            Text(
              'Investments:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            ...farmData['investments'].map<Widget>((investment) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Category: ${investment['category'] ?? "N/A"}'),
                  Text('Amount: ${investment['amount']}'),
                  Text('Date: ${investment['date']}'),
                  Text('Description: ${investment['description']}'),
                  const Divider(),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class FetchFarmData extends StatefulWidget {
  const FetchFarmData({super.key});

  @override
  State<FetchFarmData> createState() => _FetchFarmDataState();
}

class _FetchFarmDataState extends State<FetchFarmData> {
  List<dynamic> farmDataList = []; // Store the list of farms
  bool isLoading = false; // To show loading indicator

  // Function to retrieve the access token from SharedPreferences
  Future<String?> getAccessToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(
        'accessToken'); // Retrieve token using the key 'access_token'
  }

  // Function to fetch the data
  Future<void> fetchFarmData() async {
    setState(() {
      isLoading = true;
    });

    final String url = 'http://192.168.196.187:3000/farm';

    try {
      String? accessToken = await getAccessToken();

      if (accessToken == null) {
        setState(() {
          farmDataList = []; // Token not found
          isLoading = false;
        });
        return;
      }

      final http.Response response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          var data = json.decode(response.body)['data'];
          farmDataList = data; // Store the list of farms
          isLoading = false;
        });
      } else {
        setState(() {
          farmDataList = []; // Error in fetching data
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        farmDataList = [];
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchFarmData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Data'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchFarmData, // Call fetchFarmData to refresh the data
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (isLoading) const CircularProgressIndicator(),
            if (!isLoading && farmDataList.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: farmDataList.length,
                  itemBuilder: (context, index) {
                    var farm = farmDataList[index];

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: ListTile(
                        title: Text(
                          'Farming Type: ${farm['farmingType']}',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                        subtitle: Text('Crop Type: ${farm['createdAt']}'),
                        trailing: Icon(Icons.arrow_forward),
                        onTap: () {
                          // Navigate to the details screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FarmDetailsScreen(
                                farmData: farm, // Passing the farm data
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            if (!isLoading && farmDataList.isEmpty)
              const Text('No farm data available'),
          ],
        ),
      ),
    );
  }
}
