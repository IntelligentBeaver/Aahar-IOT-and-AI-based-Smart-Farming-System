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
              return _buildLoading();
            } else if (snapshot.hasError) {
              return _buildError(snapshot.error, context);
            } else if (snapshot.hasData) {
              return _buildPredictionResult(snapshot.data!, context);
            } else {
              return _buildError("Unexpected error occurred.", context);
            }
          },
        ),
      ),
    );
  }

  // Loading state UI
  Widget _buildLoading() {
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
  }

  // Error state UI
  Widget _buildError(Object? error, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error,
          color: Colors.red,
          size: 50,
        ),
        SizedBox(height: 20),
        Text(
          "Error: $error",
          style: TextStyle(color: Colors.red, fontSize: 18),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            // Retry fetching data
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ResponsePage(responseFuture: responseFuture)),
            );
          },
          child: Text("Retry"),
        ),
      ],
    );
  }

  // Prediction result UI
  Widget _buildPredictionResult(String response, BuildContext context) {
    try {
      print(response);

      final Map<String, dynamic> responseData = jsonDecode(response);
      print(responseData);

      final List<dynamic> data = responseData["data"] ?? [];
      print(data);

// Extract predicted class
      final String predictedClass = _extractInfo(data, "Predicted Class");

// Extract confidence and handle invalid or missing values
      final String confidenceScoreValue =
          _extractInfo(data, "Confidence Score");
      String confidenceScore;

      try {
        // Try parsing the confidence score to a double
        confidenceScore =
            (double.parse(confidenceScoreValue) * 100).toStringAsFixed(1);
      } catch (e) {
        // Handle cases where confidenceScoreValue is not a valid number
        confidenceScore = "N/A";
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 80),
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
                  style: TextStyle(fontSize: 52, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 20),
                Text(
                  "Class:",
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.w600),
                ),
                Text(
                  "$predictedClass",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w400),
                ),
                SizedBox(height: 20),
                Text(
                  "Confidence:",
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.w600),
                ),
                Text(
                  "$confidenceScore%",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      return _buildError("Error parsing response: $e", context);
    }
  }

  // Helper method to extract relevant information from the response data
  String _extractInfo(List<dynamic> data, String key) {
    try {
      return data
          .firstWhere((item) => item.startsWith("$key: "))
          .replaceFirst("$key: ", "");
    } catch (e) {
      return "N/A"; // In case the key is not found
    }
  }
}
