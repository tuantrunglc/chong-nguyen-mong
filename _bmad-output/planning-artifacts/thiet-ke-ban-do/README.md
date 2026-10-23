# Hướng Dẫn & Quy Chuẩn Thiết Kế Bản Đồ (Level Design)

Thư mục này dùng để lưu trữ toàn bộ hồ sơ thiết kế, sa bàn chiến thuật, và lời giải cho chuỗi chiến dịch 6 trận của game *Hào Khí Đông A* (1288) cùng các trận thử nghiệm chiến thuật.

---

## 1. Ký hiệu quy chuẩn (Grid Symbols)

Mỗi file dữ liệu trận (`.json`) định nghĩa bàn cờ qua 2 lớp chuỗi: **Địa hình (`dia_hinh`)** và **Quân cờ (`quan`)**.

### Địa hình:
| Ký hiệu | Tên địa hình | Kích thước | Thuộc tính |
|---|---|---|---|
| `.` | Đất trống / Cỏ | 64×64 | Đi được, không chặn đòn |
| `~` | Sông | 64×64 | **Không đi được**, không chặn lao/tên. Quân Nguyên vào đây **chết đuối ngay**; Tướng vào thì va chạm mất 1 máu |
| `#` | Rừng rậm / Tre trúc | 64×96 (nhô cao) | **Không đi được**, **chặn** lao, tên, xung phong. Va vào mất 1 máu |
| `^` | Hầm chông tre | 64×64 | **Đi được**. Bất kỳ quân nào đi vào/băng qua mất 1 máu |
| `L` | Kho lương | 64×96 (nhô cao) | **Không đi được**, **chặn đòn**. Hồi 1 máu cho quân Nguyên kề bên cuối hiệp. Bị đốt bởi *Vườn không nhà trống* |
| `D` | Làng quê | 64×96 (nhô cao) | **Không đi được**, **chặn đòn**. Mỗi khi bị trúng đòn/va chạm thì **Lòng dân −1** |
| `A` | Ô ải (Bệ đá Vạn Kiếp) | 64×64 | Đi được. Mục tiêu bảo vệ trong trận *Giữ ải* |

### Quân cờ:
| Ký hiệu | Tên quân | Phe | Máu | Tầm đi | Đòn đánh & Kỹ năng |
|---|---|---|---|---|---|
| `1` | Nguyễn Khoái | Đại Việt | 3 | 3 | Tiên phong: chém 1 ô kề, **2 sát thương**, **đẩy lùi 1 ô** |
| `2` | Phạm Ngũ Lão | Đại Việt | 3 | 3 | Phóng xa: phóng lao thẳng hàng **2–4 ô**, bay qua ô kề, **1 sát thương** |
| `3` | Trần Khánh Dư | Đại Việt | 3 | 3 | Khống chế: kéo quân Nguyên trong vòng **3 ô** về phía mình **2 ô**, 0 sát thương |
| `B` | Bộ binh Nguyên | Nguyên | 3 | 2 | Cận chiến: chém 1 ô kề, **1 sát thương** |
| `K` | Kỵ binh Mông Cổ | Nguyên | 2 | 3 | Xung phong thẳng hàng, **1 sát thương** vào vật đầu tiên trên đường |
| `C` | Cung kỵ | Nguyên | 1 | 3 | Bắn thẳng hàng **2–3 ô**, **1 sát thương**, tên bay qua quân (bị rừng/kho chặn) |

---

## 2. Nguyên tắc Thiết Kế Câu Đố Chiến Thuật (Tactical Puzzle Principles)

1. **Địa hình là vũ khí:** Mỗi trận phải cho người chơi cơ hội tận dụng địa hình để tiêu diệt địch (đẩy xuống sông, đẩy vào hầm chông, dùng rừng che chắn đòn xung phong).
2. **Khắc chế vai trò:** 
   - Bộ binh trâu máu (3 máu) -> Giải quyết bằng đẩy rơi sông, va chạm hoặc đẩy vào hầm chông.
   - Kỵ binh đe dọa thẳng hàng -> Đứng né khỏi hàng hoặc dùng Dư kéo lệch hướng, lừa Kỵ binh xung phong trúng đồng đội.
   - Cung kỵ yếu máu (1 máu) nhưng bắn xa -> Ưu tiên cho Phạm Ngũ Lão phóng lao kết liễu từ xa.
3. **Mỗi trận dạy một luật mới:**
   - Trận 1: Né ô đỏ, đẩy địch xuống sông (Nguyễn Khoái & Phạm Ngũ Lão).
   - Trận 2: Kỵ binh xung phong, dùng rừng chặn đường, địch đánh trúng nhau.
   - Trận 3: Trần Khánh Dư ra trận, đòn kéo, hầm chông, giới hạn hiệp.
   - Trận 4: Bảo vệ làng quanh Vạn Kiếp, Lòng dân.
   - Trận 5: Kho lương, *Vườn không nhà trống*, quân tiếp viện, Giữ ải.
   - Trận 6: Đại chiến tổng hợp mọi cơ chế, mưu kế *Sát Thát*.
4. **Luôn có lời giải hoàn hảo không mất tướng:** Mọi màn chơi thiết kế phải được kiểm chứng bằng file lời giải `.md` và kịch bản tự động `.json` chạy pass 100% trong `tools/test.sh`.

---

## 3. Đề Xuất Cân Bằng & Mở Rộng

Xem chi tiết báo cáo đánh giá độ khó và đề xuất bổ sung các đơn vị quân mới (Thuẫn binh có giáp, Hỏa tiễn binh, Boss Ô Mã Nhi, danh tướng dự bị) tại:
- [`de_xuat_can_bang_va_mo_rong_quan_co.md`](file:///home/trung.nguyen11/Documents/GameTest/_bmad-output/planning-artifacts/de_xuat_can_bang_va_mo_rong_quan_co.md)
