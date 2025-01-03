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
  
// export const pump = (req, res) => {
//     const { action } = req.body; // Expecting action in the request body
  
//     if (!action || (action !== 'pump_turn_on' && action !== 'pump_turn_off')) {
//       return res.status(400).json({ message: 'Invalid action' });
//     }
  
//     // Send the command to WebSocket to control the ESP32 pump
//     if (wss.clients.size > 0) { // Ensure there is a WebSocket client connected
//       wss.clients.forEach(client => {
//         if (client.readyState === 1) {
//           client.send(action); // Send the action to the WebSocket client (ESP32)
//         }
//       });
//       return res.status(200).json({ message: `Pump: ${action}` });
//     } else {
//       return res.status(500).json({ message: 'No WebSocket client connected' });
//     }
// }
  
export const pump = (req, res) => {
  const { action, time } = req.body; // Expecting action and optional time in the request body

  // Validate the action
  if (!action || (action !== 'pump_turn_on' && action !== 'pump_turn_off')) {
    return res.status(400).json({ message: 'Invalid action' });
  }

  // Validate the time if provided
  if (time && (typeof time !== 'number' || time <= 0)) {
    return res.status(400).json({ message: 'Invalid time value. Time must be a positive number.' });
  }

  // Send the action to the WebSocket clients
  if (wss.clients.size > 0) {
    wss.clients.forEach((client) => {
      if (client.readyState === 1) {
        client.send(action); // Send the action to the WebSocket client (ESP32)
      }
    });

    // If the action is "pump_turn_on" and a time is provided, set a timer
    if (action === 'pump_turn_on' && time) {
      setTimeout(() => {
        wss.clients.forEach((client) => {
          if (client.readyState === 1) {
            client.send('pump_turn_off'); // Automatically turn off the pump after the specified time
          }
        });
        console.log(`Pump automatically turned off after ${time} seconds.`);
      }, time * 1000); // Convert time from seconds to milliseconds
    }

    return res.status(200).json({
      message: `Pump: ${action}`,
      ...(time && action === 'pump_turn_on' && { autoTurnOff: `Pump will turn off automatically after ${time} seconds.` }),
    });
  } else {
    return res.status(500).json({ message: 'No WebSocket client connected.' });
  }
};
