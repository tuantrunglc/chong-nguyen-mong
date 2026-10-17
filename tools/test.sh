#!/usr/bin/env bash
# Một lệnh chạy toàn bộ test. Ví dụ: tools/test.sh
# Bốn bước: kiểm ranh giới, kiểm kịch bản đã duyệt, quét project, chạy test GUT.
# Bước nào trượt thì các bước sau vẫn chạy. Mã thoát 0 là đạt, 1 là trượt.
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/_godot.sh"

GAME="$REPO_ROOT/game"
KET_QUA_DIR="$REPO_ROOT/build/test"
GUT_LOG="$KET_QUA_DIR/gut.log"
GUT_XML="$KET_QUA_DIR/ket_qua.xml"
MAU="$REPO_ROOT/tools/mau_ranh_gioi"
mkdir -p "$KET_QUA_DIR"

ly_do_truot=()   # lý do trượt cho dòng tóm tắt cuối
bao_cao=()       # các dòng [n/4] in ra cuối

# Ghi một dòng kết quả cho bước. Tham số: số bước, tên bước, kết quả.
ghi_buoc() {
	bao_cao+=("[$1/4] $2: $3")
}

# ---------- Bước 1: kiểm ranh giới ----------
chi_tiet_1=()
buoc1_dat=1
# Tự kiểm công cụ trên file mẫu: mỗi file vi phạm phải bị bắt, bộ hợp lệ phải đạt.
ra_mau="$("$REPO_ROOT/tools/check_boundaries.sh" "$MAU/vi_pham" 2>&1 || true)"
cong_cu_hong=0
while IFS= read -r f; do
	grep -qF "${f#"$MAU"/}:" <<<"$ra_mau" || cong_cu_hong=1
done < <(find "$MAU/vi_pham" -type f -name '*.gd')
"$REPO_ROOT/tools/check_boundaries.sh" "$MAU/hop_le" >/dev/null 2>&1 || cong_cu_hong=1
if (( cong_cu_hong )); then
	buoc1_dat=0
	chi_tiet_1+=("  ❌ công cụ kiểm ranh giới bị hỏng (tools/mau_ranh_gioi không cho kết quả đúng)")
	ly_do_truot+=("công cụ kiểm ranh giới bị hỏng")
fi
ma=0
ra_that="$("$REPO_ROOT/tools/check_boundaries.sh" 2>&1)" || ma=$?
if (( ma != 0 )); then
	buoc1_dat=0
	so=0
	while IFS= read -r dong; do
		[[ "$dong" == ❌* ]] || continue
		chi_tiet_1+=("  $dong")
		so=$((so + 1))
	done <<<"$ra_that"
	(( so > 0 )) || chi_tiet_1+=("  ❌ $ra_that")
	ly_do_truot+=("$so lỗi ranh giới")
fi
if (( buoc1_dat )); then ghi_buoc 1 "Kiểm ranh giới" "đạt"; else ghi_buoc 1 "Kiểm ranh giới" "trượt"; fi
bao_cao+=("${chi_tiet_1[@]+"${chi_tiet_1[@]}"}")

# ---------- Bước 2: khóa da_duyet ----------
# File JSON trong game/ mà ở commit gần nhất có "da_duyet": true thì không được khác commit đó.
chi_tiet_2=()
if ! command -v git >/dev/null 2>&1 || ! git -C "$REPO_ROOT" rev-parse --verify -q HEAD >/dev/null 2>&1; then
	ghi_buoc 2 "Kịch bản đã duyệt" "trượt"
	chi_tiet_2+=("  ❌ không kiểm được khóa da_duyet (không có git hoặc chưa có commit nào)")
	ly_do_truot+=("không kiểm được khóa da_duyet")
else
	so_khoa=0
	so_bi_sua=0
	while IFS= read -r f; do
		git -C "$REPO_ROOT" show "HEAD:$f" 2>/dev/null \
			| grep -qE '"da_duyet"[[:space:]]*:[[:space:]]*true' || continue
		so_khoa=$((so_khoa + 1))
		if ! git -C "$REPO_ROOT" diff --quiet HEAD -- "$f"; then
			chi_tiet_2+=("  ❌ $f: kịch bản đã duyệt bị sửa so với commit gần nhất")
			so_bi_sua=$((so_bi_sua + 1))
		fi
	done < <(git -C "$REPO_ROOT" ls-tree -r --name-only HEAD -- game | grep '\.json$' || true)
	if (( so_bi_sua > 0 )); then
		ghi_buoc 2 "Kịch bản đã duyệt" "trượt"
		ly_do_truot+=("$so_bi_sua kịch bản đã duyệt bị sửa")
	else
		ghi_buoc 2 "Kịch bản đã duyệt" "đạt ($so_khoa file)"
	fi
fi
bao_cao+=("${chi_tiet_2[@]+"${chi_tiet_2[@]}"}")

# ---------- Bước 3: quét project ----------
# game/.godot/ không có trong git: phải quét trước, nếu không GUT thoát mã 0 mà không chạy test nào.
da_quet=1
if "$GODOT" --headless --path "$GAME" --import >"$KET_QUA_DIR/import.log" 2>&1; then
	ghi_buoc 3 "Quét project" "đạt"
