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
# Tự kiểm công cụ trên file mẫu: bộ vi phạm phải thoát mã 1 và mỗi file phải bị bắt
# đúng lý do ghi ở dòng "# mong_doi: <lý do>" của nó; bộ hợp lệ phải đạt.
ma_mau=0
ra_mau="$("$REPO_ROOT/tools/check_boundaries.sh" "$MAU/vi_pham" 2>&1)" || ma_mau=$?
mau_hong=()
(( ma_mau == 1 )) || mau_hong+=("vi_pham/ thoát mã $ma_mau, phải là 1")
so_mau=0
while IFS= read -r f; do
	so_mau=$((so_mau + 1))
	ten="${f#"$MAU"/}"
	so_mong_doi=0
	while IFS= read -r ly_do; do
		so_mong_doi=$((so_mong_doi + 1))
		# Không dùng grep -q: grep thoát sớm làm grep trước nhận SIGPIPE, pipefail báo sai.
		grep -F "$ten:" <<<"$ra_mau" | grep -F ": $ly_do" >/dev/null \
			|| mau_hong+=("$ten không bị bắt với lý do \"$ly_do\"")
	done < <(sed -nE 's/^#[[:space:]]*mong_doi:[[:space:]]*//p' "$f")
	(( so_mong_doi > 0 )) || mau_hong+=("$ten thiếu dòng \"# mong_doi: <lý do>\"")
done < <(find "$MAU/vi_pham" -type f -name '*.gd' | sort)
(( so_mau > 0 )) || mau_hong+=("vi_pham/ không có file mẫu nào")
"$REPO_ROOT/tools/check_boundaries.sh" "$MAU/hop_le" >/dev/null 2>&1 || mau_hong+=("hop_le/ bị báo vi phạm")
if (( ${#mau_hong[@]} > 0 )); then
	buoc1_dat=0
	chi_tiet_1+=("  ❌ công cụ kiểm ranh giới bị hỏng (tools/mau_ranh_gioi không cho kết quả đúng):")
	for dong in "${mau_hong[@]}"; do
		chi_tiet_1+=("     $dong")
	done
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
		# Không dùng grep -q: với file lớn, git show nhận SIGPIPE và pipefail làm bỏ sót file khóa.
		git -C "$REPO_ROOT" show "HEAD:$f" 2>/dev/null \
			| grep -E '"da_duyet"[[:space:]]*:[[:space:]]*true' >/dev/null || continue
		so_khoa=$((so_khoa + 1))
		if ! git -C "$REPO_ROOT" diff --quiet HEAD -- "$f"; then
			chi_tiet_2+=("  ❌ $f: kịch bản đã duyệt bị sửa so với commit gần nhất")
			so_bi_sua=$((so_bi_sua + 1))
		fi
	done < <(git -C "$REPO_ROOT" -c core.quotePath=false ls-tree -r --name-only HEAD -- game | grep '\.json$' || true)
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
IMPORT_LOG="$KET_QUA_DIR/import.log"
LOI_SCRIPT='SCRIPT ERROR|Parse Error'
ma_quet=0
"$GODOT" --headless --path "$GAME" --import >"$IMPORT_LOG" 2>&1 || ma_quet=$?
# Repo mới clone: lần quét đầu Godot nạp Theme trước khi quét xong font nên báo lỗi oan.
# Có lỗi thì quét lại một lần; lỗi thật trong script vẫn còn ở lần hai.
if (( ma_quet == 0 )) && grep -qE "$LOI_SCRIPT" "$IMPORT_LOG"; then
	"$GODOT" --headless --path "$GAME" --import >"$IMPORT_LOG" 2>&1 || ma_quet=$?
fi
if (( ma_quet == 0 )); then
	# Chống xanh giả: script game lỗi cú pháp thì --import vẫn thoát mã 0, chỉ ghi vào log.
	if grep -qE "$LOI_SCRIPT" "$IMPORT_LOG"; then
		ghi_buoc 3 "Quét project" "trượt"
		bao_cao+=("  ❌ có script game lỗi (xem build/test/import.log):")
		while IFS= read -r dong; do
			bao_cao+=("     $dong")
		done < <(grep -A1 -E "$LOI_SCRIPT" "$IMPORT_LOG" | grep -vE '^--$' | head -10)
		ly_do_truot+=("có script game lỗi")
	else
		ghi_buoc 3 "Quét project" "đạt"
	fi
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

		# Chống xanh giả: test không có assert nào thì GUT không tính là trượt.
		so_khong_assert=0
		while IFS=$'\t' read -r ten_file ten_test; do
			chi_tiet_4+=("  ❌ $ten_file › $ten_test: không có assert nào")
			so_khong_assert=$((so_khong_assert + 1))
		done < <(awk '
			/<testcase / && /status="no asserts"/ {
				match($0, / name="[^"]*"/); ten = substr($0, RSTART + 7, RLENGTH - 8)
				match($0, /classname="[^"]*"/); lop = substr($0, RSTART + 11, RLENGTH - 12)
				printf "%s\t%s\n", lop, ten
			}
		' "$GUT_XML")
		(( so_khong_assert == 0 )) || ly_do_truot+=("$so_khong_assert test không có assert")

		# Chống xanh giả: GUT bỏ qua file lỗi cú pháp mà vẫn thoát mã 0. Lỗi khi chạy cũng ghi SCRIPT ERROR.
		if grep -qE 'SCRIPT ERROR|Parse Error' "$GUT_LOG"; then
			chi_tiet_4+=("  ❌ có lỗi script khi chạy test (file lỗi cú pháp thì GUT đã bỏ qua nó):")
			while IFS= read -r dong; do
				chi_tiet_4+=("     $dong")
			done < <(grep -A1 -E 'SCRIPT ERROR|Parse Error' "$GUT_LOG" | grep -vE '^--$' | head -10)
			ly_do_truot+=("có lỗi script khi chạy test")
		fi
		so_file_test=0
		if [[ -d "$GAME/tests" ]]; then
			so_file_test="$(find "$GAME/tests" -type f -name 'test_*.gd' | wc -l | tr -d ' ')"
		fi
		# GUT ghi một <testsuite> cho mỗi inner class ("tests/x.gd.TenLop"): đếm theo file .gd.
		so_file_chay="$(awk '
			match($0, /<testsuite name="[^"]*\.gd/) {
				k = substr($0, RSTART, RLENGTH)
				if (!(k in da_gap)) { da_gap[k] = 1; n++ }
			}
			END { print n + 0 }
		' "$GUT_XML")"
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
