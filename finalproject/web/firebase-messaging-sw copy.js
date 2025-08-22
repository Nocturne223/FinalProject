importScripts('https://www.gstatic.com/firebasejs/10.11.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.11.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyB_T5wu3iSCCtOoXGJo5RnZIdBuj2pMO_I",
  authDomain: "sims-dev-47238.firebaseapp.com",
  projectId: "sims-dev-47238",
  storageBucket: "sims-dev-47238.firebasestorage.app",
  messagingSenderId: "527882203234",
  appId: "1:527882203234:web:4713e82360e59819a9613b",
  // measurementId: "YOUR_MEASUREMENT_ID" // optional
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage(function(payload) {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  // Customize notification here
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/icons/Icon-192.png'
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
