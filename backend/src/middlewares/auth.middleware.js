import jwt from "jsonwebtoken";
import userModel from "../models/user.model.js";
import { ApiError } from "../utils/apiError.js";

export const verifyUser = async (req, _, next) => {
  try {
    const token = req.header("Authorization").replace("Bearer ", "");

    if (!token) {
      throw new ApiError(401, "Unauthorized request");
    }

    const decodedToken = jwt.verify(token, process.env.ACCESS_TOKEN_SECRET);

    if (!decodedToken) {
      throw new ApiError(204, "there was error in jwt verify");
    }

    const user = await userModel
      .findById(decodedToken._id)
      .select("-password -refreshToken");

    if (!user) {
      throw new ApiError(204, "Invalid access token");
    }

    req.user = user;
    next();
  } catch (error) {
    throw new ApiError(401, error?.message || "Unauthorized request");
  }
};
