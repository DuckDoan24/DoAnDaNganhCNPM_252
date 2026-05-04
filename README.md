# DoAnDaNganhCNPM_252
# Hướng dẫn chạy dự án

## Backend
### 1. Tải thư viện
```bash
pip install -r requirement.txt
```
### 2. Cấu hình môi trường
Tạo file .env trong thư mục /Code gồm:
```bash
ADA_USERNAME=<Your Adafruit username>
ADA_KEY=<Your Adafruit key>
JWT_SECRET_KEY=<Random string>
DB_NAME=<Your DB Name>
DB_USER=<Your DB Username>
DB_PASSWORD=<Your DB Password>
```
### 3. Chạy dự án
```bash
cd Code
python app.py
```
API document: /localhost/apidocs
Lưu ý: Code có 1 API test gửi dữ liệu đến Adafruit sử dụng feed tên 'led', nên tài khoản Adafruit liên kết đến cần 1 feed tên 'led'

## Frontend
### 1. Setup
1. Tải bản stable [Flutter SDK](https://docs.flutter.dev/get-started/install) hoặc [hướng dẫn](https://docs.flutter.dev/tools/vs-code).
2. Nếu tải bản stable, giải nén và thêm vào `flutter/bin` folder ở `PATH` tại environment variable.
3. Gõ terminal:
   ```bash
   flutter config --enable-web
   ```

4. Set up lấy các package mới nhất
   ```bash
   cd frontend
   flutter pub get
   ```

### 2. Chạy debug
```bash
cd frontend
flutter run -d chrome
```
### 3. Chạy build
```bash
cd frontend
flutter build web
```

   Có 2 cách để chạy web:
   - Cách 1:
   ```bash
   cd build/web
   python -m http.server 8000
   ```

   - Cách 2:
   ```bash
   npm install -g serve
   npx serve build/web
   ```
