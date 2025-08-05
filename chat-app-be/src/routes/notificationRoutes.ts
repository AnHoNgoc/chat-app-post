import { Router } from "express";
import { verifyToken } from "../middlewares/authMiddleware";
import { saveFcmToken } from "../controllers/notificationController";

const router = Router();

router.post("/save-token", verifyToken, saveFcmToken);

export default router;