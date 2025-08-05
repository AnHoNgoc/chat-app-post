import dotenv from "dotenv";
dotenv.config();

import express from "express";
import http from "http";
import { Server } from "socket.io";
import authRoutes from "./routes/authRoutes";
import conversationsRoutes from "./routes/conversationsRoutes";
import messagesRoutes from "./routes/messagesRoutes";
import contactssRoutes from "./routes/contactsRoutes";
import userRoutes from "./routes/userRoutes";
import notificationRoutes from "./routes/notificationRoutes";
import { saveMessage } from "./controllers/messagesControleler";
import "./cron/cronJob";
import { sendPushNotification, getUserFcmToken, getReceiverIdFromConversation } from "./controllers/notificationController";
import { getUserById } from "./controllers/userController";
const app = express();
const server = http.createServer(app)
const PORT = process.env.PORT || 3000;

app.use(express.json());


const io = new Server(server, {
    cors: {
        origin: "*"
    }
})

app.use("/auth", authRoutes)
app.use("/conversations", conversationsRoutes)
app.use("/messages", messagesRoutes)
app.use("/contacts", contactssRoutes)
app.use("/user", userRoutes)
app.use("/fcm", notificationRoutes)

io.on("connection", (socket) => {
    console.log("A user connected", socket.id);

    socket.on("joinConversation", (conversationId) => {
        socket.join(conversationId);
        console.log("User joined conversation: " + conversationId);
    })

    socket.on("sendMessage", async (message) => {
        const { conversationId, senderId, content } = message;
        console.log("📩 Incoming message:", message);

        try {
            const savedMessage = await saveMessage(conversationId, senderId, content);
            const receiverId = await getReceiverIdFromConversation(conversationId, senderId);


            const senderInfo = await getUserById(senderId);

            if (receiverId && senderInfo) {
                const tokens = await getUserFcmToken(receiverId);
                const senderName = senderInfo.username || "New message";
                const profileImage = senderInfo.profile_image || "";

                for (const token of tokens) {
                    await sendPushNotification(
                        token,
                        senderName,
                        content,
                        conversationId,
                        senderName,
                        profileImage
                    );
                }
            }

            io.to(conversationId).emit("newMessage", savedMessage);
            io.emit("conversationUpdated", {
                conversationId,
                lastMessage: savedMessage.content,
                lastMessageTime: savedMessage.created_at,
            });
        } catch (err) {
            console.error("❌ Failed to handle sendMessage:", err);
        }
    });

    socket.on("disconnect", () => {
        console.log("User dissconnected: ", socket.id);

    })
})


server.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});