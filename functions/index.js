process.env.TZ = 'UTC';

const functions = require("firebase-functions");
const firebase = require("firebase-admin");
firebase.initializeApp()
const { notificationsFunction } = require("./notifications");

const firestore = firebase.firestore()

exports.scheduledHourlyNotificationSendingTask = functions.runWith({ timeoutSeconds: 540 }).pubsub.schedule('1 * * * *').onRun(async (context) => {
    await notificationsFunction()
})

exports.manually = functions.runWith({ timeoutSeconds: 540 }).https.onRequest(async (request, response) => {
    functions.logger.info("Manually function triggered", { structuredData: true });

    await notificationsFunction()

    response.send("Done");
});

exports.shareBirthday = functions.https.onCall(async (data, context) => {
    const email = context.auth.token.email

    if (!email) {
        throw new functions.https.HttpsError('invalid-argument', 'The function must be called with ' +
            'one arguments "email" containing the message text to add.');
    }

    const birthdayId = data.birthdayId

    const birthday = (await firestore.collection("birthdays").doc(birthdayId).get()).data()

    if (!birthday || birthday.owner !== context.auth.uid) {
        throw new functions.https.HttpsError('not-found', 'Birthday not found');
    }

    const doc = await firebase.collection('share_birthday').add({
        birthdayId,
        email
    })

    return doc.id
})

