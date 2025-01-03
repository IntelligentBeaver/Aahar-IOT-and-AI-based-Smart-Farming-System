import mongoose from "mongoose";

const diseaseSchema = new mongoose.Schema(
  {
    farm: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Farm",
      required: true,
    }, // Reference to the farm where the disease was detected
    cropName: {
      type: String,
      required: true,
    }, // Crop associated with the disease
    imageUrl: {
      type: String,
      required: true,
    }, // URL of the uploaded image
    detectedDisease: {
      type: String,
      required: true,
    }, // AI-detected disease name
    confidence: {
      type: Number,
      required: true,
    }, // Confidence score from the AI model
    description: {
      type: String,
    }, // Optional: Additional information about the disease
    detectedAt: {
      type: Date,
      default: Date.now,
    }, // Timestamp for detection
  },
  {
    timestamps: true,
  }
);

export default mongoose.model("Disease", diseaseSchema);
