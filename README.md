# 🏠 TrọPay - Ứng Dụng Quản Lý Chi Tiêu Phòng Trọ & Quỹ Sinh Viên Thông Minh

> **Báo cáo đồ án / Bài tập lớn môn Lập trình thiết bị di động (Mobile Application Development)**  
> **Nền tảng phát triển:** Flutter & Dart  
> **Phiên bản:** `1.0.0`

---

## 📑 Mục lục
1. [Giới thiệu đề tài & Tính cấp thiết](#1-giới-thiệu-đề-tài--tính-cấp-thiết)
2. [Điểm nổi bật & Tính năng sáng tạo](#2-điểm-nổi-bật--tính-năng-sáng-tạo)
3. [Kiến trúc ứng dụng & Công nghệ sử dụng](#3-kiến-trúc-ứng-dụng--công-nghệ-sử-dụng)
4. [Cấu trúc mã nguồn (Project Structure)](#4-cấu-trúc-mã-nguồn-project-structure)
5. [Chi tiết các phân hệ chức năng](#5-chi-tiết-các-phân-hệ-chức-năng)
   - [Phân hệ 1: Quỹ phòng trọ & Chia tiền hóa đơn (Room Fund & Bill Splitter)](#phân-hệ-1-quỹ-phòng-trọ--chia-tiền-hóa-đơn-room-fund--bill-splitter)
   - [Phân hệ 2: Bảng tính toán "Ai nợ ai" (Debt Settlement)](#phân-hệ-2-bảng-tính-toán-ai-nợ-ai-debt-settlement)
   - [Phân hệ 3: Lập ngân sách sinh viên (Student Budgeting)](#phân-hệ-3-lập-ngân-sách-sinh-viên-student-budgeting)
   - [Phân hệ 4: Trợ lý giọng nói tiếng Việt AI (Speech AI Assistant)](#phân-hệ-4-trợ-lý-giọng-nói-tiếng-việt-ai-speech-ai-assistant)
   - [Phân hệ 5: Quản lý Ví & Dòng tiền sinh viên (Accounts & Incomes)](#phân-hệ-5-quản-lý-ví--dòng-tiền-sinh-viên-accounts--incomes)
   - [Phân hệ 6: Quỹ tiết kiệm mục tiêu & Đầu tư học tập (Savings & Investments)](#phân-hệ-6-quỹ-tiết-kiệm-mục-tiêu--đầu-tư-học-tập-savings--investments)
   - [Phân hệ 7: Phân tích thống kê & Dự báo chi tiêu AI (Analytics & Prediction)](#phân-hệ-7-phân-tích-thống-kê--dự-báo-chi-tiêu-ai-analytics--prediction)
   - [Phân hệ 8: Cài đặt hệ thống & Đa ngôn ngữ (Settings & i18n)](#phân-hệ-8-cài-đặt-hệ-thống--đa-ngôn-ngữ-settings--i18n)
6. [Cơ chế lưu trữ & Dữ liệu Hybrid (Offline-First + API Backend)](#6-cơ-chế-lưu-trữ--dữ-liệu-hybrid-offline-first--api-backend)
7. [Hướng dẫn cài đặt & Chạy ứng dụng demo](#7-hướng-dẫn-cài-đặt--chạy-ứng-dụng-demo)

---

## 1. Giới thiệu đề tài & Tính cấp thiết

Đối với sinh viên sống trong các khu ký túc xá hoặc thuê phòng trọ chung, việc quản lý tài chính luôn là một vấn đề phức tạp và nhạy cảm:
- **Chi phí chung phát sinh liên tục:** Tiền thuê phòng trọ, hóa đơn tiền điện (theo số kWh), tiền nước sinh hoạt, mạng internet, tiền rác, gia vị và đồ dùng vệ sinh chung (nước mắm, bột giặt, nước lau sàn...).
- **Khó khăn khi chia tiền:** Một bạn thường đứng ra thanh toán trước cho chủ trọ hoặc siêu thị, sau đó phải tự tính toán chia tiền lẻ cho từng bạn, ghi nhớ ai đã trả và ai chưa trả. Tình trạng "quên trả nợ" hoặc ngại nhắc tiền rất phổ biến.
- **Thiếu quỹ phòng trọ chung:** Khó khăn khi cần tiền mua sắm các vật dụng sinh hoạt đột xuất.

**TrọPay** ra đời nhằm giải quyết triệt để bài toán này, kết hợp mô hình quản lý **Quỹ phòng trọ & Chia hóa đơn nhóm** với **Quản lý tài chính cá nhân sinh viên**, tích hợp công nghệ **Trợ lý giọng nói AI tiếng Việt** và **Mô hình học máy dự báo chi tiêu**.

---

## 2. Điểm nổi bật & Tính năng sáng tạo

1. **Smart Bill Splitter (Chia tiền hóa đơn phòng trọ thông minh):**
   - Hỗ trợ tạo hóa đơn theo danh mục đặc thù: Tiền phòng, Tiền điện, Tiền nước, Mạng Internet, Ăn uống chung...
   - Tự động chia đều cho cả phòng hoặc chọn danh sách bạn tham gia.
   - Đánh dấu trạng thái hoàn tiền của từng thành viên trong 1 chạm.
2. **Debt Settlement ("Ai nợ ai"):**
   - Tự động tính toán tổng số tiền bạn cần trả và số tiền bạn sẽ nhận lại từ các bạn cùng phòng.
   - Bảng tổng hợp minh bạch, rõ ràng, tránh mọi tranh cãi trong phòng trọ.
3. **Quỹ phòng trọ chung (Room Fund):**
   - Thiết lập mức đóng định kỳ (VD: 150.000đ/người/tháng).
   - Theo dõi số dư quỹ chung, ghi nhận lịch sử đóng quỹ và lịch sử chi tiêu từ quỹ.
4. **Trợ lý ảo AI nhận diện giọng nói 2 chiều (STT + TTS):**
   - Nhận lệnh nói tự nhiên tiếng Việt: *"Hôm nay tiền điện 310k chia đều cho cả phòng"*, *"An đóng 150k tiền quỹ phòng"*, *"Mẹ gửi 3 triệu tiền ăn"*.
   - Khả năng **tự học từ vựng (Voice Synonym Learning)** theo thói quen ngôn ngữ của từng người.
5. **Dự báo chi tiêu thông minh bằng AI:**
   - Kết nối mô hình dự báo để ước tính chi tiêu tháng sau và tính toán định mức tiêu tiền mỗi ngày (`Daily Allowance`).
6. **Sẵn sàng chạy Offline (Offline-First Ready):**
   - Dữ liệu phòng trọ, thành viên, hóa đơn mẫu đã được nạp sẵn cục bộ. Giảng viên có thể chạy chấm điểm ngay mà không bắt buộc phải dựng máy chủ Backend.

---

## 3. Kiến trúc ứng dụng & Công nghệ sử dụng

| Công nghệ / Thư viện | Phiên bản | Vai trò trong ứng dụng |
| :--- | :--- | :--- |
| **Flutter SDK** | `>=3.3.0 <4.0.0` | Framework xây dựng giao diện đa nền tảng |
| **Provider** | `^6.0.5` | Quản trị trạng thái (State Management) |
| **Shared Preferences** | `^2.2.2` | Lưu trữ cục bộ dữ liệu phòng trọ, thành viên, hóa đơn, quỹ phòng |
| **Flutter Secure Storage** | `^9.0.0` | Lưu Access Token bảo mật |
| **Dio & HTTP** | `^5.4.0` / `^1.2.2` | Gọi API RESTful & Token Interceptors |
| **Speech To Text** | `^7.3.0` | Thu âm và chuyển giọng nói tiếng Việt thành văn bản |
| **Flutter TTS** | `^3.8.3` | Trợ lý phát giọng nói tiếng Việt tương tác với người dùng |
| **Diacritic** | `^0.1.6` | Chuẩn hóa, bóc tách dấu tiếng Việt phục vụ NLP |
| **FL Chart** | `^0.66.0` | Vẽ biểu đồ thống kê cơ cấu ngân sách sinh viên |
| **Intl & Flutter Localizations** | `^0.20.2` | Đa ngôn ngữ (i18n Tiếng Việt & English), định dạng tiền tệ |

---

## 4. Cấu trúc mã nguồn (Project Structure)

```
lib/
├── main.dart                          # Khởi tạo App, MultiProvider, Theme & Bottom Navigation 5 Tab
├── roommate/                          # [MỚI] Module Phòng trọ & Chia tiền TrọPay
│   ├── roommate_model.dart            # Models: RoommateMember, BillSplitItem, RoomFund, FundTransaction, DebtRecord
│   ├── roommate_service.dart          # Service lưu trữ SharedPreferences & Dữ liệu mẫu ban đầu
│   └── roommate_provider.dart         # Provider tính toán nợ nần, chia tiền, quản lý quỹ phòng
├── pages/
│   ├── roommate_page.dart             # [MỚI] Màn hình Quỹ phòng trọ, Chia tiền & Ai nợ ai
│   ├── budgets_page.dart              # Tab 2: Ngân sách tháng sinh viên & Hạn mức chi tiêu
│   ├── accounts_page.dart             # Tab 3: Ví cá nhân, nguồn tiền sinh viên, sổ tiết kiệm
│   ├── analytics_page.dart            # Tab 4: Biểu đồ thu chi, dự báo AI chi tiêu tháng sau
│   ├── setting/
│   │   ├── setting_page.dart          # Tab 5: Cài đặt giao diện, Dark Mode, cỡ chữ, thông tin TrọPay
│   │   ├── money_settings_page.dart   # Cấu hình tiền tệ (VND, USD)
│   │   └── settings_provider.dart     # Provider lưu cài đặt
│   ├── note_page.dart                 # Màn hình FAB: Bàn phím số Numpad & Trợ lý giọng nói AI
│   ├── allocate_money_page.dart       # Phân bổ ngân sách theo phong bì
│   ├── profile_page.dart              # Hồ sơ cá nhân & đổi mật khẩu
│   └── transactions_page.dart         # Sổ giao dịch chi tiết theo ngày/tháng
├── api/                               # Tầng giao tiếp mạng & API Services
│   ├── ai/                            # AI Voice Intent Parser, STT, TTS & Prediction Service
│   ├── bankaccount/                   # API Ví / Tài khoản ngân hàng
│   ├── income/                        # API Nguồn thu nhập sinh viên
│   ├── saving/                        # API Sổ tiết kiệm mục tiêu
│   ├── investment/                    # API Đầu tư (Vàng SJC, Crypto CoinGecko, Cổ phiếu VNDirect)
│   └── transaction/                   # API Giao dịch thu/chi
├── core/                              # Tiện ích lõi (Date, Money, Voice Synonym Store...)
└── widgets/                           # Form tạo/sửa tài khoản, nguồn thu, tiết kiệm, đầu tư
```

---

## 5. Chi tiết các phân hệ chức năng

### Phân hệ 1: Quỹ phòng trọ & Chia tiền hóa đơn (Room Fund & Bill Splitter)
- **Tập tin:** [`roommate_page.dart`](file:///e:/Base%20Sources%202026/Quan_ly_chi_tieu/lib/pages/roommate_page.dart), [`roommate_provider.dart`](file:///e:/Base%20Sources%202026/Quan_ly_chi_tieu/lib/roommate/roommate_provider.dart).
- **Chức năng:**
  - **Quản lý danh sách thành viên:** Hiển thị tên, biệt danh, số điện thoại, màu đại diện cho từng bạn trong phòng. Hỗ trợ thêm bạn mới hoặc xóa thành viên.
  - **Tạo hóa đơn chia tiền:**
    - Lựa chọn danh mục: *Tiền phòng trọ, Tiền điện, Tiền nước, Mạng Internet, Ăn uống chung, Đồ dùng chung*.
    - Nhập số tiền và chọn người đã chi trả trước.
    - Chọn danh sách các bạn cùng tham gia chia tiền (hỗ trợ loại trừ thành viên không tham gia).
    - Tự động chia đều số tiền cho từng người theo thời gian thực.
  - **Theo dõi tiến độ hoàn tiền:** Nút chuyển đổi nhanh `Chưa trả` ⇄ `Đã trả` cho từng người trên mỗi hóa đơn.
  - **Quỹ phòng trọ chung:** Thẻ tổng quan số dư quỹ phòng, ghi nhận các khoản đóng quỹ (Nạp tiền) và các khoản chi từ quỹ (mua sắm đồ dùng chung).

---

### Phân hệ 2: Bảng tính toán "Ai nợ ai" (Debt Settlement)
- **Tập tin:** [`roommate_provider.dart`](file:///e:/Base%20Sources%202026/Quan_ly_chi_tieu/lib/roommate/roommate_provider.dart).
- **Chức năng:**
  - Thuật toán tự động quét toàn bộ hóa đơn chưa hoàn tất trong phòng để xác định:
    - **Khoản bạn cần trả:** Bạn đang nợ ai, số tiền bao nhiêu, tương ứng với hóa đơn nào.
    - **Khoản bạn sẽ nhận lại:** Ai đang nợ bạn tiền (do bạn đã thanh toán trước hóa đơn).
  - Thẻ thông số nhanh trên cùng hiển thị 2 khối màu trực quan:
    - 🔴 **Bạn cần trả:** Cảnh báo đỏ nếu bạn còn nợ tiền phòng/điện nước.
    - 🟢 **Bạn sẽ nhận:** Hiển thị xanh nếu bạn đã chi trả trước và đang đợi các bạn gửi lại.

---

### Phân hệ 3: Lập ngân sách sinh viên (Student Budgeting)
- **Tập tin:** [`budgets_page.dart`](file:///e:/Base%20Sources%202026/Quan_ly_chi_tieu/lib/pages/budgets_page.dart), [`allocate_money_page.dart`](file:///e:/Base%20Sources%202026/Quan_ly_chi_tieu/lib/pages/allocate_money_page.dart).
- **Chức năng:**
  - Áp dụng phương pháp phong bì chi tiêu (**Zero-Based Budgeting**): Giúp sinh viên phân bổ số tiền bố mẹ gửi hoặc tiền làm thêm vào từng khoản mục cụ thể đầu tháng.
  - Hạn mức theo các hạng mục sinh viên: Tiền phòng trọ, Ăn uống, Tiền điện nước, Giáo trình học tập, Di chuyển xe buýt...
  - **Cảnh báo vượt hạn mức 4 cấp:** Xanh lá (< 75%), Vàng (75-90%), Cam (90-100%) và Đỏ (> 100% kèm số tiền vượt mức).

---

### Phân hệ 4: Trợ lý giọng nói tiếng Việt AI (Speech AI Assistant)
- **Tập tin:** [`note_page.dart`](file:///e:/Base%20Sources%202026/Quan_ly_chi_tieu/lib/pages/note_page.dart), [`voice_intent.dart`](file:///e:/Base%20Sources%202026/Quan_ly_chi_tieu/lib/api/ai/voice_intent.dart), [`voice_synonym_store.dart`](file:///e:/Base%20Sources%202026/Quan_ly_chi_tieu/lib/core/voice/voice_synonym_store.dart).
- **Chức năng:**
  - Giao tiếp 2 chiều: Trợ lý phát giọng nói hướng dẫn -> Thu âm câu nói của sinh viên -> Xử lý NLP bóc tách số tiền, danh mục, ví nguồn.
  - Hỗ trợ ngôn ngữ tự nhiên sinh viên: `50k`, `100 nghìn`, `2 triệu`, `mẹ gửi`, `học bổng`, `tiền trọ`, `tiền điện`.
  - **Tự học từ vựng (Voice Learning):** Ghi nhớ các từ lóng hoặc cách gọi riêng của người dùng vào bộ nhớ cục bộ để cải thiện độ chính xác ở các lần sau.

---

### Phân hệ 5: Quản lý Ví & Dòng tiền sinh viên (Accounts & Incomes)
- **Tập tin:** [`accounts_page.dart`](file:///e:/Base%20Sources%202026/Quan_ly_chi_tieu/lib/pages/accounts_page.dart).
- **Chức năng:**
  - Quản lý đa ví: Ví MoMo, ZaloPay, Tài khoản Ngân hàng (Vietcombank, MB Bank, Techcombank...), Tiền mặt.
  - Tính năng **Ẩn số dư bảo mật (`Hide Balance`)** khi mở app ở nơi công cộng.
  - Quản lý các dòng tiền thu nhập đặc trưng sinh viên: Tiền gia đình hỗ trợ hàng tháng, Lương làm thêm part-time, Học bổng khuyến khích học tập.

---

### Phân hệ 6: Quỹ tiết kiệm mục tiêu & Đầu tư học tập (Savings & Investments)
- **Tập tin:** [`saving_provider.dart`](file:///e:/Base%20Sources%202026/Quan_ly_chi_tieu/lib/api/saving/saving_provider.dart), [`investment_provider.dart`](file:///e:/Base%20Sources%202026/Quan_ly_chi_tieu/lib/api/investment/investment_provider.dart).
- **Chức năng:**
  - Lập quỹ tiết kiệm tích lũy: Mua laptop mới, Tiền đóng học phí kỳ tới, Quỹ du lịch cùng lớp.
  - Theo dõi danh mục đầu tư cá nhân tích lũy với cập nhật thị giá thời gian thực:
    - 🥇 **Vàng SJC:** Tích hợp API SJC TP.HCM.
    - 🪙 **Crypto:** Tích hợp API CoinGecko.
    - 📈 **Chứng khoán VN:** Tích hợp API VNDirect.

---

### Phân hệ 7: Phân tích thống kê & Dự báo chi tiêu AI (Analytics & Prediction)
- **Tập tin:** [`analytics_page.dart`](file:///e:/Base%20Sources%202026/Quan_ly_chi_tieu/lib/pages/analytics_page.dart), [`ai_service.dart`](file:///e:/Base%20Sources%202026/Quan_ly_chi_tieu/lib/api/ai/ai_service.dart).
- **Chức năng:**
  - Dự báo mức chi tiêu tháng tiếp theo bằng mô hình AI (`/api/predict`).
  - Biểu đồ tròn tỷ trọng ngân sách (FL Chart).
  - Thanh so sánh chi tiêu thực tế (MTD) với dự báo và ngân sách.
  - Tính toán định mức tiêu tiền mỗi ngày (`Daily Allowance`) giúp sinh viên không bị "cháy túi" cuối tháng.

---

### Phân hệ 8: Cài đặt hệ thống & Đa ngôn ngữ (Settings & i18n)
- **Tập tin:** [`setting_page.dart`](file:///e:/Base%20Sources%202026/Quan_ly_chi_tieu/lib/pages/setting/setting_page.dart), [`money_settings_page.dart`](file:///e:/Base%20Sources%202026/Quan_ly_chi_tieu/lib/pages/setting/money_settings_page.dart).
- **Chức năng:**
  - Hỗ trợ song ngữ: **Tiếng Việt** và **English**.
  - Giao diện Sáng / Tối (Light & Dark Theme).
  - Tùy chỉnh màu chủ đạo (Color Seeds).
  - Tùy biến định dạng tiền tệ (VND, USD) và dấu phân cách số.

---

## 6. Cơ chế lưu trữ & Dữ liệu Hybrid (Offline-First + API Backend)

Ứng dụng được thiết kế theo mô hình **Hybrid thông minh**:
1. **Chế độ Offline-First (Mặc định khi demo bài tập lớn):**
   - Phân hệ Quỹ phòng trọ, Thành viên, Chia hóa đơn, Bảng nợ nần và Cài đặt hoạt động hoàn toàn cục bộ trên máy thông qua `SharedPreferences`.
   - Ứng dụng đã tích hợp sẵn **Bộ dữ liệu mẫu hoàn chỉnh** (Phòng 304 Bách Khoa, 4 thành viên, hóa đơn tiền điện 310 kWh, hóa đơn mạng FPT, quỹ phòng 650.000đ).
   - 👉 **Giảng viên mở ứng dụng lên là thấy đầy đủ dữ liệu demo sinh động ngay lập tức.**
2. **Chế độ Kết nối API Backend (Khi có server):**
   - Hỗ trợ đồng bộ tài khoản, đăng nhập JWT Bearer Token, lưu ngân sách và gọi API Machine Learning dự báo `/api/predict`.

---

## 7. Hướng dẫn cài đặt & Chạy ứng dụng demo

### 1. Chuẩn bị môi trường
- Đã cài đặt Flutter SDK (`>= 3.3.0`).
- Thiết bị thật Android/iOS hoặc máy ảo Android Emulator.

### 2. Cài đặt thư viện
Tại thư mục gốc dự án, chạy lệnh:
```bash
flutter pub get
```

### 3. Chạy ứng dụng
Khởi động ứng dụng trực tiếp:
```bash
flutter run
```

*(Tùy chọn) Chạy với địa chỉ IP Backend riêng:*
```bash
flutter run --dart-define=API_BASE=http://<IP_BACKEND>:8000
```

---
*Đồ án môn Lập trình thiết bị di động - Ứng dụng TrọPay © 2026*
