const Product = require("../models/product");
const Order = require("../models/order");
const messageBroker = require("../utils/messageBroker");
const uuid = require("uuid");

class ProductController {
  constructor() {
    this.createOrder = this.createOrder.bind(this);
    this.getOrderById = this.getOrderById.bind(this);
  }

  // CREATE PRODUCT
  async createProduct(req, res) {
    try {
      const token = req.headers.authorization;
      if (!token) return res.status(401).json({ message: "Unauthorized" });

      const product = new Product(req.body);
      const validationError = product.validateSync();
      if (validationError)
        return res.status(400).json({ message: validationError.message });

      await product.save();
      res.status(201).json(product);
    } catch (err) {
      console.error(err);
      res.status(500).json({ message: "Server error" });
    }
  }

  // GET ALL PRODUCTS
  async getProducts(req, res) {
    try {
      const token = req.headers.authorization;
      if (!token) return res.status(401).json({ message: "Unauthorized" });

      const products = await Product.find();
      res.status(200).json(products);
    } catch (err) {
      console.error(err);
      res.status(500).json({ message: "Server error" });
    }
  }

  // GET PRODUCT BY ID
  async getProductById(req, res) {
    try {
      const token = req.headers.authorization;
      if (!token) return res.status(401).json({ message: "Unauthorized" });

      const { id } = req.params;
      const product = await Product.findById(id);
      if (!product)
        return res.status(404).json({ message: "Product not found" });

      res.status(200).json(product);
    } catch (err) {
      console.error(err);
      if (err.name === "CastError")
        return res.status(400).json({ message: "Invalid product ID" });
      res.status(500).json({ message: "Server error" });
    }
  }

  // CREATE ORDER
  async createOrder(req, res) {
    try {
      const token = req.headers.authorization;
      if (!token) return res.status(401).json({ message: "Unauthorized" });

      const { ids } = req.body; // array of product IDs
      const products = await Product.find({ _id: { $in: ids } });
      if (products.length === 0)
        return res.status(400).json({ message: "No products found" });

      const totalPrice = products.reduce((sum, p) => sum + p.price, 0);
      const username = req.user?.username || req.user?.id || "unknown";

      // Thêm trường orderId là UUID
      const order = new Order({
        orderId: uuid.v4(),
        products: products.map((p) => p._id),
        username,
        status: "completed",
        totalPrice,
      });

      await order.save();

      // Publish message to broker (if cần)
      await messageBroker.publishMessage("orders", {
        orderId: order.orderId,
        products,
        username,
        status: order.status,
        totalPrice,
      });

      res.status(201).json(order);
    } catch (err) {
      console.error("[createOrder error]", err);
      res.status(500).json({ message: "Server error", error: err.message });
    }
  }

  // GET ORDER BY ID (support both query id and params id)
  async getOrderById(req, res) {
    try {
      const token = req.headers.authorization;
      if (!token) return res.status(401).json({ message: "Unauthorized" });

      // Lấy id từ query hoặc từ params
      const id = req.query.id || req.params.id;
      if (!id) return res.status(400).json({ message: "Order id is required" });

      // Tìm theo Mongo ObjectId trước
      let order = null;
      try {
        order = await Order.findById(id).populate("products");
      } catch (err) {
        // Nếu lỗi CastError, thử tìm theo trường orderId (UUID)
        if (err.name !== "CastError") console.error(err);
      }

      // Nếu không tìm thấy, thử tìm theo orderId (UUID)
      if (!order) {
        order = await Order.findOne({ orderId: id }).populate("products");
      }

      if (!order) return res.status(404).json({ message: "Order not found" });

      res.status(200).json(order);
    } catch (err) {
      console.error(err);
      res.status(500).json({ message: "Server error" });
    }
  }
}
exports.getProductById = async (req, res) => {
  try {
    const product = await Product.findById(req.params.id);
    if (!product) return res.status(404).json({ message: "Product not found" });
    res.json(product);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

module.exports = ProductController;
