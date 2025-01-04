import { wss } from '../index.js'; 
import Farm from "../models/farm.model.js";

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
  
// export const pump = (req, res) => {
//   const { action, time } = req.body; // Expecting action and optional time in the request body

//   // Validate the action
//   if (!action || (action !== 'pump_turn_on' && action !== 'pump_turn_off')) {
//     return res.status(400).json({ message: 'Invalid action' });
//   }

//   // Validate the time if provided
//   if (time && (typeof time !== 'number' || time <= 0)) {
//     return res.status(400).json({ message: 'Invalid time value. Time must be a positive number.' });
//   }

//   // Send the action to the WebSocket clients
//   if (wss.clients.size > 0) {
//     wss.clients.forEach((client) => {
//       if (client.readyState === 1) {
//         client.send(action); // Send the action to the WebSocket client (ESP32)
//       }
//     });

//     // If the action is "pump_turn_on" and a time is provided, set a timer
//     if (action === 'pump_turn_on' && time) {
//       setTimeout(() => {
//         wss.clients.forEach((client) => {
//           if (client.readyState === 1) {
//             client.send('pump_turn_off'); // Automatically turn off the pump after the specified time
//           }
//         });
//         console.log(`Pump automatically turned off after ${time} seconds.`);
//       }, time * 1000); // Convert time from seconds to milliseconds
//     }

//     return res.status(200).json({
//       message: `Pump: ${action}`,
//       ...(time && action === 'pump_turn_on' && { autoTurnOff: `Pump will turn off automatically after ${time} seconds.` }),
//     });
//   } else {
//     return res.status(500).json({ message: 'No WebSocket client connected.' });
//   }
// };


const power = 0.18; // The constant power usage (kWh or similar)

export const pump = async (req, res) => {
  const { action, time, farmId } = req.body; // Expecting action, optional time, and farmId in the request body

  // Validate the action
  if (!action || (action !== 'pump_turn_on' && action !== 'pump_turn_off')) {
    return res.status(400).json({ message: 'Invalid action' });
  }

  // Validate the time if provided
  if (time && (typeof time !== 'number' || time <= 0)) {
    return res.status(400).json({ message: 'Invalid time value. Time must be a positive number.' });
  }

  // Validate the farmId
  if (!farmId) {
    return res.status(400).json({ message: 'farmId is required to record processes and investments.' });
  }

  // Fetch the farm and validate ownership
  const farm = await Farm.findById(farmId);
  if (!farm) {
    return res.status(404).json({ message: 'Farm not found.' });
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
      let pumpStartTime = Date.now(); // Store the timestamp when the pump is turned on

      setTimeout(async () => {
        wss.clients.forEach((client) => {
          if (client.readyState === 1) {
            client.send('pump_turn_off'); // Automatically turn off the pump after the specified time
          }
        });

        const pumpOnDuration = (Date.now() - pumpStartTime) / 1000; // Calculate time in seconds
        const electricity = pumpOnDuration * power; // Calculate electricity usage

        const newProcess = {
          processName: 'Irrigation',
          date: new Date(),
          description: 'Pump irrigation process.',
          quantity: pumpOnDuration,
          electricity: electricity,
        };

        // console.log("farm", farm);
        // Add the process and investment to the farm
        addProcessAndInvestmentToFarm(farm, newProcess, electricity);

      }, time * 1000);
    }

    // If the action is "pump_turn_off", calculate how long the pump was on
    if (action === 'pump_turn_off' && pumpStartTime) {
      const pumpOnDuration = (Date.now() - pumpStartTime) / 1000; // Calculate time in seconds
      pumpStartTime = null; // Reset the timestamp

      const electricity = pumpOnDuration * power; // Calculate electricity usage

      const newProcess = {
        processName: 'Irrigation',
        date: new Date(),
        description: 'Pump irrigation process.',
        quantity: pumpOnDuration,
        electricity: electricity,
      };

      // Add the process and investment to the farm
      addProcessAndInvestmentToFarm(farm, newProcess, electricity);
    }

    return res.status(200).json({
      message: `Pump: ${action}`,
      ...(time && action === 'pump_turn_on' && { autoTurnOff: `Pump will turn off automatically after ${time} seconds.` }),
    });
  } else {
    return res.status(500).json({ message: 'No WebSocket client connected.' });
  }
};

// Helper function to add a process and investment to the farm
const addProcessAndInvestmentToFarm = async (farm, newProcess, electricity) => {
  const rate = 0.5; // Example electricity rate per unit
  const processCost = electricity * rate;

  // Add the new process to the farm
  farm.processes.push(newProcess);

  // Add the investment cost
  const investmentDescription = `Process: ${newProcess.processName}`;
  farm.investments.push({
    category: newProcess.processName,
    amount: processCost,
    date: new Date(),
    description: investmentDescription,
  });

  // Save the updated farm
  await farm.save();
};
