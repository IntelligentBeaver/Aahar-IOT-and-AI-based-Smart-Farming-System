import "dotenv/config";
import connectDb from "./config/mongoose.connection.js";
import app from "./app.js";
import { WebSocketServer } from "ws";
import http from "http";
const port = process.env.PORT;


// Create an HTTP server to use with WebSocket
const server = http.createServer(app);

// Set up WebSocket server
const wss = new WebSocketServer({ server });

wss.on("connection", (ws) => {
  console.log("WebSocket client connected");

  ws.on("message", (message) => {
    try {
      const data = JSON.parse(message.toString());
      console.log("Received from client:", data);

      // Broadcast data to all connected frontend clients
      wss.clients.forEach((client) => {
        if (client !== ws && client.readyState === 1) {
          client.send(JSON.stringify(data)); // Send data to frontend
        }
      });
    } catch (error) {
      console.error("Error parsing message:", error);
    }
  });

  ws.on("close", () => {
    console.log("WebSocket client disconnected");
  });
});


export { wss };

// Connect to the database and start the server
connectDb()
  .then(() => {
    server.listen(port, () => {
      console.log(`Server started at http://localhost:${port}`);
      console.log(`WebSocket server started`);
    });
  })
  .catch((error) => {
    console.log("Error connecting to the database:", error);
  });

