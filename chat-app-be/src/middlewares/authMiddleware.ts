import dotenv from "dotenv";
dotenv.config();
import { Request, Response, NextFunction } from "express";
import jwt, { TokenExpiredError, JsonWebTokenError } from "jsonwebtoken";
import pool from "../models/db";
import { JwtPayload } from "jsonwebtoken";
import { JWT_REFRESH_CONFIG } from "../config";

const secret = process.env.ACCESS_TOKEN_SECRET;

if (!secret) {
    throw new Error("Missing ACCESS_TOKEN_SECRET in environment variables");
}

export const verifyToken = (req: Request, res: Response, next: NextFunction): void => {
    const authHeader = req.headers.authorization;
    const token = authHeader?.startsWith("Bearer ") ? authHeader.split(" ")[1] : undefined;

    if (!token) {
        res.status(401).json({
            message: "Access token is missing"
        });
        return;
    }

    try {
        const decoded = jwt.verify(token, secret);
        req.user = decoded as { id: string };
        next();
    } catch (error: any) {
        if (error instanceof TokenExpiredError) {
            res.status(401).json({
                message: "Token has expired"
            });
        } else if (error instanceof JsonWebTokenError) {
            res.status(401).json({
                message: "Invalid access token"
            });
        } else {
            res.status(500).json({
                message: "Token verification failed"
            });
        }
    }
};


interface RefreshTokenPayload extends JwtPayload {
    id: string;
}

export const verifyRefreshToken = async (token: string): Promise<RefreshTokenPayload> => {

    try {
        const decoded = jwt.verify(token, JWT_REFRESH_CONFIG.key!) as RefreshTokenPayload;

        if (!decoded || !decoded.id) {
            throw new Error("Invalid token payload");
        }

        const userId = decoded.id;

        const result = await pool.query(
            `SELECT token, expires_at FROM user_refresh_tokens WHERE user_id = $1`,
            [userId]
        );

        if (result.rowCount === 0) {
            throw new Error("No refresh token found for user");
        }

        const { token: storedToken, expires_at } = result.rows[0];

        if (storedToken !== token) {
            throw new Error("Refresh token mismatch");
        }

        if (new Date(expires_at) < new Date()) {
            throw new Error("Refresh token has expired");
        }

        return decoded;

    } catch (error: any) {
        console.error("Error verifying refresh token:", error.message);
        throw new Error("Invalid or expired refresh token");
    }
};