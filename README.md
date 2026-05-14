#  Hệ thống quản lý nhà thông minh YOLO:HOME
</div>
Hệ thống quản lý nhà thông minh YOLO:HOME là một hệ thống IoT kết nối giữa một ứng dụng web/mobile với mạch phần cứng Yolo:Bit, cho phép người dùng theo dõi các chỉ số cảm biến và điều khiển các thiết bị phần cứng từ xa thông qua giao diện web hoặc mobile

## Tính năng chính

### Quản lý Người dùng
- Đăng ký
- Đăng nhập
- Chỉnh sửa hồ sơ

### Theo dõi cảm biến
- Cập nhật các giá trị cảm biến nhiệt độ, độ ẩm, ánh sáng theo thời gian thực
- Cung cấp biểu đồ nhiệt độ theo thời gian

### Điều khiển từ xa
- Bật tắt đèn
- Chỉnh màu sắc đèn
- Điều khiển tốc độ quạt

### Tích hợp trên mạch phàn cứng
- Mở cửa bằng AI nhận diện khuôn mặt
- Mở cửa bằng remote bấm mật mã
- Bật tắt đèn bằng cảm biến chuyển động

## Công nghệ sử dụng
- **Backend**: Flask, Adafruit_IO library (Python)
- **Frontend**: Flutter (Dart)
- **Database**: PostgreSQL
- **Cloud server**: Adafruit.io

## Chạy dự án
### Backend
#### 1. Tải thư viện
```bash
cd Code
pip install -r requirement.txt
```
#### 2. Cấu hình môi trường
Tạo file .env trong thư mục /Code gồm:
```bash
ADA_USERNAME=<Your Adafruit username>
ADA_KEY=<Your Adafruit key>
JWT_SECRET_KEY=<Random string>
DB_NAME=<Your DB Name>
DB_USER=<Your DB Username>
DB_PASSWORD=<Your DB Password>
```
#### 3. Chạy chương trình
```bash
python app.py
```
### Frontend
#### 1. Setup
1. Tải bản stable [Flutter SDK](https://docs.flutter.dev/get-started/install) hoặc [hướng dẫn](https://docs.flutter.dev/tools/vs-code).
2. Nếu tải bản stable, giải nén và thêm vào `flutter/bin` folder ở `PATH` tại environment variable.
3. Gõ terminal:
   ```bash
   flutter config --enable-web
   ```

#### 2. Chạy debug
```bash
cd frontend
flutter run -d chrome
```
#### 3. Chạy giả lập Android
1. Cài đặt Android studio và tạo thiết bị giả lập
2. Gõ terminal
   ```bash
   flutter devices
   flutter run -d <device_id>
   ```

## Tác giả

Dự án được phát triển bởi:
1. Đoàn Minh Đức - 2310767
2. Trần Phương Đỉnh - 2310744
3. Lưu Việt Đức - 2310779
4. Cao Vũ Hoàng Long - 2311888
5. Nguyễn Chí Thanh - 2313079
6. Hà Trọng Sơn - 2312958
---
