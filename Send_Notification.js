const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendPushNotification = functions.https.onCall(async (data, context) => {
  const userId = data.userId;
  const message = data.message;
  const title = data.title;

  // Get the FCM token of the specific user
  const userDoc = await admin.firestore().collection('tokens').doc(userId).get();
  const token = userDoc.data()?.fcmToken;

  if (token) {
    const payload = {
      notification: {
        title: title,
        body: message,
      },
      token: token,
    };

    try {
      // Send notification to the specific user's device
      await admin.messaging().send(payload);
      return { success: true };
    } catch (error) {
      console.error("Error sending message:", error);
      return { success: false, error: error.message };
    }
  } else {
    return { success: false, error: "FCM token not found" };
  }
});
