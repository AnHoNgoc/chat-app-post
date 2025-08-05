import dotenv from "dotenv";
dotenv.config();
import { Request, Response } from "express";
import bcrypt from "bcrypt";
import pool from "../models/db";
import jwt from "jsonwebtoken";
import { JWT_ACCESS_CONFIG } from "../config";
import { findUserByEmail, hashPassword } from "./authController";

import { UploadApiResponse } from "cloudinary";
import { v2 as cloudinary } from "cloudinary";
import streamifier from "streamifier";
import { sendEmail } from "../helpers/sendEmail";



cloudinary.config({
    cloud_name: process.env.CLOUD_NAME,
    api_key: process.env.CLOUD_API_KEY,
    api_secret: process.env.CLOUD_API_SECRET,
});

const streamUpload = (fileBuffer: Buffer): Promise<UploadApiResponse> => {
    return new Promise((resolve, reject) => {
        const stream = cloudinary.uploader.upload_stream({ folder: "profile_images" }, (error, result) => {
            if (result) resolve(result);
            else reject(error);
        });

        streamifier.createReadStream(fileBuffer).pipe(stream);
    });
};



export const uploadProfileImage = async (req: Request, res: Response) => {
    if (!req.file) {
        res.status(400).json({ message: "No file uploaded" });
        return;
    }

    try {
        const result = await streamUpload(req.file.buffer);
        res.status(200).json({ message: "Upload success", url: result.secure_url });
    } catch (error) {
        res.status(500).json({ message: "Upload failed", error });
        return;
    }
};

export const getUser = async (req: Request, res: Response) => {
    const userId = req.user?.id;

    if (!userId) {
        res.status(401).json({ message: "Unauthorized" });
        return;
    }

    try {
        const result = await pool.query(
            "SELECT email, username, profile_image FROM users WHERE id = $1",
            [userId]
        );

        if (result.rowCount === 0) {
            res.status(404).json({ message: "User not found" });
            return;
        }

        res.status(200).json(result.rows[0]);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Error retrieving profile" });
    }
};

export const getUserById = async (userId: string) => {
    try {
        const result = await pool.query(
            "SELECT username, profile_image FROM users WHERE id = $1",
            [userId]
        );
        return result.rows[0] || null;
    } catch (error) {
        console.error("❌ Error getting user:", error);
        return null;
    }
};

export const updateProfile = async (req: Request, res: Response) => {
    const userId = req.user?.id;

    const { username, profile_image } = req.body;

    if (!username && !profile_image) {
        res.status(400).json({ message: "Missing username and profile_image" });
        return;
    }

    try {
        const result = await pool.query(
            "UPDATE users SET username = $1, profile_image = $2 WHERE id = $3 RETURNING id, email, username, profile_image",
            [username, profile_image, userId]
        );

        res.status(200).json({ message: "Profile updated successfully", user: result.rows[0] });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Error updating profile" });
    }
};


export const changePassword = async (req: Request, res: Response) => {
    const userId = req.user?.id;

    if (!userId) {
        res.status(401).json({ message: "Unauthorized" });
        return;
    }

    const { oldPassword, newPassword } = req.body;

    if (!oldPassword || !newPassword) {
        res.status(400).json({ message: "Missing old password or new password" });
        return;
    }


    try {
        const result = await pool.query("SELECT password FROM users WHERE id = $1", [userId]);
        if (result.rowCount === 0) {
            res.status(404).json({ message: "User not found" });
            return;
        }

        const isMatch = await bcrypt.compare(oldPassword, result.rows[0].password);
        if (!isMatch) {
            res.status(400).json({ message: "Old password is incorrect" });
            return;
        }

        const hashedPassword = await hashPassword(newPassword);

        await pool.query("UPDATE users SET password = $1 WHERE id = $2", [hashedPassword, userId]);

        res.status(200).json({ message: "Password updated successfully" });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Server error" });
    }
};

export const forgotPassword = async (req: Request, res: Response) => {
    const { email } = req.body;

    if (!process.env.FRONTEND_RESET_LINK) {
        res.status(500).json({ message: "Server misconfiguration" });
        return;
    }

    try {
        const user = await findUserByEmail(email);

        // Không tiết lộ tài khoản có tồn tại hay không
        if (!user) {
            res.status(200).json({
                message: "If this email is registered, a reset link will be sent",
            });
            return;
        }

        const token = jwt.sign(
            { id: user.id },
            JWT_ACCESS_CONFIG.key!,
            { expiresIn: '15m' }
        );

        const resetLink = `${process.env.FRONTEND_RESET_LINK}?token=${token}`;

        // Gửi email
        await sendEmail(
            email,
            "Reset Your Password",
            `
      <p>Click the link below to reset your password:</p>
      <p><a href="${resetLink}" style="color: blue;">Open app to reset password</a></p>
      <p>Or copy this link:</p>
      <p style="word-break: break-all;">${resetLink}</p>
      <p>This link will expire in 15 minutes.</p>
      `
        );

        res.status(200).json({ message: "Reset link sent to email" });
    } catch (error) {
        console.error("Forgot password error:", error);
        res.status(500).json({ message: "Something went wrong" });
    }
};


export const resetPassword = async (req: Request, res: Response) => {
    const { token, newPassword } = req.body;

    try {
        const decoded = jwt.verify(token, JWT_ACCESS_CONFIG.key!) as { id: number };

        const userResult = await pool.query("SELECT id FROM users WHERE id = $1", [decoded.id]);
        if (userResult.rowCount === 0) {
            res.status(404).json({ message: "User not found" });
            return;
        }

        const hashedPassword = await hashPassword(newPassword);

        await pool.query(
            "UPDATE users SET password = $1 WHERE id = $2",
            [hashedPassword, decoded.id]
        );

        res.status(200).json({ message: "Password has been reset successfully" });
    } catch (error) {
        console.error(error);
        res.status(400).json({ message: "Invalid or expired token" });
    }
};