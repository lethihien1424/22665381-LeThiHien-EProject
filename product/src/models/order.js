const mongoose = require("mongoose");
const Schema = mongoose.Schema;

const orderSchema = new Schema(
  {
    orderId: { type: String, unique: true, index: true }, // UUID
    products: [{ type: Schema.Types.ObjectId, ref: "Product" }],
    username: { type: String },
    status: { type: String, default: "pending" },
    totalPrice: { type: Number },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Order", orderSchema);
