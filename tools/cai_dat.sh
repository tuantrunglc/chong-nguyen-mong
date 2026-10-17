#!/usr/bin/env bash
# Cài Godot 4.7.2 và export template vào .tools/ trong repo. Chạy lại khi đã cài thì không tải lại.
set -euo pipefail

GODOT_BO_QUA_KIEM_TRA=1
source "$(dirname "${BASH_SOURCE[0]}")/_godot.sh"

if [[ -f "$GODOT_DIR/.installed" && -x "$GODOT" ]]; then
	echo "Đã cài Godot 4.7.2"
	exit 0
fi

BASE_URL="https://github.com/godotengine/godot/releases/download/$GODOT_VERSION"
case "$GODOT_OS" in
	macos) FILE_GODOT="Godot_v${GODOT_VERSION}_macos.universal.zip" ;;
	linux) FILE_GODOT="Godot_v${GODOT_VERSION}_linux.x86_64.zip" ;;
esac
FILE_TEMPLATE="Godot_v${GODOT_VERSION}_export_templates.tpz"
FILE_SUMS="SHA512-SUMS.txt"

if command -v sha512sum >/dev/null 2>&1; then
	sha512() { sha512sum "$1" | awk '{print $1}'; }
else
	sha512() { shasum -a 512 "$1" | awk '{print $1}'; }
fi

TAI_VE="$REPO_ROOT/.tools/tai_ve"
mkdir -p "$TAI_VE"

tai() {
	local ten="$1"
	echo "Đang tải $ten ..."
	# Giữ file .tmp khi lỗi để lần chạy sau tải tiếp phần còn dở (-C -), không tải lại từ đầu.
	if ! curl -fL --progress-bar --connect-timeout 30 --retry 5 --retry-delay 5 -C - \
		-o "$TAI_VE/$ten.tmp" "$BASE_URL/$ten"; then
		echo "Lỗi: không tải được $ten. Kiểm tra mạng rồi chạy lại (sẽ tải tiếp phần còn dở)." >&2
		exit 1
	fi
	mv "$TAI_VE/$ten.tmp" "$TAI_VE/$ten"
}

kiem_tra() {
	local ten="$1"
	local mong_doi
	mong_doi="$(awk -v f="$ten" '$2 == f {print $1}' "$TAI_VE/$FILE_SUMS")"
	if [[ -z "$mong_doi" ]]; then
		rm -f "$TAI_VE/$ten"
		echo "Lỗi: không thấy mã kiểm tra của $ten trong $FILE_SUMS." >&2
		exit 1
	fi
	if [[ "$(sha512 "$TAI_VE/$ten")" != "$mong_doi" ]]; then
		rm -f "$TAI_VE/$ten"
		echo "Lỗi: file $ten tải về bị hỏng (sai mã SHA-512). Đã xóa, hãy chạy lại." >&2
		exit 1
	fi
	echo "Đã kiểm tra mã SHA-512: $ten khớp."
}

# Luôn tải lại danh sách mã kiểm tra; file lớn đã tải đúng thì dùng lại.
tai "$FILE_SUMS"
for ten in "$FILE_GODOT" "$FILE_TEMPLATE"; do
	if [[ -f "$TAI_VE/$ten" ]]; then
		echo "Đã có $ten, kiểm tra lại."
	else
		tai "$ten"
	fi
	kiem_tra "$ten"
done

echo "Đang giải nén Godot ..."
rm -rf "$GODOT_DIR"
mkdir -p "$GODOT_DIR"
unzip -q "$TAI_VE/$FILE_GODOT" -d "$GODOT_DIR"
chmod +x "$GODOT"

if [[ "$GODOT_OS" == "macos" ]]; then
	xattr -dr com.apple.quarantine "$GODOT_DIR/Godot.app" 2>/dev/null || true
fi

# Bật chế độ tự chứa: có file ._sc_ cạnh file chạy thì Godot ghi dữ liệu vào editor_data/ cạnh đó.
touch "$(dirname "$GODOT")/._sc_"

echo "Đang cài export template ..."
THU_MUC_TEMPLATE="$GODOT_DATA_DIR/export_templates/4.7.2.stable"
TAM="$TAI_VE/template_tam"
rm -rf "$TAM" "$THU_MUC_TEMPLATE"
mkdir -p "$TAM" "$THU_MUC_TEMPLATE"
unzip -q "$TAI_VE/$FILE_TEMPLATE" -d "$TAM"
mv "$TAM"/templates/* "$THU_MUC_TEMPLATE/"
rm -rf "$TAM"

# butler: thêm ở Story 0.5

touch "$GODOT_DIR/.installed"
rm -rf "$TAI_VE"
echo "Đã cài xong Godot 4.7.2 vào .tools/godot-4.7.2"
