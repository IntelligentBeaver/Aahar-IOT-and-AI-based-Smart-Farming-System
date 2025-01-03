const asyncHandler=(fn)=>{
    return async(req,res,next)=>{
        try {
          await fn(req,res,next)
        } catch (error) {
            console.log("there is error in asynchandler",error)
            next(error);  // Forward the error to the error-handling middleware
        }
    }
    }
    export default asyncHandler;