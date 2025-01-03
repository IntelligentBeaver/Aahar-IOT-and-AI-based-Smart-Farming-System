import 'dart:convert';
import 'dart:ui';
import 'package:aahar_app/components/daily_forecasts.dart';
import 'package:aahar_app/components/hourly_forecasts.dart';
import '../components/additional_information.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

class Forecasting extends StatefulWidget {
  const Forecasting({super.key});

  @override
  State<Forecasting> createState() => _ForecastingState();
}

class _ForecastingState extends State<Forecasting> {
  late Future<Map<String, dynamic>> weather;
  String locationName = "Your Location";
  String _apiKey =
      "5c6131e0bd0b648dda6d504f83c1dc6f"; // Store the key securely (environment variables, etc.)

  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      // Get the user's current location
      Position position = await _determinePosition();

      final double latitude = position.latitude;
      final double longitude = position.longitude;

      // Call OpenWeatherMap API with latitude and longitude
      final res = await http.get(
        Uri.parse(
            'https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&appid=$_apiKey'),
      );

      final jsonvalue = jsonDecode(res.body);
      if (int.parse(jsonvalue['cod']) != 200) {
        throw "Error fetching weather data.";
      }

      // Update the location name
      setState(() {
        locationName = jsonvalue['city']['name'];
      });

      return jsonvalue;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw "Location services are disabled.";
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw "Location permissions are denied.";
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw "Location permissions are permanently denied.";
    }

    // Get the current position
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: weather,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          final data = snapshot.data!;

          final currentWeatherData = data['list'][0];
          final currentTemp =
              (currentWeatherData['main']['temp'] - 273.15).toStringAsFixed(0);

          final currentWeather = currentWeatherData['weather'][0]['main'];
          final currentHumidity = currentWeatherData['main']['humidity'];
          final currentPressure = currentWeatherData['main']['pressure'];
          final currentWindSpeed = currentWeatherData['wind']['speed'];

          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Weather
                Row(
                  children: [
                    Expanded(
                      flex: 9,
                      child: Text(
                        "Weather for $locationName",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            weather = getCurrentWeather();
                          });
                        },
                        icon: const Icon(Icons.refresh),
                      ),
                    ),
                  ],
                ),
                // Main weather card
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                "$currentTemp°C",
                                style: const TextStyle(
                                    fontSize: 32, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              Icon(
                                currentWeather == "Clouds" ||
                                        currentWeather == "Rain"
                                    ? Icons.cloud
                                    : Icons.sunny,
                                size: 64,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                currentWeather,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Weather Forecast Section
                const SizedBox(height: 16),
                const Text(
                  "3-Hour Forecast",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 140,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 8,
                    itemBuilder: (context, index) {
                      final forecast = data['list'][index + 1];
                      final time =
                          DateTime.parse(forecast['dt_txt'].toString());
                      final weatherCondition =
                          forecast['weather'][0]['main']; // Extract condition

                      return HourlyForecast(
                        time: DateFormat.Hm().format(time),
                        temperature:
                            "${(forecast['main']['temp'] - 273.15).toStringAsFixed(0)}°C",
                        weatherCondition: weatherCondition, // Pass condition
                      );
                    },
                  ),
                ),
                // Daily Weather Forecast Section
                const SizedBox(height: 16),
                const Text(
                  "Daily Forecast",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 5, // Show forecasts for 5 days
                  itemBuilder: (context, index) {
                    // Filter data to only include forecasts for the next 5 days, at around 12:00 PM
                    final List dailyForecasts = data['list']
                        .where((forecast) =>
                            DateTime.parse(forecast['dt_txt']).hour == 12)
                        .toList();

                    final dailyData = dailyForecasts[index];
                    final date = DateTime.parse(dailyData['dt_txt']);
                    final weatherCondition = dailyData['weather'][0]['main'];

                    return DailyForecast(
                      day: index == 0
                          ? "Today" // Show "Today" for the first day
                          : DateFormat.E().format(
                              date), // Get the day of the week (e.g., Sun, Mon)
                      temperature:
                          "${(dailyData['main']['temp'] - 273.15).toStringAsFixed(0)}°C",
                      weatherCondition: weatherCondition,
                    );
                  },
                ),

                // Additional Information Section
                const SizedBox(height: 16),
                const Text(
                  "Additional Information",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AdditionalInformation(
                      icon: Icons.water_drop,
                      title: "Humidity",
                      value: '$currentHumidity',
                    ),
                    AdditionalInformation(
                      icon: Icons.wind_power,
                      title: "Wind Speed",
                      value: '$currentWindSpeed',
                    ),
                    AdditionalInformation(
                      icon: Icons.line_weight,
                      title: "Pressure",
                      value: '$currentPressure',
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
