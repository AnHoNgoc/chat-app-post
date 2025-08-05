import dotenv from "dotenv";
dotenv.config();

export const SALT_ROUNDS = 10;

export const JWT_ACCESS_CONFIG = {
    key: process.env.ACCESS_TOKEN_SECRET,
    expiresIn: process.env.JWT_ACCESS_EXPRIES_IN,
};

export const JWT_REFRESH_CONFIG = {
    key: process.env.REFRESH_TOKEN_SECRET,
    expiresIn: process.env.JWT_REFRESH_EXPRIES_IN,
};

// Kiểm tra biến môi trường
if (!JWT_ACCESS_CONFIG.key || !JWT_ACCESS_CONFIG.expiresIn) {
    throw new Error("Missing ACCESS TOKEN environment variables");
}

if (!JWT_REFRESH_CONFIG.key || !JWT_REFRESH_CONFIG.expiresIn) {
    throw new Error("Missing REFRESH TOKEN environment variables");
}