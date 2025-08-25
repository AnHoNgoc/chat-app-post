import dotenv from "dotenv";
dotenv.config();
import { Pool } from "pg";

const pool = new Pool({
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    host: process.env.DB_HOST,
    port: Number(process.env.DB_PORT),
    database: process.env.DB_NAME,
    ssl: {
        rejectUnauthorized: false // Render requires this
    }
});

pool.query("SELECT NOW()", (err, res) => {
    if (err) {
        console.error("❌ Database connection failed:", err.stack);
    } else {
        console.log("✅ Database connected. Current time:", res.rows[0].now);
    }
});

export default pool;