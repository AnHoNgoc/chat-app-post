import { Router } from "express";
import { verifyToken } from "../middlewares/authMiddleware";
import { fetchAllConversationsByUserId, checkOnCreateConversation, getDailyQuestion } from "../controllers/conversationsController";

const router = Router();

router.get("/", verifyToken, fetchAllConversationsByUserId)
router.post("/check-or-create", verifyToken, checkOnCreateConversation)
router.post("/:id/daily-question", verifyToken, getDailyQuestion)


export default router;