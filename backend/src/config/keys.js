export default {
    app: {
        name: "Aahar",
    },

    port: process.env.PORT || 5000,

    NODE_ENV: process.env.NODE_ENV,

    database: {
        url: process.env.MONGODB_URL,
        name: process.env.DB_NAME,
    }
}