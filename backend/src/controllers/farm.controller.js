import asyncHandler from "../utils/asyncHandler.js";
import Farm from "../models/farm.model.js";
import { ApiError } from "../utils/apiError.js";
import ApiResponse from "../utils/apiResponse.js";

// Create a new farm
const createFarm = asyncHandler(async (req, res) => {
  const { address, farmingType, crops, processes, investments, income } =
    req.body;

  if (!farmingType || !address) {
    throw new ApiError(400, "Farming type and address are required");
  }

  const farm = await Farm.create({
    owner: req.user._id,
    address,
    farmingType,
    crops: crops || [],
    processes: processes || [],
    investments: investments || [],
    income: income || [],
  });

  res.status(201).json(new ApiResponse(201, farm, "Farm created successfully"));
});

// Get all farms owned by the logged-in user
const getFarmsByOwner = asyncHandler(async (req, res) => {
  const farms = await Farm.find({ owner: req.user._id });

  if (!farms || farms.length === 0) {
    throw new ApiError(404, "No farms found for this user");
  }

  res
    .status(200)
    .json(new ApiResponse(200, farms, "Farms retrieved successfully"));
});

// Get a single farm by ID
const getFarmById = asyncHandler(async (req, res) => {
  const { farmId } = req.params;

  const farm = await Farm.findById(farmId);

  if (!farm) {
    throw new ApiError(404, "Farm not found");
  }

  if (farm.owner.toString() !== req.user._id.toString()) {
    throw new ApiError(403, "You are not authorized to view this farm");
  }

  res
    .status(200)
    .json(new ApiResponse(200, farm, "Farm details retrieved successfully"));
});

// Update a farm
const updateFarm = asyncHandler(async (req, res) => {
  const { farmId } = req.params;

  let farm = await Farm.findById(farmId);

  if (!farm) {
    throw new ApiError(404, "Farm not found");
  }

  if (farm.owner.toString() !== req.user._id.toString()) {
    throw new ApiError(403, "You are not authorized to update this farm");
  }

  const updatedFields = req.body;

  farm = await Farm.findByIdAndUpdate(farmId, updatedFields, {
    new: true,
    runValidators: true,
  });

  res.status(200).json(new ApiResponse(200, farm, "Farm updated successfully"));
});

const addProcessToFarm = asyncHandler(async (req, res) => {
  const { farmId } = req.params;
  const { processName, date, description, duration, quantity, unit, method } =
    req.body;

  let farm = await Farm.findById(farmId);

  if (!farm) {
    throw new ApiError(404, "Farm not found");
  }

  if (farm.owner.toString() !== req.user._id.toString()) {
    throw new ApiError(403, "You are not authorized to update this farm");
  }

  // Add the new process
  const newProcess = {
    processName,
    date,
    description,
    duration,
    quantity,
    unit,
    method,
  };

  farm.processes.push(newProcess);

  // Optionally, add the cost of the process to investments
  if (quantity && unit) {
    const investmentDescription = `Process: ${processName}`;
    const processCost = quantity * 10; // Example: You can calculate cost dynamically
    farm.investments.push({
      category: processName,
      amount: processCost,
      date: date || new Date(),
      description: investmentDescription,
    });
  }

  // Save the updated farm
  await farm.save();

  res
    .status(200)
    .json(new ApiResponse(200, farm, "Process added to the farm successfully"));
});

// Delete a farm
const deleteFarm = asyncHandler(async (req, res) => {
  const { farmId } = req.params;

  const farm = await Farm.findById(farmId);

  if (!farm) {
    throw new ApiError(404, "Farm not found");
  }

  if (farm.owner.toString() !== req.user._id.toString()) {
    throw new ApiError(403, "You are not authorized to delete this farm");
  }

  await farm.remove();

  res.status(200).json(new ApiResponse(200, {}, "Farm deleted successfully"));
});

export {
  createFarm,
  getFarmsByOwner,
  getFarmById,
  updateFarm,
  addProcessToFarm,
  deleteFarm,
};
