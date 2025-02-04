const String apiKey =
    "5c6131e0bd0b648dda6d504f83c1dc6f"; // Store the key securely (environment variables, etc.)
final String baseUrlLogin = "http://192.168.51.189:3000/auth/login";
final String baseUrlRegister = "http://192.168.51.189:3000/auth/register";
final String webSocketUrl = 'ws://192.168.51.189:3000/'; // WebSocket server URL
final String pumpStateUrl = "http://192.168.51.189:3000/iot/control-pump";
final String ledStateUrl = "http://192.168.51.189:3000/iot/control-led";
final String getFarmUrl = "http://192.168.51.189:3000/farm/";
final String imageUrl = "https://model-disease.onrender.com/predict";
// final String imageUrl = "http://192.168.51.189:5000/predict";
final String nationalNewsUrl = "http://192.168.51.189:3000/ai/national-news";
final String internationalNewsUrl =
    "http://192.168.51.189:3000/ai/international-news";

const String ledTurnOnAction = 'led_turn_on';
const String ledTurnOffAction = 'led_turn_off';
const String pumpTurnOnAction = 'pump_turn_on';
const String pumpTurnOffAction = 'pump_turn_off';
