import { Router } from "express";
import { 
    nationalNews, internationalNews, predictDisease
} from "../controllers/ai.controller.js";
import upload from "../middlewares/multer.middleware.js";
import { verifyUser } from "../middlewares/auth.middleware.js";

const router= Router()

router.get("/national-news", verifyUser, nationalNews);
router.get("/international-news", verifyUser, internationalNews)
router.post("/predict-disease", verifyUser, upload.single("cropImage"),predictDisease)

export default router;