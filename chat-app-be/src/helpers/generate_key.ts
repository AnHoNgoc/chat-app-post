import crypto from "crypto";

const keyAccess = crypto.randomBytes(32).toString("hex");
const keyRefresh = crypto.randomBytes(32).toString("hex");

console.table({
    AccessTokenKey: keyAccess,
    RefreshTokenKey: keyRefresh
});
