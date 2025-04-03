# Note Taking App - Flutter & SQLite

Ứng dụng ghi chú đa chức năng xây dựng bằng Flutter và SQLite, với khả năng đính kèm hình ảnh và tệp tin.

## Tính năng chính

-   Tạo, chỉnh sửa, xóa ghi chú với tiêu đề và nội dung
-   Chọn độ ưu tiên cho ghi chú (Cao, Vừa, Thấp)
-   Tùy chỉnh màu sắc ghi chú (10 màu khác nhau)
-   Chế độ xem lưới hoặc danh sách
-   Tìm kiếm ghi chú theo tiêu đề và nội dung
-   Đính kèm hình ảnh từ thư viện hoặc camera
-   Đính kèm tệp tin (PDF, văn bản, v.v.)
-   Xem trước hình ảnh đính kèm
-   Chế độ sáng/tối tự động hoặc tùy chỉnh
-   Lưu trữ cục bộ bằng SQLite

## Cấu trúc cơ sở dữ liệu

Ứng dụng sử dụng SQLite với hai bảng chính:

```
+-------------------+        +----------------------+
|    note_table     |        |   attachment_table   |
+-------------------+        +----------------------+
| id (PK)           |        | attachment_id (PK)   |
| title             |        | note_id (FK)         |
| description       |◄-------| file_path            |
| priority          |        | file_name            |
| color             |        | file_type            |
| date              |        | file_size            |
+-------------------+        | created_at           |
                             +----------------------+
```

## Công nghệ sử dụng

-   Flutter & Dart
-   SQLite (sqflite package)
-   Provider cho State Management
-   file_picker và image_picker cho tính năng đính kèm
-   Shared Preferences để lưu thiết lập người dùng
-   Dynamic Theming (chế độ sáng/tối)
-   Material Design 3

## Yêu cầu hệ thống

-   Flutter 3.0 trở lên
-   iOS 11.0+ / Android 5.0+ / Windows / macOS / Linux

### Cho Linux

-   Cần cài đặt `zenity` cho tính năng chọn file
-   Cần cài đặt `xdg-desktop-portal` và portal GUI tương ứng (`xdg-desktop-portal-gtk/kde/...`) cho tính năng chọn ảnh

## Cài đặt

1. Clone repository:

```
git clone https://github.com/yourusername/notes-app.git
```

2. Di chuyển vào thư mục project:

```
cd notes-app
```

3. Cài đặt các dependencies:

```
flutter pub get
```

4. Chạy ứng dụng:

```
flutter run
```