else
	da_quet=0
	ghi_buoc 3 "Quét project" "trượt"
	bao_cao+=("  ❌ không quét được project (xem build/test/import.log)")
	ly_do_truot+=("không quét được project")
fi

# ---------- Bước 4: chạy test GUT ----------
chi_tiet_4=()
tong=0
so_truot=0
if (( ! da_quet )); then
	ghi_buoc 4 "Test GUT" "bỏ qua (chưa quét được project)"
else
	rm -f "$GUT_XML"
	ma_gut=0
	"$GODOT" --headless --path "$GAME" -s res://addons/gut/gut_cmdln.gd \
		-gdir=res://tests -ginclude_subdirs -gexit "-gjunit_xml_file=$GUT_XML" \
		>"$GUT_LOG" 2>&1 || ma_gut=$?

	if [[ ! -f "$GUT_XML" ]]; then
		chi_tiet_4+=("  ❌ GUT không chạy xong (xem build/test/gut.log)")
		ly_do_truot+=("GUT không chạy xong")
	else
		goc="$(grep -m1 '<testsuites' "$GUT_XML" || true)"
		tong="$(sed -nE 's/.* tests="([0-9]+)".*/\1/p' <<<"$goc")"
		so_truot="$(sed -nE 's/.* failures="([0-9]+)".*/\1/p' <<<"$goc")"
		tong="${tong:-0}"
		so_truot="${so_truot:-0}"

		# Từng test trượt: tên file › tên test, kèm dòng đầu của thông điệp lỗi.
		while IFS=$'\t' read -r ten_file ten_test thong_diep; do
			chi_tiet_4+=("  ❌ $ten_file › $ten_test")
			[[ -n "$thong_diep" ]] && chi_tiet_4+=("     $thong_diep")
		done < <(awk '
			/<testcase / && /status="fail"/ {
				match($0, /name="[^"]*"/); ten = substr($0, RSTART + 6, RLENGTH - 7)
				match($0, /classname="[^"]*"/); lop = substr($0, RSTART + 11, RLENGTH - 12)
				cho = 1; next
			}
			cho && /CDATA\[/ {
				s = $0; sub(/.*CDATA\[/, "", s); sub(/\]\]>.*/, "", s)
				printf "%s\t%s\t%s\n", lop, ten, s; cho = 0
			}
		' "$GUT_XML")
		if (( so_truot > 0 )); then
			ly_do_truot+=("$so_truot test trượt")
		fi

		# Chống xanh giả: GUT bỏ qua file lỗi cú pháp mà vẫn thoát mã 0.
		if grep -qE 'SCRIPT ERROR|Parse Error' "$GUT_LOG"; then
			chi_tiet_4+=("  ❌ có file lỗi cú pháp, GUT đã bỏ qua nó:")
			while IFS= read -r dong; do
				chi_tiet_4+=("     $dong")
			done < <(grep -A1 -E 'SCRIPT ERROR|Parse Error' "$GUT_LOG" | grep -vE '^--$' | head -10)
			ly_do_truot+=("có file test lỗi cú pháp")
		fi
		so_file_test=0
		if [[ -d "$GAME/tests" ]]; then
			so_file_test="$(find "$GAME/tests" -type f -name 'test_*.gd' | wc -l | tr -d ' ')"
		fi
		so_file_chay="$(grep -c '<testsuite ' "$GUT_XML" || true)"
		if (( so_file_test != so_file_chay )); then
			chi_tiet_4+=("  ❌ có file test không được chạy ($so_file_chay/$so_file_test file)")
			ly_do_truot+=("có file test không được chạy")
		fi
		if (( tong == 0 )); then
			chi_tiet_4+=("  ❌ không có test nào được chạy")
			ly_do_truot+=("không có test nào được chạy")
		fi
		if (( ma_gut != 0 && so_truot == 0 )); then
			chi_tiet_4+=("  ❌ GUT thoát mã $ma_gut (xem build/test/gut.log)")
			ly_do_truot+=("GUT thoát mã $ma_gut")
		fi
	fi

	if (( ${#chi_tiet_4[@]} == 0 )); then
		ghi_buoc 4 "Test GUT" "$tong/$tong đạt"
	elif (( so_truot > 0 )); then
		ghi_buoc 4 "Test GUT" "$so_truot/$tong trượt"
	else
		ghi_buoc 4 "Test GUT" "trượt"
	fi
	bao_cao+=("${chi_tiet_4[@]+"${chi_tiet_4[@]}"}")
fi

# ---------- Tóm tắt ----------
for dong in "${bao_cao[@]}"; do
	[[ -n "$dong" ]] && echo "$dong"
done
echo
if (( ${#ly_do_truot[@]} == 0 )); then
	echo "✅ $tong/$tong test đạt"
	exit 0
fi
tom_tat="$(printf '%s, ' "${ly_do_truot[@]}")"
echo "❌ trượt: ${tom_tat%, }"
(( ${#chi_tiet_4[@]} == 0 )) || echo "   Chi tiết: build/test/gut.log"
exit 1
