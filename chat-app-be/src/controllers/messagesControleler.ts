import { Request, Response } from "express";
import pool from "../models/db";


export const fetchAllMessageByConversationId = async (req: Request, res: Response): Promise<void> => {

    const { conversationId } = req.params;

    if (!conversationId) {
        res.status(400).json({ error: "Missing conversation ID" });
        return;
    }

    try {
        const result = await pool.query(
            `
            SELECT m.id, m.content, m.sender_id, m.conversation_id, m.created_at
            FROM messages m
            WHERE m.conversation_id = $1
            ORDER BY m.created_at ASC
            `,
            [conversationId]
        );

        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: "Failed to fetch messages" })
    }
}

export const saveMessage = async (conversationId: string, senderId: string, content: string): Promise<any> => {

    if (!conversationId || !senderId || !content) {
        throw new Error("Missing parameters to save message");
    }


    try {
        const result = await pool.query(
            `
           INSERT INTO messages (conversation_id, sender_id, content)
           VALUES ($1, $2, $3)
           Returning *
            `,
            [conversationId, senderId, content]
        );

        return result.rows[0];
    } catch (err) {
        console.error("Error saving message : ", err);
        throw new Error("Failed to save message");
    }
}