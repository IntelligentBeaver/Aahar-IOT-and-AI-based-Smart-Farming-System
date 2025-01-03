import { wss } from '../index.js'; 

export const led = (req, res) => {
    const { action } = req.body; // Expecting action in the request body
  
    if (!action || (action !== 'led_turn_on' && action !== 'led_turn_off')) {
      return res.status(400).json({ message: 'Invalid action' });
    }
  
    // Send the command to WebSocket to control the ESP32 LED
    if (wss.clients.size > 0) { // Ensure there is a WebSocket client connected
      wss.clients.forEach(client => {
        if (client.readyState === 1) {
          client.send(action); // Send the action to the WebSocket client (ESP32)
        }
      });
      return res.status(200).json({ message: `LED: ${action}` });
    } else {
      return res.status(500).json({ message: 'No WebSocket client connected' });
    }
};
  
export const pump = (req, res) => {
    const { action } = req.body; // Expecting action in the request body
  
    if (!action || (action !== 'pump_turn_on' && action !== 'pump_turn_off')) {
      return res.status(400).json({ message: 'Invalid action' });
    }
  
    // Send the command to WebSocket to control the ESP32 pump
    if (wss.clients.size > 0) { // Ensure there is a WebSocket client connected
      wss.clients.forEach(client => {
        if (client.readyState === 1) {
          client.send(action); // Send the action to the WebSocket client (ESP32)
        }
      });
      return res.status(200).json({ message: `Pump: ${action}` });
    } else {
      return res.status(500).json({ message: 'No WebSocket client connected' });
    }
}
  