import mongoose from "mongoose";
import config  from "./keys.js"

const connectDb = async () => {
    console.log("connecting to db "+ config.database.name + " at url" + config.database.url)
try {
    const connect= await mongoose.connect(`${config.database.url}/${config.database.name}`)
    console.log("database connected succesfully")
    }
    catch (error) {
        console.log("error in connecting to db",error.message)
        // process.exit()
    }
} 

export default connectDb


