import { Router } from "express";
import { register, login, logout, createNewToken } from "../controllers/authController";
import { validateAuth } from "../middlewares/authValidate";
import { registerSchema, loginSchema } from "../helpers/validation";


const router = Router();

router.post("/register", validateAuth(registerSchema), register);
router.post("/login", validateAuth(loginSchema), login);
router.post("/logout", logout);
router.post("/refresh-token", createNewToken);


export default router;