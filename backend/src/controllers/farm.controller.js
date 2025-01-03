import asyncHandler from "../utils/asyncHandler.js";
import Farm from "../models/farm.model.js";
import { ApiError } from "../utils/apiError.js";
import ApiResponse from "../utils/apiResponse.js";

// Create a new farm
const createFarm = asyncHandler(async (req, res) => {
  const { farmingType, crops, processes, investments } = req.body;

  // Check if farmingType is provided (required field)
  if (!farmingType) {
    throw new ApiError(400, "Farming type is required");
  }

  // Create a new farm, income is omitted since it won't be provided at the start
  const farm = await Farm.create({
    owner: req.user._id,
    farmingType,
    crops: crops || [],
    processes: processes || [],
    investments: investments || [],
    income: [], // Set income to an empty array initially
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

  // Validate income source types
  if (updatedFields.income) {
    updatedFields.income.forEach((inc) => {
      if (
        ![
          "Direct Crop Sale",
          "Wholesale Sale",
          "Export Income",
          "Contract Farming",
          "Seed Sale",
          "other",
        ].includes(inc.source)
      ) {
        throw new ApiError(400, `Invalid income source: ${inc.source}`);
      }
    });
  }

  farm = await Farm.findByIdAndUpdate(farmId, updatedFields, {
    new: true,
    runValidators: true,
  });

  res.status(200).json(new ApiResponse(200, farm, "Farm updated successfully"));
});

// Add income to a farm
const addIncomeToFarm = asyncHandler(async (req, res) => {
  const { farmId } = req.params;
  const { income } = req.body;

  if (!income || !Array.isArray(income) || income.length === 0) {
    throw new ApiError(400, "Income must be provided as a non-empty array");
  }

  // Validate income source types
  income.forEach((inc) => {
    if (
      ![
        "Direct Crop Sale",
        "Wholesale Sale",
        "Export Income",
        "Contract Farming",
        "Seed Sale",
        "other",
      ].includes(inc.source)
    ) {
      throw new ApiError(400, `Invalid income source: ${inc.source}`);
    }
  });

  // Find the farm by ID
  const farm = await Farm.findById(farmId);

  if (!farm) {
    throw new ApiError(404, "Farm not found");
  }

  if (farm.owner.toString() !== req.user._id.toString()) {
    throw new ApiError(
      403,
      "You are not authorized to add income to this farm"
    );
  }

  // Add income to the farm
  farm.income.push(...income);

  // Save the farm with updated income
  await farm.save();

  res.status(200).json(new ApiResponse(200, farm, "Income added successfully"));
});

// Add process (irrigation, fertilizers, pesticides) to a farm
const addProcessToFarm = asyncHandler(async (req, res) => {
  const { farmId } = req.params;
  const { processName, date, description, quantity, unit } = req.body;

  // Validate process type
  if (!["Seeds", "Irrigation", "Fertilizers", "Pesticides"].includes(processName)) {
    throw new ApiError(400, `Invalid process type: ${processName}`);
  }

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
    quantity,
    electricity,
    rate
  };

  farm.processes.push(newProcess);

  // Add the cost to investments only if the processName is "Irrigation"
  if (processName === "Irrigation" && electricity) {
    const investmentDescription = `Process: ${processName}`;
    const processCost = electricity * rate; // Example: Calculate cost dynamically
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
  addIncomeToFarm,
  addProcessToFarm,
  deleteFarm,
};
