
const functions = require("firebase-functions");
const firebase = require("firebase-admin");

const firestore = firebase.firestore()

module.exports.notificationsFunction = async function notificationsFunction() {
    const config = await getConfig()

    for await (const { users, option, timezone } of getAllCurentUsers(config)) {
        for (const user of users) {

            if (user.enable_notifications === false) {
                continue
            }

            const snapshot = await firestore.collection("birthdays").where('owner', '==', user.user_id).get()
            const birthdays = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }))

            const authedUser = await firebase.auth().getUser(user.user_id)

            for (const birthday of birthdays) {
                let date = birthday['birth'].toDate()

                const offset = (timezone * 60 * 60 * 1000)

                date = new Date(date.getTime() + offset)
                const today = new Date(Date.now() + offset)

                const day = date.getDate()
                const month = date.getMonth() + 1
                const year = date.getFullYear()

                const todayDay = today.getDate()
                const todayMonth = today.getMonth() + 1

                const future7Days = new Date()
                future7Days.setDate(future7Days.getDate() + 7)
                const future7DaysDay = future7Days.getDate()
                const future7DaysMonth = future7Days.getMonth() + 1

                const isSameDay = todayDay === day && todayMonth === month
                const isSameDay7Days = future7DaysDay === day && future7DaysMonth === month

                if (isSameDay) {
                    functions.logger.info(`Sent notification to "${authedUser.displayName} <${authedUser.email}>. Birthday id: ${birthday.id}, (${birthday.personName})"`, { structuredData: true });
                    sendNotification(birthday, user)
                }

                if (isSameDay7Days) {
                    functions.logger.info(`Sent notification to "${authedUser.displayName} <${authedUser.email}>. Birthday id: ${birthday.id}, (${birthday.personName})"`, { structuredData: true });
                    sendNotification(birthday, user, true)
                }
            }
        }
    }
}

async function sendNotification(birthday, user, isFuture = false) {
    const noYear = !!birthday.noYear
    const year = birthday.birth.toDate().getFullYear()

    const name = birthday.personName

    const turns = new Date().getFullYear() - year

    let title = ''

    if (noYear) {
        title = !isFuture ? `Today is the birthday of ${name}` : `In 7 days is the birthday of ${name}`
    } else {
        title = !isFuture ? `Today ${name} turns ${turns}` : `In 7 days ${name} turns ${turns}`
    }

    if (user.lang === 'es') {
        if (noYear) {
            title = !isFuture ? `Hoy es el cumpleaños de ${name}` : `En 7 días es el cumpleaños de ${name}`
        } else {
            title = !isFuture ? `Hoy ${name} cumple ${turns}` : `En 7 días ${name} cumple ${turns}`
        }
    }

    // Show day and month
    const description = (birthday.notes ? `(${birthday.notes}) ` : '') + birthday.birth.toDate().toLocaleDateString(user.lang, { day: 'numeric', month: 'long' })

    return await firebase.messaging().send({
        "token": user.token,
        "notification": {
            "title": title,
            "body": description,
        },
        "data": {
            "birthday_id": birthday.id,
        }
    })
}


async function getConfig() {
    const template = await firebase.remoteConfig().getTemplate()

    /** @type {string[]} */
    const updateTimes = JSON.parse(template.parameters['daily_update_time'].defaultValue.value)
    /** @type {string} */
    const defaultTime = template.parameters['default_daily_update_time'].defaultValue.value

    return {
        updateTimes,
        defaultTime,
    }
}

/** 
 * @param {string} option
 * @param {number} config
 * @param {ReturnType<typeof getConfig>} config
 *  */
async function getUsers(option, timezone, config) {
    const registrations = (await firestore.collection("fcm_tokens").where('daily_update_time', '==', option).where('timezone', '==', timezone).get()).docs.map(doc => ({
        token: doc.id,
        ...doc.data()
    }))

    if (option === config.defaultTime) {
        registrations.push(...(await firestore.collection("fcm_tokens").where('timezone', '==', timezone).get()).docs.map(doc => ({
            token: doc.id,
            ...doc.data()
        })))
    }

    /** @type {{ token: string, lang: string, platform: string, timezone: number, daily_update_time: string | undefined, enable_notifications: boolean, updated_at: any, user_id: string }[]} */
    const users = registrations

    return users
}

/** @param {ReturnType<typeof getConfig>} config */
async function getCurrentOption(config) {
    const utc0 = new Date()
    const hours = utc0.getHours()
    const minutes = utc0.getMinutes()
    const seconds = utc0.getSeconds()

    let currentTimeOption = {
        hour: hours,
        minute: minutes,
        second: seconds,
    }

    for (const configTime of config.updateTimes) {
        const [configHour, configMinute, configSecond] = configTime.split(':').map(Number)

        if (hours > configHour || (hours === configHour && minutes > configMinute) || (hours === configHour && minutes === configMinute && seconds >= configSecond)) {
            currentTimeOption = {
                hour: configHour,
                minute: configMinute,
                second: configSecond,
            }
        }
    }

    return currentTimeOption
}


async function* getAllCurentUsers(config) {
    const timezoneOptionCombinations = await getCurrentOptionTimezoneCombinations(config)

    /** @type {{ option: string, timezone: number, users: { token: string, lang: string, platform: string, timezone: number, daily_update_time: string | undefined, enable_notifications: boolean, updated_at: any, user_id: string }[] }[]} */
    const usersByOption = []

    for (const timezoneOptionCombination of timezoneOptionCombinations) {
        const users = await getUsers(timezoneOptionCombination.option, timezoneOptionCombination.timezone, config)

        yield {
            ...timezoneOptionCombination,
            users,
        }
    }

    return usersByOption
}

/** @param {ReturnType<typeof getConfig>} config */
async function getCurrentOptionTimezoneCombinations(config) {
    const currentOption = await getCurrentOption(config)


    /** @type {{ option: string, timezone: number }[]} */
    const timezoneOptionCombinations = []

    for (let timezone = -12; timezone <= 14; timezone++) {
        timezoneOptionCombinations.push({
            option: formatLabel({
                hour: (currentOption.hour + timezone + 24) % 24,
                minute: currentOption.minute,
                second: currentOption.second,
            }),
            timezone,
        })
    }

    return timezoneOptionCombinations
}

/** @type {{ hour: number, minute: number, second: number }} */
function formatLabel(option) {
    let hourStr = option.hour.toString()
    let minuteStr = option.minute.toString()
    let secondStr = option.second.toString()

    if (hourStr.length === 1) {
        hourStr = '0' + hourStr
    }

    if (minuteStr.length === 1) {
        minuteStr = '0' + minuteStr
    }

    if (secondStr.length === 1) {
        secondStr = '0' + secondStr
    }

    if (secondStr === '00') {
        return `${hourStr}:${minuteStr}`
    }

    return `${hourStr}:${minuteStr}:${secondStr}`
}