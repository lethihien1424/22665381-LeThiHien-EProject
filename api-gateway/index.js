// const express = require("express");
// const httpProxy = require("http-proxy");

// const proxy = httpProxy.createProxyServer();
// const app = express();

// // Route requests to the auth service
// app.use("/auth", (req, res) => {
//   proxy.web(req, res, { target: "http://auth:3000" });
// });

// // Route requests to the product service
// app.use("/products", (req, res) => {
//   proxy.web(req, res, { target: "http://product:3001" });
// });

// // Route requests to the order service
// app.use("/orders", (req, res) => {
//   proxy.web(req, res, { target: "http://order:3002" });
// });

// // Health check endpoint
// app.get("/health", (req, res) => {
//   res.status(200).json({ status: "ok" });
// });

// // Start the server
// const port = process.env.PORT || 3003;
// app.listen(port, () => {
//   console.log(`API Gateway listening on port ${port}`);
// });
// Kiểm tra Product service
// index.js - API Gateway

const express = require("express");
const httpProxy = require("http-proxy");
const axios = require("axios");
const amqplib = require("amqplib");

const app = express();
const proxy = httpProxy.createProxyServer();

// ------------------- Proxy Routes -------------------
app.use("/auth", (req, res) =>
  proxy.web(req, res, { target: "http://auth:3000" })
);

app.use("/products", (req, res) =>
  proxy.web(req, res, { target: "http://product:3001" })
);

app.use("/orders", (req, res) =>
  proxy.web(req, res, { target: "http://order:3002" })
);

// ------------------- Healthcheck -------------------
app.get("/health", (req, res) => res.status(200).json({ status: "ok" }));

// ------------------- Retry Helper -------------------
const waitForService = async (checkFn, retries = 10, delay = 5000) => {
  for (let i = 0; i < retries; i++) {
    try {
      await checkFn();
      return;
    } catch (err) {
      console.log(`Service not ready, retrying in ${delay / 1000}s...`);
      await new Promise((res) => setTimeout(res, delay));
    }
  }
  throw new Error("Service failed to start after retries");
};

// ------------------- Service Check Functions -------------------
const checkRabbitMQ = async () => {
  const conn = await amqplib.connect("amqp://guest:guest@rabbitmq:5672");
  await conn.close();
};

const checkAuth = async () => {
  await axios.get("http://auth:3000/health");
};

const checkProduct = async () => {
  await axios.get("http://product:3001/health");
};

const checkOrder = async () => {
  await axios.get("http://order:3002/health");
};

// ------------------- Start Server -------------------
(async () => {
  console.log("Waiting for RabbitMQ...");
  await waitForService(checkRabbitMQ);
  console.log("RabbitMQ ready ✅");

  console.log("Waiting for Auth service...");
  await waitForService(checkAuth);
  console.log("Auth service ready ✅");

  console.log("Waiting for Product service...");
  await waitForService(checkProduct);
  console.log("Product service ready ✅");

  console.log("Waiting for Order service...");
  await waitForService(checkOrder);
  console.log("Order service ready ✅");

  const port = process.env.PORT || 3003;
  app.listen(port, () => {
    console.log(`API Gateway listening on port ${port}`);
  });
})();
