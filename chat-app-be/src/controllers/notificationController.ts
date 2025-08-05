import dotenv from "dotenv";
dotenv.config();
import { Request, Response } from "express";
import pool from "../models/db";
import axios from "axios";
import { GoogleAuth } from "google-auth-library";
import path from "path";

export const saveFcmToken = async (req: Request, res: Response): Promise<any> => {
    const { fcmToken } = req.body;
    const userId = req.user?.id;

    if (!userId || !fcmToken) {
        return res.status(400).json({ error: "Missing userId or fcmToken" });
    }

    try {
        const result = await pool.query(
            "SELECT user_id FROM fcm_tokens WHERE token = $1",
            [fcmToken]
        );

        if (result.rowCount && result.rows[0].user_id === userId) {

            return res.status(200).json({ message: "FCM token already registered" });
        }

        // 🔁 Nếu token đã gắn với user khác → xóa đi để tránh xung đột
        await pool.query("DELETE FROM fcm_tokens WHERE token = $1", [fcmToken]);

        await pool.query(
            "INSERT INTO fcm_tokens (user_id, token) VALUES ($1, $2)",
            [userId, fcmToken]
        );

        return res.status(200).json({ message: "FCM token saved successfully" });

    } catch (error) {
        console.error("❌ Error saving FCM token:", error);
        return res.status(500).json({ error: "Internal server error" });
    }
};

const PROJECT_ID = "chat-app-nodejs-f77bf";

const SERVICE_ACCOUNT_PATH = path.resolve(__dirname, "../config/service-account.json");

export const sendPushNotification = async (
    fcmToken: string,
    title: string,
    body: string,
    conversationId: string,
    mate: string,
    profileImage: string
) => {
    try {
        const auth = new GoogleAuth({
            keyFile: SERVICE_ACCOUNT_PATH,
            scopes: ["https://www.googleapis.com/auth/firebase.messaging"],
        });

        const client = await auth.getClient();
        const accessToken = await client.getAccessToken();

        if (!accessToken || !accessToken.token) {
            console.error("❌ Failed to retrieve access token.");
            return;
        }

        const message = {
            message: {
                token: fcmToken,
                notification: {
                    title,
                    body,
                },
                android: {
                    priority: "high",
                    notification: {
                        sound: "default",
                        clickAction: "FLUTTER_NOTIFICATION_CLICK",
                    },
                },
                apns: {
                    payload: {
                        aps: {
                            sound: "default",
                        },
                    },
                },
                data: {
                    click_action: "FLUTTER_NOTIFICATION_CLICK",
                    title,
                    body,
                    type: "chat",
                    conversationId,
                    mate, 
                    profileImage
                },
            },
        };

        console.log("📤 Sending push notification:", message);

        const response = await axios.post(
            `https://fcm.googleapis.com/v1/projects/${PROJECT_ID}/messages:send`,
            message,
            {
                headers: {
                    Authorization: `Bearer ${accessToken.token}`,
                    "Content-Type": "application/json",
                },
            }
        );

        console.log("✅ Push notification sent:", response.data);
    } catch (error) {
        console.error("❌ Failed to send push notification:", error);
    }
};

export const getUserFcmToken = async (userId: string): Promise<string[]> => {
    try {
        const result = await pool.query(
            "SELECT token FROM fcm_tokens WHERE user_id = $1",
            [userId]
        );
        return result.rows.map(row => row.token);
    } catch (error) {
        console.error("Error fetching FCM token:", error);
        return [];
    }
};


export const getReceiverIdFromConversation = async (
    conversationId: string,
    senderId: string
): Promise<string | null> => {
    try {
        const result = await pool.query(
            `
            SELECT 
                CASE 
                    WHEN participant_one = $2 THEN participant_two
                    WHEN participant_two = $2 THEN participant_one
                    ELSE NULL
                END AS receiver_id
            FROM conversations
            WHERE id = $1
            `,
            [conversationId, senderId]
        );
        return result.rows[0]?.receiver_id || null;
    } catch (error) {
        console.error("Error fetching receiver ID:", error);
        return null;
    }
};