# Nguồn gốc & các thay đổi có chủ đích

## 1. Tệp gốc

| | |
|---|---|
| Tên | `main 2.txt` |
| Dòng | 26.515 |
| Byte | 993.469 |
| sha256 | `c1207ab32fba1ecd4c4203a385da3431f30f7413c50b875e9586891b86313429` |
| Ngôn ngữ | Lua / Luau (Roblox executor) |

Kiểm tra lại:

```bash
sha256sum "main 2.txt"
```

## 2. Chỉ có 4 thay đổi

Tất cả nằm ở 3 vị trí, mục đích duy nhất là **gỡ hai closure ngoài cùng** để thư viện UI
(~24.900 dòng) không còn là một tệp khổng lồ.

| Dòng | Bản gốc | Trong repo | Vì sao |
|---:|---|---|---|
| 19 | `local LIB = (function()` | *bỏ* | closure A chỉ để tạo scope, không còn cần |
| 201 | `local LIB = (function()` | `local LIB` | khai báo biến thay cho closure B |
| 25082 | `return require(NgotStudio["3e"])` | `LIB = require(NgotStudio["3e"])` | gán thay vì return (không còn closure để return) |
| 25083 | `end)()` | *bỏ* | đóng closure B |
| 26021 | `return LIB` | *bỏ* | `return` ở cấp chunk sẽ cắt cụt script |
| 26022 | `end)()` | *bỏ* | đóng closure A |

Tổng cộng **6 dòng** bị đụng tới: 2 dòng viết lại, 4 dòng bỏ hẳn (26.515 − 4 = 26.511 dòng,
đúng bằng số dòng thân module). Dung lượng: 993.469 B → 993.405 B (−64 B).

### Vì sao an toàn

- Closure A và B **không tạo ra logic riêng** — chúng chỉ bọc scope. Sau khi làm phẳng, mọi
  `local` bên trong trở thành local cấp chunk, cùng một chỗ nhìn thấy như trước.
- `LIB` vẫn đúng một mạch: `local LIB` (khai báo) → `lib/080_module_open` mở framework →
  `LIB = require(NgotStudio["3e"])` gán thư viện → boot đọc `LIB` → `return LIB` ở dòng cuối.
- Không đổi tên biến, không đổi thứ tự khai báo, không gộp tệp dữ liệu.

### Hệ quả đã kiểm tra

```bash
python3 src/build.py --verify-source "main 2.txt"
#   ✔ verify-source: khớp từng byte (26511 dòng)
#   26.515 − 4 dòng đã bỏ = 26.511 ✔

diff "main 2.txt" dist/xngot_studio.lua
# 19d18            < local LIB = (function()
# 201c200          < local LIB = (function()   ---   > local LIB
# 25082,25083c25081 < return require(...)       ---   > LIB = require(...)
# 26021,26022d26018 < return LIB / end)()
```

Đúng 4 hunk — không có thay đổi nào khác.

## 3. Việc chia nhỏ

| | |
|---|---|
| Module | 150 |
| Dòng thân module | 26.511 (= đúng số dòng sau 4 thay đổi) |
| Tệp banner | 150 (mỗi tệp một comment đầu tệp) |
| Ghép | theo thứ tự dòng gốc, không đảo |
| Chia cắt | chỉ ở ranh giới câu lệnh, không cắt giữa biểu thức |

Riêng bộ icon (7.797 dòng) được chia theo **chữ cái đầu của tên icon** — 26 shard
`040_icons_*.lua`, mỗi shard là một dãy entry liên tục trong bảng `Icons`.

## 4. Những gì **không** thay đổi

- Không đổi tên hàm/biến/bảng toàn cục: `LIB`, `Window`, `_G.xNgotMusicConfig`,
  `_G.CrossAIMusic`, `_G.xNgotLog`, `_G.xNgotDebug`, `_G.xNgotDevTools`, `_G.xNgotDebugBridge`,
  `_G.__xNgotEmbeddedLibrary`, `getgenv().xNgotStudio`… giữ nguyên.
- Không đổi chuỗi hiển thị, không đổi `Version = "3.0.0"`, không đổi `KeySystem` mặc định.
- Không đổi thứ tự thực thi, không di chuyển code giữa các nhánh `if`.
- Comment kỹ thuật trong bản gốc (`-- FILE-MANAGER:`, `-- METADATA:`, `-- FIX(...)`) được giữ
  nguyên văn — chúng giải thích các lỗi đã sửa, bỏ đi sẽ mất ngữ cảnh.

## 5. Quy trình tái tạo từ đầu

```bash
# 1. chia bản gốc -> src/modules/**  + src/manifest.json
python3 tools/split_source.py "main 2.txt" .

# 2. kiểm tra + build
python3 src/build.py --check
python3 src/build.py --verify-source "main 2.txt"
python3 src/build.py            # dist/xngot_studio.lua
python3 src/build.py --release  # dist/main.lua

# 3. sinh lại docs
python3 src/build.py --docs
```

Toàn bộ chạy dưới 10 giây, không cần thư viện ngoài.

## 6. Ghi công

Toàn bộ mã nguồn, giao diện, bảng nổi, engine nhạc và loader trong repo này do **xNgot Zume**
(Nguyễn Minh Nhật) viết và duy trì.

Xem thêm [`LICENSE`](../LICENSE).
