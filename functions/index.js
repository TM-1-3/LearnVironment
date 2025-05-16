const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const { initializeApp } = require('firebase-admin/app');
const { getMessaging } = require('firebase-admin/messaging');

initializeApp();

exports.notifyOnEvent = onDocumentCreated('events/{eventId}', async (event) => {
  const eventData = event.data?.data();

  if (!eventData) return;

  const className = eventData.className;

  if (!className) {
      console.error('No className found in event data.');
      return;
  }

  if (!className || typeof className !== 'string' || className.trim().length < 3) {
    console.error('Invalid or unsafe className:', className);
    return;
  }

  let name = className;

  const sanitizedClassName = name.replace(/[^a-zA-Z0-9-_.~%]/g, '_');

  const payload = {
    notification: {
      title: 'New Event!',
      body: `Event "${eventData.name}" is live.`,
    },
    topic: sanitizedClassName,
  };

  console.log('FCM payload:', payload);

  await getMessaging().send(payload)
    .then((response) => console.log('Successfully sent message:', response))
    .catch((error) => console.error('Error sending message:', error));
});