# DoAnDaNganhCNPM_252
# Hướng dẫn chạy dự án
## 1. Tải thư viện
```bash
pip install adafruit-io python-dotenv flask flask-sqlalchemy
```
## 2. Cấu hình môi trường
Tạo file .env trong thư mục gốc gồm:
```bash
ADA_USERNAME=<Your Adafruit username>
ADA_KEY=<Your Adafruit key>
```
## 3. Chạy dự án
```bash
python app.py
```
Lưu ý: Code có 1 API test gửi dữ liệu đến Adafruit sử dụng feed tên 'led', nên tài khoản Adafruit liên kết đến cần 1 feed tên 'led'
