// require('dotenv').config();

// module.exports = {
//     mongoURI: process.env.MONGODB_URI || 'mongodb://mongodb:27017/order_db',
//     rabbitMQURI: process.env.RABBITMQ_URL || 'amqp://admin:123456@rabbitmq:5672',
//     rabbitMQQueue: 'orders',
//     port: process.env.PORT || 3002
// };
require("dotenv").config();

module.exports = {
  port: process.env.PORT || 3002,
  mongoURI: process.env.MONGODB_URI || "mongodb://mongodb:27017/order_db",
  rabbitMQURI: process.env.RABBITMQ_URL || "amqp://admin:123456@rabbitmq:5672",
  queueName: "orders", // product thì là 'products_queue'
};
