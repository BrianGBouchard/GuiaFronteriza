const functions = require('firebase-functions');
const admin = require('firebase-admin');
const secureCompare = require('secure-compare');
const web = require('web-request');
admin.initializeApp();

exports.getData = functions.https.onRequest(async (req, res) => {

    const key = req.query.key;

    var db = admin.database();
    var ref = db.ref("crossingData");

    if (!secureCompare(key, functions.config().cron.key)) {
        console.log('The key provided in the request does not match the key set in the environment. Check that', key,
            'matches the cron.key attribute in `firebase env:get`');
        res.status(403).send('Security key does not match. Make sure your "key" URL query parameter matches the ' +
            'cron.key environment variable.');
        return null;
      }

    //(async function () {

        const identifiers = [
            "250201",
            "535501",
            "535504",
            "535503",
            "535502",
            "250301",
            "250302",
            "240601",
            "230201",
            "260101",
            "230301",
            "230302",
            "240201",
            "240202",
            "240204",
            "240203",
            "240401",
            "l24501",
            "230503",
            "230501",
            "230502",
            "230401",
            "230402",
            "230403",
            "230404",
            "260201",
            "260301",
            "260402",
            "260403",
            "250601",
            "240301",
            "230902",
            "230901",
            "230701",
            "231001",
            "260801",
            "240801",
            "250401",
            "250501"]
    
        var result = await web.get('https://apps.cbp.gov/bwt/bwt.xml');
        const data = result.content;
        console.log(data.content);
        for(var index=0; index<identifiers.length; index++) {
            var section = data.split(identifiers[index])[1];
            var section1 = section.split("<passenger_vehicle_lanes>")[1];
            var section2 = section1.split("<standard_lanes>")[1];
            var section3 = section2.split("<delay_minutes>")[1];
            var section4 = section3.split("</delay_minutes>")[0];
            console.log("The delay time at " + identifiers[index] + " is " + section4);
            // Grab the text parameter.
            const original = req.query.text;
            // Push the new message into the Realtime Database using the Firebase Admin SDK.
            //admin.database().ref('/DelayData').removeValue();
            //admin.database().ref('/DelayData').push(identifiers[index]);
            //admin.database().ref('/DelayData').ref("/" + identifieres[index]).push(section4);
            ref.child("/"+identifiers[index]).set({section4})

            }
        return res.status(200).send('Hello');
    //})(); 
  });

  



// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

/*exports.add = functions.https.onRequest((req, res) => {
    // Grab the text parameter.
    const original = req.query.text;
    // Push the new message into the Realtime Database using the Firebase Admin SDK.
    return admin.database().ref('/messages').push({original: original}).then((snapshot) => {
      // Redirect with 303 SEE OTHER to the URL of the pushed object in the Firebase console.
      return res.status(200).send("success");
    });
  });*/