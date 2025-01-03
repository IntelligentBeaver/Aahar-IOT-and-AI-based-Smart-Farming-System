import mongoose from "mongoose";

const farmSchema = new mongoose.Schema(
  {
    owner: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    farmingType: {
      type: String,
      enum: ["Organic", "Conventional", "Hydroponic", "Mixed", "Other"],
    },
    crops: [
      {
        cropName: { type: String },
        plantingDate: { type: Date },
        harvestingDate: { type: String },
        quantity: { type: String },
        amount: { type: String },
      },
    ],
    processes: [
      {
        processName: {
          type: String,
          enum: ["Seeds", "Irrigation", "Fertilizers", "Pesticides"],
        },
        date: { type: Date },
        quantity: { type: String },
        electricity: { type: String },
        rate: { type: String },
        description: { type: String }, // Optional details
      },
    ],
    investments: [
      {
        category: {
          type: String,
          enum: [
            "Seeds",
            "Fertilizers",
            "Pesticides",
            "Irrigation",
            "Labor",
            "Equipment",
            "Other",
          ],
        },
        amount: { type: Number, required: true },
        date: { type: Date, required: true },
        description: { type: String },
      },
    ],
    income: [
      {
        source: {
          type: String,
          enum: [
            "Direct Crop Sale",
            "Wholesale Sale",
            "Export Income",
            "Contract Farming",
            "Seed Sale",
            "Other",
          ],
        },
        amount: { type: Number, required: true },
        date: { type: Date, required: true },
      },
    ],
  },
  {
    timestamps: true,
  }
);

export default mongoose.model("Farm", farmSchema);
