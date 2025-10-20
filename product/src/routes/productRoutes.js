const express = require("express");
const ProductController = require("../controllers/productController");
const isAuthenticated = require("../utils/isAuthenticated");

console.log("[routes] productRoutes loaded");

const router = express.Router();
const controller = new ProductController();

// POST create product
router.post("/", isAuthenticated, controller.createProduct);

// POST create order
router.post("/buy", isAuthenticated, controller.createOrder);

// GET all products
router.get("/", isAuthenticated, controller.getProducts);

// GET order by ID (path param) - use orderId name for clarity
router.get("/order/:id", isAuthenticated, controller.getOrderById);

// GET product by ID
router.get("/:id", isAuthenticated, controller.getProductById);

module.exports = router;
