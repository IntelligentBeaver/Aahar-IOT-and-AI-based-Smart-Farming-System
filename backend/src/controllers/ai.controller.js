import express from "express";
import asyncHandler from "../utils/asyncHandler.js";
import { ApiError } from "../utils/apiError.js";
import ApiResponse from "../utils/apiResponse.js";
import { PythonShell } from "python-shell";

const router = express.Router();

// Define the /news route
const internationalNews = asyncHandler(async (req, res) => {
  try {
    const newsData = await getInternationalNewsResult();
    console.log("news:", newsData);
    res
      .status(200)
      .json(new ApiResponse(200, newsData, "News data fetched successfully"));
  } catch (error) {
    console.error("Error in fetching news data:", error);
    throw new ApiError(500, "Failed to fetch news data");
  }
});

const getInternationalNewsResult = async () => {
  return new Promise((resolve, reject) => {
    const options = {
      mode: "text",
      pythonOptions: ["-u"],
      scriptPath: "AI_model",
      args: [],
    };

    PythonShell.run("predict.py", options)
      .then((messages) => {
        try {
          // Combine multi-line output, if necessary
          const rawOutput = messages.join("");
          // console.log("Raw Output from Python:", rawOutput);

          // Replace single quotes with double quotes, if necessary
          const formattedOutput = rawOutput.replace(/'/g, '"');
          // console.log("Formatted Output:", formattedOutput);

          // Parse the JSON
          const parsedOutput = JSON.parse(formattedOutput);
          resolve(parsedOutput);
        } catch (parseError) {
          console.error("Error parsing Python output:", parseError);
          reject("Failed to parse data from Python script");
        }
      })
      .catch((error) => {
        console.error("Error in Python script:", error);
        reject("Failed to retrieve data from Python script");
      });
  });
};

// Define the /news route
const nationalNews = asyncHandler(async (req, res) => {
  try {
    const newsData = await getNationalNewsResult();
    console.log("news:", newsData);
    res
      .status(200)
      .json(new ApiResponse(200, newsData, "News data fetched successfully"));
  } catch (error) {
    console.error("Error in fetching news data:", error);
    throw new ApiError(500, "Failed to fetch news data");
  }
});
const getNationalNewsResult = async () => {
  return new Promise((resolve, reject) => {
    const options = {
      mode: "text",
      pythonOptions: ["-u"],
      scriptPath: "AI_model",
      args: [],
    };

    PythonShell.run("national_news.py", options)
      .then((messages) => {
        try {
          // Combine multi-line output, if necessary
          const rawOutput = messages.join("");
          // console.log("Raw Output from Python:", rawOutput);

          // Replace single quotes with double quotes, if necessary
          const formattedOutput = rawOutput.replace(/'/g, '"');
          // console.log("Formatted Output:", formattedOutput);

          // Parse the JSON
          const parsedOutput = JSON.parse(formattedOutput);
          resolve(parsedOutput);
        } catch (parseError) {
          console.error("Error parsing Python output:", parseError);
          reject("Failed to parse data from Python script");
        }
      })
      .catch((error) => {
        console.error("Error in Python script:", error);
        reject("Failed to retrieve data from Python script");
      });
  });
};


//route fo disease Detection where image will be provided
const predictDisease = asyncHandler(async (req, res) => {
  try {
    const cropImage = req.file?.path;

    if (!cropImage) {
      throw new ApiError(400, "Image not provided");
    }

    console.log("Image Path:", cropImage);

    const diseaseData = await getDiseasePredictionResult(cropImage);
    console.log("Disease:", diseaseData);
    res
      .status(200)
      .json(
        new ApiResponse(
          200,
          diseaseData,
          "Disease prediction data fetched successfully"
        )
      );
  } catch (error) {
    console.error("Error in fetching disease prediction data:", error);
    throw new ApiError(500, "Failed to fetch disease prediction data");
  }
});

// Function to get disease prediction data from Python script
const getDiseasePredictionResult = async (cropImage) => {
  return new Promise((resolve, reject) => {
    const options = {
      args: [cropImage],
    };

    PythonShell.run("Image_model/plant_detection.py", options)
      .then((messages) => {
        // Clean the message output
        const cleanedMessages = messages.map((msg) =>
          msg.replace(/[\r\x1B][[A-Za-z0-9]*[A-Za-z]/g, "").trim()
        );
        console.log("Cleaned Output:", cleanedMessages);

        // Resolve with the cleaned output
        resolve(cleanedMessages);
      })
      .catch((error) => {
        console.error("Error in Python script:", error);
        reject("Failed to retrieve data from Python script");
      });
  });
};

export { internationalNews, nationalNews, predictDisease };
