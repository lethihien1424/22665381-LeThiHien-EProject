const express = require("express");
const ProductController = require("../controllers/productController");
const isAuthenticated = require("../utils/isAuthenticated");

const router = express.Router();
const productController = new ProductController();

router.post("/", isAuthenticated, productController.createProduct);
router.post("/buy", isAuthenticated, productController.createOrder);
router.get("/", isAuthenticated, productController.getProducts);
router.get("/:id", isAuthenticated, productController.getProductById);
router.get("/:id", isAuthenticated, productController.getProductById); //them cai  nay
module.exports = router;
