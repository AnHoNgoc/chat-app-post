import cron from "node-cron";
import pool from "../models/db";
import { generateDailyQuestion } from "../services/openaiService";
import dotenv from "dotenv";
dotenv.config();

const AI_BOT_ID = process.env.AI_BOT_ID;

cron.schedule("0 9 * * *", async () => {
    try {

        if (!AI_BOT_ID) {
            console.error("Missing AI_BOT_ID env variable");
            return;
        }

        const conversations = await pool.query("SELECT id FROM conversations");
        for (const conversation of conversations.rows) {
            const question = await generateDailyQuestion();

            if (!question) {
                console.error("No question generated.");
                return;
            }

            await pool.query(
                `
                INSERT INTO messages (conversation_id, sender_id, content)
                VALUES ($1, $2, $3)
                `,
                [conversation.id, AI_BOT_ID, question]
            );
            console.log(`Daily question sent for conversation ${conversation.id}`)
        }

    } catch (error) {
        console.error("Error in daily question job: ", error);
    }
})