const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.notifyOnEvent = functions.firestore
  .document('events/{eventId}')
  .onCreate(async (snap, context) => {
    const eventData = snap.data();
    const payload = {
      notification: {
        title: 'New Event!',
        body: `Event "${eventData.name}" is live.`,
      },
      topic: 'your_event_topic',
    };
    await admin.messaging().send(payload);
  });