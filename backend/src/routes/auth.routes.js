import { Router } from "express";
import {
  register,
  login,
  logout,
  refreshAccessToken,
  changeCurrentPassword,
} from "../controllers/auth.controller.js";
import { verifyUser } from "../middlewares/auth.middleware.js";
const router = Router();

router.route("/register").post(register);
router.route("/login").post(login);
router.route("/logout").post(verifyUser, logout);
router.route("/refresh-token").post(verifyUser, refreshAccessToken);
router.route("/change-password").post(verifyUser, changeCurrentPassword);

export default router;
