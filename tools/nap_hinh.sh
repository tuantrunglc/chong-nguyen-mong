#!/usr/bin/env bash
# Chép hình bản cuối từ kho nháp img/pixellab-thu/toi_uu/ vào game/assets/textures/ (Story 8.1).
# Đổi tên theo quy ước tex_<tên>.png (chữ thường, không dấu, gạch dưới). Chạy lại được: file không đổi thì bỏ qua.
# Không chép: ảnh tổng hợp (_tong_hop_*, _so_sanh_*, _mockup_*), *.gif, bảng ghép spritesheet, bản 64/320 thừa,
# chân dung E4, thuyền (làm ở E7), ảnh bìa itch.io.
# Ví dụ: tools/nap_hinh.sh
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NGUON="$REPO_ROOT/img/pixellab-thu/toi_uu"
DICH="$REPO_ROOT/game/assets/textures"

so_moi=0
so_cap_nhat=0
so_khong_doi=0
so_loi=0

# chep <file nguồn tính từ toi_uu/> <file đích tính từ textures/>
chep() {
	local nguon="$NGUON/$1"
	local dich="$DICH/$2"
	if [[ ! -f "$nguon" ]]; then
		echo "❌ Không thấy file nguồn: img/pixellab-thu/toi_uu/$1" >&2
		so_loi=$((so_loi + 1))
		return
	fi
	mkdir -p "$(dirname "$dich")"
	if [[ ! -f "$dich" ]]; then
		cp "$nguon" "$dich"
		so_moi=$((so_moi + 1))
	elif ! cmp -s "$nguon" "$dich"; then
		cp "$nguon" "$dich"
		so_cap_nhat=$((so_cap_nhat + 1))
	else
		so_khong_doi=$((so_khong_doi + 1))
	fi
}

# Bỏ phần đuôi .png và đổi gạch ngang thành gạch dưới.
ten_goc() {
	local t="${1%.png}"
	echo "${t//-/_}"
}

