   // firebase_init.js
   // Import the functions you need from the SDKs you need
   import { initializeApp } from "firebase/app";
   import { getAnalytics } from "firebase/analytics";

   // Your web app's Firebase configuration
   const firebaseConfig = {
     apiKey: "AIzaSyAe1Gj_RaiPtC2fcdcI3-P7v0EnGAWykuk",
     authDomain: "elite-hotel-26752.firebaseapp.com",
     projectId: "elite-hotel-26752",
     storageBucket: "elite-hotel-26752.firebasestorage.app",
     messagingSenderId: "73510414994",
     appId: "1:73510414994:web:5ef7554a68c62b18ce544b",
     measurementId: "G-EBRTERMSCW"
   };

   // Initialize Firebase
   const app = initializeApp(firebaseConfig);
   const analytics = getAnalytics(app);