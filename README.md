1. Download source code
2. Run npm install
3. Thêm dữ liệu
Thêm dữ liệu cho file .env của api-gateway, auth, product, order

Thêm dữ liệu cho Dockerfile của api-gateway, auth, product, order

Thêm dữ liệu cho file docker-compose.yml


4. Build docker
![alt text](public/buildDocker.png)
![alt text](public/Docker.png)
5. Test all business logic with POSTMAN
Auth:
register
![alt text](public/dk.png)
login
![alt text](public/login.png)
Chọn Headers->key:x-auth-token->value là giá trị của token có được từ login

Sử dụng GET để có thể thực hiện được cái dashboard

dashboard
![alt text](public/dashboard.png)
product:
POST
![alt text](public/postProducts.png)
GET
![alt text](public/getProducts.png)
-GET PRODUCT BY ID
![alt text](public/getProducts_ID.png)
BUY
![alt text](public/buyID.png)
🔍 Kiểm tra dữ liệu trong MongoDB (Docker) sau khi thực hiện trên POSTMAN
Bạn có thể kiểm tra dữ liệu trong MongoDB container bằng lệnh:


docker exec -it mongodb mongosh
show dbs
auth

use auth_db
show collections
db.users.find().pretty()
![alt text](public/authMogo.png)
product

use product_db
show collections
db.products.find().pretty()
![alt text](public/dockerProduct.png)
order

use order_db
show collections
db.orders.find().pretty()
![alt text](public/DockerOrders.png)
Thao tác với github Action: Thực hiện CI/CD với dự án
![alt text](public/CICD.png)
CICI Thao tác với github Action: Thực hiện CI/CD với dự án
6. CI/CD
Tạo token bên Docker Hub
Copy token vào GitHub
Vào GitHub
Chọn responsitory
Chọn setting -> secrets and variables -> Actions ->
new responsitory secret -> Names(DOCKER_NAME), secret(username đăng nhập bên docker hub)
new responsitory secret -> Names(DOCKER_PASSWORD), secret(token của Docker Hub)
Tạo thư mục .GitHub/workflows
Tạo file docker-cicd.yml
Điền thông tin cho file docker-cicd.yml
Push workflow lên GitHub để chạy CI/CD

git add .github/workflows/docker-cicd.yml
git commit -m "update3"
git push origin main
![alt text](public/gitAction.png)
CICD lien kết  với  docker 
![alt text](public/gitCICD_Docker.png)
![alt text](public/CICDdocker.png)
![alt text](public/cicd_Repositories.png)

kk