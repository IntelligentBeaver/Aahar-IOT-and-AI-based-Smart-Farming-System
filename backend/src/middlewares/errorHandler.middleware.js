const errorHandler = (err, req, res, next) => {
    // If the error is an instance of ApiError, use its properties, otherwise use default values
    const statusCode = err.statusCode || 500;
    const message = err.message || "Internal Server Error";
    const errors = err.errors || [];
console.log("there is error in error handler",err)
    // Send the structured response
    res.status(statusCode).json({
        success: false,
        message: message, 
        errors: errors,   // Additional error details if available
        stack: process.env.NODE_ENV === 'development' ? err.stack : undefined, // Include stack trace in development mode
    });
};

export default errorHandler;
