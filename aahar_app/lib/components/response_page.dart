import 'dart:convert';

import 'package:flutter/material.dart';

class ResponsePage extends StatelessWidget {
  final Future<String> responseFuture; // Future for the response body

  ResponsePage({required this.responseFuture});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Disease Prediction"),
      ),
      body: Center(
        child: FutureBuilder<String>(
          future: responseFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text(
                    "Processing...",
                    style: TextStyle(fontSize: 24),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return Text(
                "Error: ${snapshot.error}",
                style: TextStyle(color: Colors.red),
              );
            } else if (snapshot.hasData) {
              print(snapshot.data);
              try {
                final Map<String, dynamic> responseData =
                    jsonDecode(snapshot.data!);
                final List<dynamic> data = responseData["data"] ?? [];

                final String predictedClass = data
                    .firstWhere((item) => item.startsWith("Predicted Class: "))
                    .replaceFirst("Predicted Class: ", "");
                final String confidenceScore = data
                    .firstWhere((item) => item.startsWith("Confidence Score: "))
                    .replaceFirst("Confidence Score: ", "");

                return Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 80, 10, 80),
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Prediction Result:",
                            style: TextStyle(
                                fontSize: 52, fontWeight: FontWeight.w800),
                          ),
                          SizedBox(height: 20),
                          Text(
                            "Class: $predictedClass",
                            style: TextStyle(
                                fontSize: 34, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            "Confidence: $confidenceScore",
                            style: TextStyle(
                                fontSize: 34, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } catch (e) {
                return Text(
                  "Error parsing response: $e",
                  style: TextStyle(color: Colors.red),
                );
              }
            } else {
              return Text("Something went wrong.");
            }
          },
        ),
      ),
    );
  }
}
