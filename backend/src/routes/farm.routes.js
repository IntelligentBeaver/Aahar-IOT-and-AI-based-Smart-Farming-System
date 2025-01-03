import express from "express";
import {
  createFarm,
  getFarmsByOwner,
  updateFarm,
  deleteFarm,
  getFarmById,
} from "../controllers/farm.controller.js";
import { verifyUser } from "../middlewares/auth.middleware.js";

const router = express.Router();

// Route to create a farm
router.post("/", verifyUser, createFarm);

// Route to get all farms of a logged-in user
router.get("/", verifyUser, getFarmsByOwner);

// Route to get a single farm by its ID
router.get("/:farmId", verifyUser, getFarmById);

// Route to update a farm
router.put("/:farmId", verifyUser, updateFarm);

// Route to delete a farm
router.delete("/:farmId", verifyUser, deleteFarm);

export default router;
