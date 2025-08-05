import dotenv from "dotenv";
dotenv.config();
import { Request, Response } from "express";
import bcrypt from "bcrypt";
import pool from "../models/db";
import jwt from "jsonwebtoken";
import { JWT_ACCESS_CONFIG, JWT_REFRESH_CONFIG, SALT_ROUNDS } from "../config";
import ms from 'ms';
import { verifyRefreshToken } from "../middlewares/authMiddleware";
import { PoolClient } from "pg";

export const hashPassword = async (userPassword: string): Promise<string> => {
    const hashedPassword = await bcrypt.hash(userPassword, SALT_ROUNDS);
    return hashedPassword;
}

export const findUserByEmail = async (email: string) => {
    const result = await pool.query("SELECT * FROM users WHERE email = $1", [email]);
    return result.rows[0];
};

const saveRefreshToken = async (userId: string, refreshToken: string, expiresAt: Date, client: PoolClient) => {
    try {
        await pool.query(
            'INSERT INTO user_refresh_tokens (user_id, token, created_at, expires_at) VALUES ($1, $2, NOW(), $3)',
            [userId, refreshToken, expiresAt]
        );
    } catch (err) {
        console.error("Failed to save refresh token:", err);
        throw err;
    }
};

export const register = async (req: Request, res: Response): Promise<any> => {

    const { username, email, password } = req.body;
    try {

        const isExist = await findUserByEmail(email);

        if (isExist) {
            return res.status(400).json({ message: "Email is already registered" });
        }

        const hashedPassword = await hashPassword(password)
        await pool.query(
            "INSERT INTO users (username, email, password) VALUES ($1, $2, $3) RETURNING *",
            [username, email, hashedPassword]
        );

        return res.status(201).json({
            message: "Create new account successful",
        });

    } catch (error) {
        console.log(error);
        return res.status(500).json({
            message: "Register failed",
        });
    }
};


export const login = async (req: Request, res: Response): Promise<any> => {
    const { email, password } = req.body;

    const client = await pool.connect();

    try {
        const user = await findUserByEmail(email);

        if (!user) {
            return res.status(404).json({ error: "User not found" });
        }

        const isMatch = await bcrypt.compare(password, user.password);

        if (!isMatch) {
            return res.status(401).json({ error: "Invalid credentials" });
        }

        const accessToken = jwt.sign(
            { id: user.id },
            JWT_ACCESS_CONFIG.key!,
            { expiresIn: JWT_ACCESS_CONFIG.expiresIn as jwt.SignOptions["expiresIn"] }
        );

        const refreshToken = jwt.sign(
            { id: user.id },
            JWT_REFRESH_CONFIG.key!,
            { expiresIn: JWT_REFRESH_CONFIG.expiresIn as jwt.SignOptions["expiresIn"] }
        );

        const expiresInStr = "7d";
        const expiresInMs = ms(expiresInStr);
        const expiresAt = new Date(Date.now() + (expiresInMs as number));

        // Bắt đầu transaction
        await client.query("BEGIN");

        await client.query(
            'DELETE FROM user_refresh_tokens WHERE user_id = $1',
            [user.id]
        );

        await saveRefreshToken(user.id, refreshToken, expiresAt, client);

        await client.query("COMMIT");

        return res.status(200).json({
            message: "Logged in successfully",
            accessToken,
            refreshToken,
            user: {
                id: user.id,
                username: user.username,
                email: user.email,
                profileImage: user.profile_image
            }
        });
    } catch (error) {
        await client.query("ROLLBACK");
        console.error(error);
        return res.status(500).json({ message: "Login failed" });
    } finally {
        client.release();
    }
};

export const logout = async (req: Request, res: Response): Promise<any> => {
    try {
        const { refreshToken } = req.body;

        if (!refreshToken) {
            return res.status(400).json({ message: "Missing refresh token" });
        }

        let decoded;
        try {
            decoded = await verifyRefreshToken(refreshToken);
        } catch (err) {
            return res.status(401).json({ message: "Invalid or expired token" });
        }

        const userId = decoded.id;

        try {
            await pool.query(
                'DELETE FROM user_refresh_tokens WHERE user_id = $1 AND token = $2',
                [userId, refreshToken]
            );
        } catch (dbErr) {
            console.error("DB error during logout:", dbErr);
            return res.status(500).json({ message: "Database error" });
        }

        return res.status(200).json({ message: "User logged out successfully" });
    } catch (e) {
        console.error("Unexpected logout error:", e);
        return res.status(500).json({ message: "Unexpected server error" });
    }
};

export const createNewToken = async (req: Request, res: Response): Promise<any> => {
    const { refreshToken } = req.body;

    if (!refreshToken) {
        return res.status(400).json({
            message: 'Refresh token is required',
        });
    }

    try {
        const decoded = await verifyRefreshToken(refreshToken);

        if (!decoded) {
            return res.status(403).json({
                message: 'Invalid or expired refresh token',
            });
        }

        const payload = {
            id: decoded.id,
        };

        const accessToken = jwt.sign(
            { id: payload.id },
            JWT_ACCESS_CONFIG.key!,
            { expiresIn: JWT_ACCESS_CONFIG.expiresIn as jwt.SignOptions["expiresIn"] }
        );

        return res.status(200).json({
            message: "Created new token successfully",
            data: {
                accessToken
            }
        });

    } catch (error: any) {
        console.error('Error refreshing token:', error.message);
        return res.status(500).json({
            message: 'Server error while refreshing token',
        });
    }
};

