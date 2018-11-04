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
            ["250201", "Andrade"],
            ["535501", "Brownsville: B&M Bridge"],
            ["535504", "Brownsville: Gateway Bridge"],
            ["535503", "Brownsville: Los Indios"],
            ["535502", "Brownsville: Veterans International Bridge"],
            ["250301", "Calexico: East"],
            ["250302", "Calexico: West"],
            ["240601", "Columbus"],
            ["230201", "Del Rio"],
            ["260101", "Douglas (Raul Hector Castro)"],
            ["230301", "Eagle Pass (Bridge I)"],
            ["230302", "Eagle Pass (Bridge II)"],
            ["240201", "El Paso: Bridge of the Americas"],
            ["240202", "El Paso: Paso Del Norte"],
            ["240204", "El Paso: Stanton DCL"],
            ["240203", "El Paso: Ysleta"],
            ["240401", "Fabens: Tornillo"],
            ["l24501", "Fort Hancock"],
            ["230503", "Hidalgo/Pharr: Andaluzas Bridge"],
            ["230501", "Hidalgo/Pharr: Hidalgo"],
            ["230502", "Hidalgo/Pharr: Pharr"],
            ["230401", "Laredo: Bridge I"],
            ["230402", "Laredo: Bridge II"],
            ["230403", "Laredo: Colombia Solidarity"],
            ["230404", "Laredo: World Trade Bridge"],
            ["260201", "Lukeville"],
            ["260301", "Naco"],
            ["260402", "Nogales: Mariposa"],
            ["260403", "Nogales: Morley Gate"],
            ["250601", "Otay Mesa"],
            ["240301", "Presidio"],
            ["230902", "Progreso: Donna International Bridge"],
            ["230901", "Progreso"],
            ["230701", "Rio Grande City"],
            ["231001", "Roma"],
            ["260801", "San Luis"],
            ["240801", "Santa Teresa"],
            ["250401", "San Ysidro"],
            ["250501", "Tecate"]
        ]

        titles = {
            "250201": "Andrade",
            "535501": "Brownsville: B&M Bridge",
            "535504": "Brownsville: Gateway Bridge",
            "535503": "Brownsville: Los Indios",
            "535502": "Brownsville: Veterans International Bridge",
            "250301": "Calexico: East",
            "250302": "Calexico: West",
            "240601": "Columbus",
            "230201": "Del Rio",
            "260101": "Douglas (Raul Hector Castro)",
            "230301": "Eagle Pass (Bridge I)",
            "230302": "Eagle Pass (Bridge II)",
            "240201": "El Paso: Bridge of the Americas",
            "240202": "El Paso: Paso Del Norte",
            "240204": "El Paso: Stanton DCL",
            "240203": "El Paso: Ysleta",
            "240401": "Fabens: Tornillo",
            "l24501": "Fort Hancock",
            "230503": "Hidalgo/Pharr: Andaluzas Bridge",
            "230501": "Hidalgo/Pharr: Hidalgo",
            "230502": "Hidalgo/Pharr: Pharr",
            "230401": "Laredo: Bridge I",
            "230402": "Laredo: Bridge II",
            "230403": "Laredo: Colombia Solidarity",
            "230404": "Laredo: World Trade Bridge",
            "260201": "Lukeville",
            "260301": "Naco",
            "260402": "Nogales: Mariposa",
            "260403": "Nogales: Morley Gate",
            "250601": "Otay Mesa",
            "240301": "Presidio",
            "230902": "Progreso: Donna International Bridge",
            "230901": "Progreso",
            "230701": "Rio Grande City",
            "231001": "Roma",
            "260801": "San Luis",
            "240801": "Santa Teresa",
            "250401": "San Ysidro",
            "250501": "Tecate"
        }
    
        var result = await web.get('https://apps.cbp.gov/bwt/bwt.xml');
        const data = result.content;
        //console.log(data.content);
        for(var index=0; index<identifiers.length; index++) {
            var section = data.split(identifiers[index][0])[1];
            var section1 = section.split("<passenger_vehicle_lanes>")[1];
            var section2 = section1.split("<standard_lanes>")[1];
            var section3 = section2.split("<delay_minutes>")[1];
            var section4 = section3.split("</delay_minutes>")[0];
            //console.log("The delay time at " + identifiers[index] + " is " + section4);
            // Grab the text parameter.
            const original = req.query.text;
            // Push the new message into the Realtime Database using the Firebase Admin SDK.
            //admin.database().ref('/DelayData').removeValue();
            //admin.database().ref('/DelayData').push(identifiers[index]);
            //admin.database().ref('/DelayData').ref("/" + identifieres[index]).push(section4);
            ref.child("/"+identifiers[index][0]).set({section4})

            }

        jsonData = await web.get("https://border-guide.firebaseio.com/UserSettings.json?print=pretty");
        jsonCrossings = await web.get("https://border-guide.firebaseio.com/crossingData.json?print=pretty")
        userData = JSON.parse(jsonData.content);
        crossingData = JSON.parse(jsonCrossings.content); 
        for (user in userData) {
            userInfo = userData[user];
            if ("Borders" in userInfo) {
                console.log("SUCCESS")
                borders = userInfo["Borders"];
                for (border in borders) {
                    crossingNumValue = parseInt(crossingData[border]["section4"], 10);
                    if (crossingNumValue <= borders[border]["Time"]) {
                        admin.database().ref("UserSettings").child(user).child("Borders").child(border).remove();
                        messageText = "The current delay time at " + titles[border] + " is " + crossingNumValue + " minutes"
                        message = {
                            "notification": {
                                "title": "Border Crossing Update",
                                "body": messageText

                            },
                            "token": userData[user]["Token"]
                        };
                        admin.messaging().send(message);
                    }
                }
            }
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

/*exports.checkDatabase = functions.https.onRequest(async (req, res) => {
    jsonData = await web.get("https://border-guide.firebaseio.com/UserSettings.json?print=pretty");
    userData = jsonData.content;
    for (user in userData) {
        userInfo = userData[user];
        if ('Borders' in userInfo) {
            borders = userInfo["Borders"];
            for (border in borders) {
                numValue = parseInt(ref[border], 10);
                if (numValue <= borders[border][time]) {
                    console.log("success")
                };
            };
        };
    };
    
});
*/