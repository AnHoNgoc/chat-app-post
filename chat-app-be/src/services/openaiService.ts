import dotenv from "dotenv";
dotenv.config();

import OpenAI from "openai";


const openai = new OpenAI({
    apiKey: process.env.OPENAI_API_KEY,

});

export const generateDailyQuestion = async (): Promise<string> => {
    try {
        const response = await openai.chat.completions.create({
            model: "gpt-3.5-turbo",
            messages: [
                { role: "user", content: "Generate a fun and engaging daily question for a chat conversation" }
            ],
            max_tokens: 50
        })
        return response.choices[0]?.message?.content?.trim() || "What's your favorite hobby?"
    } catch (error) {
        console.error("Error generating daily question: ", error);
        return "Here is a random question: What's your favorite book?"
    }
}