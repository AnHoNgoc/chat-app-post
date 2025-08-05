import dotenv from "dotenv";
dotenv.config();
import express from "express";
import { forgotPassword, resetPassword, updateProfile, changePassword, getUser } from "../controllers/userController";
import { verifyToken } from "../middlewares/authMiddleware";
import multer from "multer";
const router = express.Router();
import { uploadProfileImage } from "../controllers/userController";
import { resetPasswordSchema } from "../helpers/validation";
import { validateAuth } from "../middlewares/authValidate";


const storage = multer.memoryStorage();
const upload = multer({
    storage,
    limits: { fileSize: 5 * 1024 * 1024 },
});

router.post("/upload-profile-image", upload.single("profile_image"), uploadProfileImage);


router.get("/", verifyToken, getUser);
router.put("/update-profile", verifyToken, updateProfile);
router.patch("/change-password", verifyToken, changePassword);
router.post("/forgot-password", forgotPassword);
router.post("/reset-password", validateAuth(resetPasswordSchema), resetPassword);

export default router;