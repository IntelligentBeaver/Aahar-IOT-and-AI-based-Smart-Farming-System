import express from "express";
import asyncHandler from "../utils/asyncHandler.js";
import { ApiError } from "../utils/apiError.js";
import ApiResponse from "../utils/apiResponse.js";
import { PythonShell } from "python-shell";

const router = express.Router();

// Define the /news route
const internationalNews = asyncHandler(async (req, res) => {
  try {
    const newsData = await getPredictionResult();
    console.log("news:", newsData);
    res
      .status(200)
      .json(new ApiResponse(200, newsData, "News data fetched successfully"));
  } catch (error) {
    console.error("Error in fetching news data:", error);
    throw new ApiError(500, "Failed to fetch news data");
  }
});

// Function to get news data from Python script
const getPredictionResult = async () => {
  return new Promise((resolve, reject) => {
    const options = {
      mode: "text",
      pythonOptions: ["-u"], // Unbuffered output from Python
      scriptPath: "AI_model", // Path to your Python script
      args: [], // Add arguments if needed
    };

    PythonShell.run("predict.py", options)
      .then((messages) => {
        // Parse the Python output to JSON
        console.log(messages[0]);
        const rawResults = messages[0];
        console.log(rawResults);
        const formattedResults = JSON.parse(rawResults.replace(/'/g, '"'));
        resolve(formattedResults);
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

// Function to get news data from Python script
const getNationalNewsResult = async () => {
  return new Promise((resolve, reject) => {
    const options = {
      mode: "text",
      pythonOptions: ["-u"], // Unbuffered output from Python
      scriptPath: "AI_model", // Path to your Python script
      args: [], // Add arguments if needed
    };

    PythonShell.run("national_news.py", options)
      .then((messages) => {
          // Parse the Python output to JSON
          // console.log(messages)
        // console.log("mmmm:", messages);
        console.log("oooooo:", messages);
        // const rawResults = JSON.parse(messages);
        // const rawResults = messages[0];
        // console.log("Raw Python Output:", rawResults);
        // console.log("Raw Python Output:", messages[0]);
        // const formattedResults = JSON.parse(messages[0].replace(/'/g, '"'));
        resolve(messages);
      })
      .catch((error) => {
        console.error("Error in Python script:", error);
        reject("Failed to retrieve data from Python script");
      });
  });
};

export { internationalNews, nationalNews };
