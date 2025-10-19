# Hướng dẫn Test Tất Cả Chức Năng Qua API Gateway

## 1. Giới thiệu

File này hướng dẫn cách kiểm thử tất cả các chức năng của hệ thống microservices (Auth, Product, Order) thông qua API Gateway bằng Postman hoặc curl.

---

## 2. Cấu trúc các service & endpoint

### 2.1. API Gateway

- Base URL: `http://localhost:3003/`

### 2.2. Auth service (qua Gateway)

- Đăng ký:  
  `POST http://localhost:3003/auth/register`
- Đăng nhập:  
  `POST http://localhost:3003/auth/login`
- Dashboard (test bảo vệ bằng JWT):  
  `GET http://localhost:3003/auth/dashboard`  
  (Yêu cầu header Authorization)

### 2.3. Product service (qua Gateway)

- Tạo sản phẩm:  

  (Yêu cầu header Authorization)
- Lấy danh sách sản phẩm:  
   
  (Yêu cầu header Authorization)
- Mua sản phẩm (tạo order):  
  
  (Yêu cầu header Authorization)

### 2.4. Order service (qua Gateway)

- (Tùy code order service, thông thường:  
  `GET http://localhost:3003/orders/`  
  `POST http://localhost:3003/orders/`  
  ...)

---

## 3. Quy trình test tất cả chức năng

### Bước 1. Đăng ký tài khoản

- **Method:** POST  
- **URL:** `http://localhost:3003/auth/register`
- **Body:** (JSON)
    ```json
    {
      "username": "hienhien",
      "password": "123456"
    }
    ```
- **Kết quả:** Nhận thông báo đăng ký thành công.
![alt text](image.png)
---

### Bước 2. Đăng nhập lấy JWT token

- **Method:** POST  
- **URL:** `http://localhost:3003/auth/login`
- **Body:** (JSON)
    ```json
    {
      "username": "hien",
      "password": "123456"
    }
    ```
- **Kết quả:** Nhận JWT token, ví dụ:
    ```json
    {
      "token": "<YOUR_JWT_TOKEN>"
    }
    ```

![alt text](image-1.png)

### Bước 3. Truy cập Dashboard (kiểm tra xác thực)

- **Method:** GET  
- **URL:** `http://localhost:3003/auth/dashboard`
- **Header:**  
    ```
    Authorization: Bearer <YOUR_JWT_TOKEN>
    ```
- **Kết quả:** Nhận thông báo chào mừng (nếu token hợp lệ).

---

### Bước 4. Tạo sản phẩm mới

- **Method:** POST  
- **URL:** `http://localhost:3003/products/api/products`
- **Header:**  
    ```
    Authorization: Bearer <YOUR_JWT_TOKEN>
    ```
- **Body:** (ví dụ)
    ```json
    {
      "name": "Áo thun baba",
      "price": 120000,
      "description": "Áo thun cotton thoáng mát, phù hợp đi học, đi chơi."
    }
    ```
- **Kết quả:** Nhận sản phẩm vừa tạo.
Post main
![alt text](image-3.png)
---
mogo
![alt text](image-4.png)

### Bước 5. Lấy danh sách sản phẩm

- **Method:** GET  
- **URL:** `http://localhost:3003/products/api/products`
- **Header:**  
    ```
    Authorization: Bearer <YOUR_JWT_TOKEN>
    ```
- **Kết quả:** Nhận danh sách sản phẩm.
![alt text](image-2.png)
---

### Bước 6. Mua sản phẩm (tạo order)

- **Method:** POST  
- **URL:** `http://localhost:3003/products/api/products/buy`
- **Header:**  
    ```
    Authorization: Bearer <YOUR_JWT_TOKEN>
    ```
- **Body:** (ví dụ)
    ```json
    {
     
  "ids": ["<ID_CUA_SAN_PHAM>"]

    }
    ```
- **Kết quả:** Nhận thông tin đơn hàng vừa tạo.
Trước tiền cài đặt RabbitMQ và đăng nhập thành công 
![alt text](image-5.png)
---

### Bước 7. Kiểm tra chức năng order (nếu có)

- **Lấy danh sách đơn hàng:**  
    - GET `http://localhost:3003/orders/`
    - Header:  
        ```
        Authorization: Bearer <YOUR_JWT_TOKEN>
        ```
    - Kết quả: Trả về danh sách đơn hàng của user.

- **Tạo đơn hàng trực tiếp (nếu service có API này):**  
    - POST `http://localhost:3003/orders/`
    - Header + body tương tự như trên.

---


## 4. Lưu ý

- Tất cả các API cần xác thực đều phải gửi header:
    ```
    Authorization: Bearer <YOUR_JWT_TOKEN>
    ```
- Nếu gặp lỗi 401 Unauthorized, hãy chắc chắn token hợp lệ và đúng header.
- Nếu gặp lỗi không kết nối, kiểm tra service đang chạy đúng port, đúng host.
- Bạn có thể dùng Postman hoặc curl để test.

---

## 5. Tham khảo curl mẫu

```sh
# Đăng nhập
curl -X POST http://localhost:3003/auth/login -H "Content-Type: application/json" -d '{"username":"hien","password":"123456"}'

# Lấy sản phẩm (thay <TOKEN>)
curl http://localhost:3003/products/ -H "Authorization: Bearer <TOKEN>"
```

---


