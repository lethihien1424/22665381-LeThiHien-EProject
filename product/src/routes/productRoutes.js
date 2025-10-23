const express = require("express");
const ProductController = require("../controllers/productController");
const isAuthenticated = require("./../utils/isAuthenticated");
const router = express.Router();
const productController = new ProductController();

router.post("/", isAuthenticated, productController.createProduct);
router.post("/buy", isAuthenticated, productController.createOrder);
router.get("/", isAuthenticated, productController.getProducts);
//http://localhost:3003/products/api/products/order/32283860-b1f7-4c90-b24e-008826e5f9a1
router.get(
  "/order/:orderId",
  isAuthenticated,
  productController.getOrderStatus
);
//router.get("/order/:id", isAuthenticated, productController.getOrderById);
router.get("/:id", isAuthenticated, productController.getProductById);
module.exports = router;
