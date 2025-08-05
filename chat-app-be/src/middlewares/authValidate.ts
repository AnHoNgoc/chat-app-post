import { Request, Response, NextFunction } from "express";
import { Schema } from "joi";

export const validateAuth = (schema: Schema) =>  {
    return (req: Request, res: Response, next: NextFunction) => {
        const { error } = schema.validate(req.body, { abortEarly: false });
        if (error) {
            const messages = error.details.map((err) => err.message);
            res.status(400).json({
                EM: messages.join(". "),
                EC: 1,
                DT: "",
            });
            return;
        }
        next();
    };
};
