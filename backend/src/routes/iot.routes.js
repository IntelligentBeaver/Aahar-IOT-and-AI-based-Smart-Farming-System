// src/routes/iot.routes.js
import express from 'express';
import { led, pump } from '../controllers/iot.controller.js';

const router = express.Router();

// Endpoint to control the LED
router.post('/control-led', led);
router.post('/control-pump', pump)

export default router;
