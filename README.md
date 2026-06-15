# Hướng dẫn Biên dịch và Cài đặt Ứng dụng iOS (.ipa) trên Windows

Dự án này là ứng dụng **Device Utility Pro** được phát triển bằng **SwiftUI** dành riêng cho thiết bị iOS 15+. 

Vì hệ điều hành Windows không hỗ trợ biên dịch trực tiếp ứng dụng iOS, chúng ta sẽ sử dụng dịch vụ đám mây miễn phí **GitHub Actions** (chạy trên máy Mac của GitHub) để tự động biên dịch và tạo ra file cài đặt `.ipa` chưa ký (unsigned). File `.ipa` này cực kỳ phù hợp để cài đặt qua **TrollStore** (không bị thu hồi) hoặc các công cụ sideload như **Sideloadly / AltStore**.

---

## BƯỚC 1: Đưa mã nguồn lên GitHub (Không cần cài đặt Git)

Nếu máy tính của bạn chưa cài đặt Git, bạn có thể thực hiện tải toàn bộ thư mục này lên GitHub thông qua trình duyệt web:

1. Truy cập trang web [GitHub.com](https://github.com/) và đăng nhập (hoặc đăng ký tài khoản miễn phí nếu chưa có).
2. Tạo một Kho lưu trữ mới (Repository):
   * Nhấp vào nút **New** (hoặc dấu cộng `+` ở góc phải chọn *New repository*).
   * Đặt tên kho lưu trữ (Ví dụ: `ios-device-utility`).
   * Chọn chế độ **Public** hoặc **Private** tùy ý bạn.
   * **LƯU Ý:** Không chọn thêm README, .gitignore hay License. Hãy để kho trống hoàn toàn.
   * Nhấp **Create repository**.
3. Tại trang hiển thị tiếp theo, nhấp vào liên kết **"uploading an existing file"** ở phần thiết lập nhanh.
4. Kéo thả các tệp tin và thư mục từ máy tính của bạn vào trình duyệt. Cấu trúc thư mục cần tải lên gồm:
   * Thư mục `.github/` (chứa workflow biên dịch tự động)
   * Thư mục `Sources/` (chứa mã nguồn Swift)
   * Thư mục `Resources/` (chứa tài nguyên giao diện)
   * Tệp tin `project.yml`
   * Tệp tin `README.md`
5. Nhấp nút **Commit changes** ở cuối trang để xác nhận tải lên.

---

## BƯỚC 2: Tải xuống file `.ipa` đã biên dịch từ GitHub

Ngay sau khi bạn tải mã nguồn lên, hệ thống biên dịch tự động (GitHub Actions) sẽ tự kích hoạt:

1. Trên trang kho lưu trữ của bạn ở GitHub, chọn tab **Actions** ở menu phía trên.
2. Bạn sẽ thấy một tiến trình biên dịch đang chạy có tên **Build iOS Application** (có biểu tượng hình tròn màu vàng đang xoay).
3. Đợi khoảng **2 đến 3 phút** cho đến khi vòng tròn chuyển thành dấu tích màu xanh lá cây tượng trưng cho biên dịch thành công.
4. Nhấp vào tên của lần chạy đó (ví dụ: *Build Unsigned IPA* hoặc tiêu đề commit của bạn).
5. Cuộn xuống phần **Artifacts** ở cuối trang, nhấp vào **DeviceUtility-Unsigned-IPA** để tải xuống tệp tin `.zip`.
6. Giải nén tệp tin vừa tải về, bạn sẽ nhận được file **DeviceUtility.ipa**.

---

## BƯỚC 3: Cài đặt file `.ipa` vào iPhone 7 Plus (iOS 15.7.6)

Dưới đây là 3 cách phổ biến nhất để cài đặt file `.ipa` này:

### Cách A: Cài đặt qua TrollStore (Khuyên dùng - Cài vĩnh viễn)
Vì iPhone 7 Plus chạy iOS 15.7.6 hỗ trợ TrollStore rất tốt (TrollStore sử dụng lỗ hổng CoreTrust để cài app mà không cần ký chứng chỉ và không bao giờ hết hạn):
1. Đảm bảo iPhone của bạn đã cài đặt **TrollStore** (nếu chưa, bạn có thể jailbreak bằng *palera1n* rồi cài đặt TrollHelper).
2. Chuyển file `DeviceUtility.ipa` sang iPhone (gửi qua iCloud Drive, gửi lên Google Drive rồi tải về điện thoại, hoặc dùng AirDrop từ Mac).
3. Mở file `.ipa` trên iPhone, bấm nút Share và chọn mở bằng **TrollStore**.
4. TrollStore sẽ tiến hành cài đặt ứng dụng vào máy chỉ trong 2 giây. Bạn có thể mở và sử dụng vĩnh viễn.

### Cách B: Sideload qua Sideloadly (Cần máy tính Windows)
Công cụ Sideloadly sẽ tự động dùng Apple ID của bạn để ký và cài đặt app:
1. Tải và cài đặt **Sideloadly** trên máy tính Windows của bạn.
2. Cài đặt iTunes và iCloud bản chính thức từ Apple trên PC (không dùng bản Microsoft Store để tránh lỗi kết nối).
3. Kết nối iPhone 7 Plus vào máy tính qua cáp USB và chọn "Tin cậy thiết bị".
4. Mở Sideloadly, kéo thả file `DeviceUtility.ipa` vào ô ứng dụng.
5. Nhập **Apple ID** của bạn vào ô Apple Account.
6. Nhấp nút **Start**. Nhập mật khẩu Apple ID nếu được yêu cầu (Sideloadly kết nối trực tiếp đến máy chủ Apple để xin chứng chỉ phát triển).
7. Khi thấy dòng chữ `Done.`, ứng dụng sẽ xuất hiện trên màn hình iPhone. Vào mục *Cài đặt > Cài đặt chung > Quản lý thiết bị* trên iPhone để Tin cậy nhà phát triển trước khi mở app.
*Lưu ý:* App cài bằng cách này sẽ hết hạn sau 7 ngày, cần kết nối cáp để Sideloadly tự động ký lại.

### Cách C: Cài đặt qua AltStore
Tương tự Sideloadly, AltStore giúp bạn tự động gia hạn app mỗi khi kết nối cùng mạng Wi-Fi với máy tính chạy AltServer:
1. Tải AltServer về máy tính Windows và cài đặt AltStore lên iPhone.
2. Chuyển file `.ipa` vào ứng dụng *Tệp (Files)* trên iPhone.
3. Mở AltStore trên iPhone, chuyển sang tab **My Apps**, nhấn nút `+` ở góc trái màn hình.
4. Chọn file `DeviceUtility.ipa` để bắt đầu cài đặt.
