const express = require("express");
const admin = require("firebase-admin");
const bodyParser = require("body-parser");
const axios = require("axios"); // Importing Axios for HTTP requests

const serviceAccount = require("./accessToken.json");

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: "https://capstone-bau-2025-default-rtdb.europe-west1.firebasedatabase.app"
});

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(bodyParser.json());

// Route to manually update gas level (optional)
app.post("/updateGasLevel", async (req, res) => {
    const gasLevel = req.body.gasLevel;
    console.log("🔔 Gas level updated manually:", gasLevel);

    try {
        await admin.database().ref("/SmartHome/monitoring/gasLevel").set(gasLevel);
        res.status(200).send({ message: "Gas level updated successfully" });
    } catch (error) {
        console.error("❌ Error updating gas level:", error);
        res.status(500).send({ error: "Error updating gas level" });
    }
});

// Realtime listener for gas level updates
admin.database().ref("/SmartHome/monitoring/gasLevel").on("value", async (snapshot) => {
    const gasLevel = snapshot.val();
    console.log("🔔 Firebase gas level updated:", gasLevel);

    if (gasLevel >= 1000) {
        const message = {
            notification: {
                title: "Gas Alert",
                body: `Gas level has exceeded safe limits: ${gasLevel} PPM`,
            },
            topic: "gasAlert",
            android: {
                priority: "high",
                notification: {
                    sound: "default",
                    channel_id: "high_importance_channel",
                },
            },
            apns: {
                payload: {
                    aps: {
                        alert: {
                            title: "Gas Alert",
                            body: `Gas level has exceeded safe limits: ${gasLevel} PPM`,
                        },
                        sound: "default",
                    },
                },
            },
            data: {
                click_action: "FLUTTER_NOTIFICATION_CLICK",
                gas_level: gasLevel.toString(),
            },
        };

        try {
            const response = await admin.messaging().send(message);
            console.log("✅ Notification sent successfully:", response);
        } catch (error) {
            console.error("❌ Error sending notification:", error);
        }
    } else {
        console.log("✅ Gas level within safe limits:", gasLevel);
    }
});

// Keep-Alive Endpoint (to ensure Render doesn't spin down)
app.get("/", (req, res) => {
    res.send("Keep-Alive Endpoint: Service is active!");
});

// Keep-Alive Request (every 4 minutes)
setInterval(() => {
    axios.get(`https://webservice-s7ta.onrender.com/`)
        .then(() => console.log("💓 Keep-alive ping sent to server"))
        .catch((err) => console.error("❌ Keep-alive ping failed:", err.message));
}, 210000); // 4 minutes (240,000 ms)

// Start the server
app.listen(PORT, () => {
    console.log(`🚀 Server running on port ${PORT}`);
});