# ---------- A. Địa hình ----------
for n in $(seq 0 15); do chep "dia_hinh/o_nen/tile_$n.png" "dia_hinh/tex_o_nen_$n.png"; done
for n in 0 1 2 3; do chep "dia_hinh/o_nen/tile_co_le_$n.png" "dia_hinh/tex_o_co_le_$n.png"; done
# Vật cản: bỏ tiền tố mã (a3_, a4_...)
for f in "$NGUON"/dia_hinh/vat_can/a[3-8]_*.png; do
	b="$(basename "$f")"
	chep "dia_hinh/vat_can/$b" "dia_hinh/tex_$(ten_goc "${b#a?_}").png"
done
for f in "$NGUON"/dia_hinh/khung_ban_co/*.png; do
	b="$(basename "$f")"
	chep "dia_hinh/khung_ban_co/$b" "dia_hinh/tex_khung_$(ten_goc "$b").png"
done

# ---------- B. Quân ----------
# Hình đứng 8 hướng. Nguồn của Bộ binh là thư mục nguyen_v3.
HUONG8="north north-east east south-east south south-west west north-west"
for quan in khoai lao du ky_binh cung_ky; do
	for h in $HUONG8; do chep "$quan/$h.png" "quan/tex_${quan}_${h//-/_}.png"; done
done
for h in $HUONG8; do chep "nguyen_v3/$h.png" "quan/tex_bo_binh_${h//-/_}.png"; done

# Hoạt ảnh: khung rời, bỏ spritesheet. Đi: hoat_anh/<quân>/<hướng>_<n>.png
QUAN6="khoai lao du bo_binh ky_binh cung_ky"
for quan in $QUAN6; do
	for h in north east south west; do
		for n in 0 1 2 3; do chep "hoat_anh/$quan/${h}_$n.png" "hoat_anh/tex_${quan}_di_${h}_$n.png"; done
	done
	for h in east south west; do
		for n in 0 1 2 3; do chep "hoat_anh/tan_cong/$quan/${h}_$n.png" "hoat_anh/tex_${quan}_danh_${h}_$n.png"; done
	done
done
# Trúng đòn, gục, chết đuối: <hành động>/<quân>/<tiền tố>_<...>.png (Cung kỵ có thêm biến thể east, west)
chep_hanh_dong() { # <thư mục nguồn> <tiền tố file> <tên hành động đích> <quân...>
	local thu_muc="$1" tien_to="$2" hanh_dong="$3"
	shift 3
	local quan f b
	for quan in "$@"; do
		for f in "$NGUON/hoat_anh/$thu_muc/$quan/${tien_to}"_*.png; do
			b="$(basename "$f")"
			chep "hoat_anh/$thu_muc/$quan/$b" "hoat_anh/tex_${quan}_${hanh_dong}_${b#"${tien_to}"_}"
		done
	done
}
chep_hanh_dong bi_thuong hurt trung_don $QUAN6
chep_hanh_dong guc_nga death guc $QUAN6
chep_hanh_dong chet_duoi drown chet_duoi bo_binh ky_binh cung_ky

# ---------- C. Hiệu ứng ----------
for f in "$NGUON"/hieu_ung/c[0-9]*.png; do
	b="$(basename "$f")"
	chep "hieu_ung/$b" "hieu_ung/tex_$(ten_goc "$(echo "$b" | sed -E 's/^c[0-9]+_//')").png"
done
for n in 0 1 2 3; do chep "hieu_ung/vet_chem/vet_chem_$n.png" "hieu_ung/tex_vet_chem_$n.png"; done

# ---------- D. Giao diện ----------
for f in "$NGUON"/giao_dien/*.png; do
	b="$(basename "$f")"
	[[ "$b" == _* ]] && continue
	chep "giao_dien/$b" "giao_dien/tex_$(ten_goc "$(echo "$b" | sed -E 's/^d[0-9]+_//')").png"
done
for sub in con_tro o_co bong_do trien_an; do
	for f in "$NGUON"/giao_dien/$sub/*.png; do
		b="$(basename "$f")"
		chep "giao_dien/$sub/$b" "giao_dien/tex_$(ten_goc "$(echo "$b" | sed -E 's/^d[0-9]+_//')").png"
	done
done
# Chữ số: chỉ chép bảng ghép (Story 8.1, bảng ánh xạ)
chep "giao_dien/chu_so/so_to_sheet_156x16.png" "giao_dien/tex_so_to_sheet_156x16.png"
chep "giao_dien/chu_so/so_nho_sheet_104x10.png" "giao_dien/tex_so_nho_sheet_104x10.png"

# ---------- E. Chân dung (ba tướng, bản 96) ----------
chep "chan_dung/e1_khoai_96x96.png" "chan_dung/tex_chan_dung_khoai.png"
chep "chan_dung/e1_khoai_khung_96x96.png" "chan_dung/tex_chan_dung_khoai_khung.png"
chep "chan_dung/e2_lao_96x96.png" "chan_dung/tex_chan_dung_lao.png"
chep "chan_dung/e2_lao_khung_96x96.png" "chan_dung/tex_chan_dung_lao_khung.png"
chep "chan_dung/e3_du_96x96.png" "chan_dung/tex_chan_dung_du.png"
chep "chan_dung/e3_du_khung_96x96.png" "chan_dung/tex_chan_dung_du_khung.png"

# ---------- F. Màn hình ----------
chep "man_hinh_chinh/f1_nen_man_hinh.png" "man_hinh/tex_nen_man_hinh.png"
chep "man_hinh_chinh/f3_logo_chu_hao_khi_dong_a.png" "man_hinh/tex_logo_hao_khi_dong_a.png"
chep "man_hinh_chinh/f3_badge_logo.png" "man_hinh/tex_badge_logo.png"
chep "man_hinh_chinh/f4_icon_game.png" "man_hinh/tex_icon_game.png"
chep "man_hinh_chinh/f4_icon_256x256.png" "man_hinh/tex_icon_256.png"
chep "chuyen_tran/f2_1_hoi_nghi_binh_than_640x360.png" "man_hinh/tex_chuyen_tran_hoi_nghi_binh_than.png"
chep "chuyen_tran/f2_2_luy_ai_van_kiep_640x360.png" "man_hinh/tex_chuyen_tran_luy_ai_van_kiep.png"
chep "chuyen_tran/f2_3_thuy_chien_bach_dang_640x360.png" "man_hinh/tex_chuyen_tran_thuy_chien_bach_dang.png"

echo "Chép hình xong: $so_moi mới, $so_cap_nhat cập nhật, $so_khong_doi không đổi."
if (( so_loi > 0 )); then
	echo "❌ $so_loi file nguồn bị thiếu (xem các dòng ❌ ở trên)." >&2
	exit 1
fi
