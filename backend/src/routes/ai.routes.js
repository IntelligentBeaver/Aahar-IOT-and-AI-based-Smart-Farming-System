import { Router } from "express";
import { 
    nationalNews, internationalNews
} from "../controllers/ai.controller.js";
import { verifyUser } from "../middlewares/auth.middleware.js";

const router= Router()

router.get("/national-news", verifyUser, nationalNews);
router.get("/international-news",verifyUser, internationalNews)


export default router;