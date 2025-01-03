import express from "express";
import {
  createFarm,
  getFarmsByOwner,
  getFarmById,
  updateFarm,
  addIncomeToFarm,
  addProcessToFarm,
  deleteFarm,
} from "../controllers/farm.controller.js";
import { verifyUser } from "../middlewares/auth.middleware.js";

const router = express.Router();

// Route to create a new farm (POST)
router.post("/", verifyUser, createFarm);

// Route to get all farms owned by the logged-in user (GET)
router.get("/", verifyUser, getFarmsByOwner);

// Route to get a single farm by ID (GET)
router.get("/:farmId", verifyUser, getFarmById);

// Route to update a farm (PATCH)
router.patch("/:farmId", verifyUser, updateFarm);

// Route to add income to a farm (PATCH)
router.patch("/:farmId/income", verifyUser, addIncomeToFarm);

// Route to add process to a farm (PATCH)
router.patch("/:farmId/process", verifyUser, addProcessToFarm);

// Route to delete a farm (DELETE)
router.delete("/:farmId", verifyUser, deleteFarm);

export default router;
