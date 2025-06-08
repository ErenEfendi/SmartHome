const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.notifyGasLevel = functions.database
    .ref("/SmartHome/monitoring/gasLevel")
    .onUpdate((change, context) => {
      const gasLevel = change.after.val();
      console.log("🔔 Gas level updated:", gasLevel);

      if (gasLevel > 600) {
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

        return admin.messaging().send(message)
            .then((response) => {
              console.log("✅ Notification sent successfully:", response);
              return null;
            })
            .catch((error) => {
              console.error("❌ Error sending notification:", error);
            });
      }

      return null;
    });
