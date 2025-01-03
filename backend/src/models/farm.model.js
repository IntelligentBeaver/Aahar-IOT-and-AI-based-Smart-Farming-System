import mongoose from "mongoose";

const farmSchema = new mongoose.Schema(
  {
    owner: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    }, // References the User model
    farmingType: {
      type: String,
      enum: ["Organic", "Conventional", "Hydroponic", "Mixed", "Other"],
    },
    crops: [
      {
        cropName: { type: String },
        plantingDate: { type: Date },
        harvestingDate: { type: Date },
        estimatedYield: { type: Number }, // in kg
        actualYield: { type: Number }, // in kg
      },
    ],
    processes: [
      {
        processName: {
          type: String,
          enum: [
            "Seeds",
            "Fertilizers",
            "Pesticides",
            "Irrigation",
            "Labor",
            "Equipment",
          ],
        }, // e.g., "Irrigation", "Fertilizer Application"
        date: { type: Date },
        description: { type: String }, // Additional details about the process
        duration: { type: Number, default: 0 }, // Duration in minutes (e.g., irrigation duration)
        quantity: { type: Number }, // Amount used (e.g., fertilizer quantity)
        unit: { type: String }, // Unit of measurement (e.g., "liters", "kg")
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
          ],
        },
        amount: { type: Number, required: true },
        date: { type: Date, required: true },
        description: { type: String }, // Optional details
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
            "other",
          ],
        },

        amount: { type: Number, required: true },
        date: { type: Date, required: true },
      },
    ],
    totalInvestment: { type: Number, default: 0 },
    totalIncome: { type: Number, default: 0 },
    profitOrLoss: {
      type: Number,
      default: function () {
        return this.totalIncome - this.totalInvestment;
      },
    },
  },
  {
    timestamps: true,
  }
);

// Middleware to calculate financial summaries
farmSchema.pre("save", function (next) {
  this.totalInvestment = this.investments.reduce(
    (sum, investment) => sum + investment.amount,
    0
  );
  this.totalIncome = this.income.reduce(
    (sum, income) => sum + income.amount,
    0
  );
  this.profitOrLoss = this.totalIncome - this.totalInvestment;
  next();
});

export default mongoose.model("Farm", farmSchema);
