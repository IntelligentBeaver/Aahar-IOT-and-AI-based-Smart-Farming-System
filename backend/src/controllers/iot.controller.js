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
const rate = 0.5; // Example rate per unit of electricity used (you can adjust this value)

export const pump = async(req, res) => {
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
      pumpStartTime = Date.now(); // Store the timestamp when the pump is turned on

      setTimeout(async() => {
        wss.clients.forEach((client) => {
          if (client.readyState === 1) {
            client.send('pump_turn_off'); // Automatically turn off the pump after the specified time
          }
        });

        const pumpOnDuration = (Date.now() - pumpStartTime) / 1000; // Calculate time in seconds

        // Calculate electricity usage in kWh or similar unit
        const electricity = pumpOnDuration * power; // Using the formula: unit = time * power
        console.log(`Pump automatically turned off after ${time} seconds. It was on for ${pumpOnDuration} seconds, using ${electricity} units of electricity.`);

        // Example of adding the process to the farm's processes
        const newProcess = {
          processName: 'Irrigation', // Example process name
          date: new Date(),
          description: 'Pump irrigation process.',
          quantity: pumpOnDuration,
          electricity: electricity,
        };

        // Add the new process to the farm
        addProcessToFarm(newProcess);

        // Add investment cost after the process
        const investmentDescription = `Process: ${newProcess.processName}`;
        const processCost = electricity * rate; // Calculate cost dynamically based on electricity usage and rate

        // Example of pushing the investment details into the farm's investments array
        farm.investments.push({
          category: newProcess.processName,
          amount: processCost,
          date: new Date(),
          description: investmentDescription,
        });

        // Save the updated farm with the new process and investment
        await farm.save();

      }, time * 1000); // Convert time from seconds to milliseconds
    }

    // If the action is "pump_turn_off", calculate how long the pump was on
    if (action === 'pump_turn_off' && pumpStartTime) {
      const pumpOnDuration = (Date.now() - pumpStartTime) / 1000; // Calculate time in seconds
      pumpStartTime = null; // Reset the timestamp after turning off

      // Calculate electricity usage in kWh or similar unit
      const electricity = pumpOnDuration * power; // Using the formula: unit = time * power
      console.log(`Pump turned off manually after being on for ${pumpOnDuration} seconds, using ${electricity} units of electricity.`);

      // Example of adding the process to the farm's processes
      const newProcess = {
        processName: 'Irrigation', // Example process name
        date: new Date(),
        description: 'Pump irrigation process.',
        quantity: pumpOnDuration,
        electricity: electricity,
      };

      // Add the new process to the farm
      addProcessToFarm(newProcess);

      // Add investment cost after the process
      const investmentDescription = `Process: ${newProcess.processName}`;
      const processCost = electricity * rate; // Calculate cost dynamically based on electricity usage and rate

      // Example of pushing the investment details into the farm's investments array
      farm.investments.push({
        category: newProcess.processName,
        amount: processCost,
        date: new Date(),
        description: investmentDescription,
      });

      // Save the updated farm with the new process and investment
      await farm.save();
    }

    return res.status(200).json({
      message: `Pump: ${action}`,
      ...(time && action === 'pump_turn_on' && { autoTurnOff: `Pump will turn off automatically after ${time} seconds.` }),
    });
  } else {
    return res.status(500).json({ message: 'No WebSocket client connected.' });
  }
};

// Function to add process to farm (as per the existing example)
const addProcessToFarm = async (newProcess) => {
  const { farmId, date, description, quantity, electricity } = newProcess;

  let farm = await Farm.findById(farmId);

  if (!farm) {
    throw new ApiError(404, "Farm not found");
  }

  if (farm.owner.toString() !== req.user._id.toString()) {
    throw new ApiError(403, "You are not authorized to update this farm");
  }

  // Add the new process
  farm.processes.push(newProcess);

  // Save the updated farm
  await farm.save();
};
