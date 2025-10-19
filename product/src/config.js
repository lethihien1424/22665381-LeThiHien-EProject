// require("dotenv").config();

// module.exports = {
//   port: process.env.PORT || 3001,
//   mongoURI: process.env.MONGODB_URI || "mongodb://mongodb:27017/product_db",
//   rabbitMQURI: process.env.RABBITMQ_URL || "amqp://admin:123456@rabbitmq:5672",
//   exchangeName: "products",
//   queueName: "products_queue",
// };
require("dotenv").config();

module.exports = {
  port: process.env.PORT || 3002,
  mongoURI: process.env.MONGODB_URI || "mongodb://mongodb:27017/product_db",
  rabbitMQURI: process.env.RABBITMQ_URL || "amqp://admin:123456@rabbitmq:5672",
  queueName: "products_queue", // product thì là 'products_queue'
};
