import asyncHandler from "../utils/asyncHandler.js";
import User from "../models/user.model.js";
import { ApiError } from "../utils/apiError.js";
import ApiResponse from "../utils/apiResponse.js";

const register = asyncHandler(async (req, res) => {
  const { email, password } = req.body;
  console.log(req.body);

  if ([email, password].some((field) => field.trim() === "")) {
    throw new ApiError(404, "All fields are required");
  }

  const existedUser = await User.findOne({ email });

  if (existedUser) {
    throw new ApiError(409, "User with email already exists");
  }

  const user = await User.create({
    email,
    password: password,
  });

  if (!user) {
    throw new ApiError(400, "Error occurred while saving user data");
  }

  const { accessToken, refreshToken } = await generateAccessAndRefreshTokens(
    user
  );

  res
    .status(201)
    .json(
      new ApiResponse(
        201,
        { accessToken, refreshToken, user },
        "User registered successfully"
      )
    );
});

const generateAccessAndRefreshTokens = async (user) => {
  try {
    const accessToken = await user.generateAccessToken();
    const refreshToken = await user.generateRefreshToken();

    user.refreshToken = refreshToken;
    await user.save({ validateBeforeSave: false });
    return { accessToken, refreshToken };
  } catch (error) {
    console.log(
      "there was error while generating the access and refresh token",
      error.message
    );
  }
};

const login = asyncHandler(async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    throw new ApiError(400, "Email and password are required");
  }

  const user = await User.findOne({ email });

  if (!user) {
    throw new ApiError(404, "User with this email does not exist");
  }

  const userPasswordCheck = await user.isPasswordCorrect(password);
  if (!userPasswordCheck) {
    throw new ApiError(403, "Password does not match");
  }

  const { accessToken, refreshToken } = await generateAccessAndRefreshTokens(
    user
  );

  const loggedInUser = await User.findById(user._id).select(
    "-password -refreshToken"
  );

  res
    .status(200)
    .json(
      new ApiResponse(
        200,
        { accessToken, refreshToken, user: loggedInUser },
        "User logged in successfully"
      )
    );
});

const logout = asyncHandler(async (req, res) => {
  const user = req.user;

  const loggedOutUser = await User.findByIdAndUpdate(
    user._id,
    {
      $unset: { refreshToken: 1 },
    },
    { new: true }
  );

  res
    .status(200)
    .json(new ApiResponse(200, {}, "User logged out successfully"));
});

const refreshAccessToken = asyncHandler(async (req, res) => {
  const incomingRefreshToken =
    req.cookies.refreshToken || req.body.refreshToken;

  if (!incomingRefreshToken) {
    throw new ApiError(401, "User not authorized");
  }

  try {
    const decodedToken = jwt.verify(
      incomingRefreshToken,
      process.env.REFRESH_TOKEN_SECRET
    );

    if (!decodedToken) {
      throw new ApiError(401, "User not authorized");
    }

    const user = await User.findById(decodedToken?._id);

    if (!user || user.refreshToken !== incomingRefreshToken) {
      throw new ApiError(401, "Invalid or expired refresh token");
    }

    const { newAccessToken, newRefreshToken } =
      await generateAccessAndRefreshTokens(user);

    res
      .status(200)
      .json(
        new ApiResponse(
          200,
          { accessToken: newAccessToken, refreshToken: newRefreshToken },
          "Access token refreshed successfully"
        )
      );
  } catch (error) {
    throw new ApiError(401, error.message || "Invalid refresh token");
  }
});

const changeCurrentPassword = asyncHandler(async (req, res) => {
  const { oldPassword, newPassword } = req.body;

  if (!oldPassword || !newPassword) {
    throw new ApiError(400, "old and new password are required");
  }

  const user = await User.findById(req?.user._id);

  if (!user) {
    throw new ApiError(404, "User not found");
  }

  const isPasswordCorrect = await user.isPasswordCorrect(oldPassword);
  if (!isPasswordCorrect) {
    throw new ApiError(400, "Invalid old  password");
  }
  user.password = newPassword;
  await user.save({ validateBeforeSave: false });

  return res
    .status(200)
    .json(new ApiResponse(200, {}, "password Changed successfully"));
});

export { register, login, logout, refreshAccessToken, changeCurrentPassword };
