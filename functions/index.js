const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const { initializeApp } = require('firebase-admin/app');
const { getMessaging } = require('firebase-admin/messaging');

initializeApp();

exports.notifyOnEvent = onDocumentCreated('events/{eventId}', async (event) => {
  const eventData = event.data?.data();

  if (!eventData) return;

  const payload = {
    notification: {
      title: 'New Event!',
      body: `Event "${eventData.name}" is live.`,
    },
    topic: 'your_event_topic',
  };

  await getMessaging().send(payload);
    .then((response) => console.log('Successfully sent message:', response))
    .catch((error) => console.error('Error sending message:', error));
});