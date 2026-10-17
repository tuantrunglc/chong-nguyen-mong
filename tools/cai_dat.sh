#!/usr/bin/env bash
# Cài Godot 4.7.2, export template, butler (đẩy bản web lên itch.io) và công cụ AI (GoPeak, Context7)
# vào .tools/ trong repo.
# Chạy lại khi đã cài thì không tải lại.
set -euo pipefail

GODOT_BO_QUA_KIEM_TRA=1
source "$(dirname "${BASH_SOURCE[0]}")/_godot.sh"

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

# Tải file về .tools/tai_ve/<tên>. Tham số: tên file, [địa chỉ] (mặc định: bản phát hành Godot).
tai() {
	local ten="$1" url="${2:-$BASE_URL/$1}"
	echo "Đang tải $ten ..."
	# Giữ file .tmp khi lỗi để lần chạy sau tải tiếp phần còn dở (-C -), không tải lại từ đầu.
	if ! curl -fL --progress-bar --connect-timeout 30 --retry 5 --retry-delay 5 -C - \
		-o "$TAI_VE/$ten.tmp" "$url"; then
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

cai_godot() {
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

	touch "$GODOT_DIR/.installed"
	echo "Đã cài xong Godot 4.7.2 vào .tools/godot-4.7.2"
}

# butler: ghim bản 15.32.0. Trang tải (broth.itch.zone) không có file mã kiểm tra, nên SHA-256 ghi ở đây
# (tải và đo ngày 2026-10-17). Nâng bản thì sửa BUTLER_VERSION trong _godot.sh và các mã dưới.
cai_butler() {
	local nen_tang sha
	case "$GODOT_OS-$(uname -m)" in
		macos-arm64) nen_tang="darwin-arm64"; sha="f1c460f08c02686b49f8da74344e5578ece9ea1a8bae1779445b5d98e0a794b3" ;;
		macos-x86_64) nen_tang="darwin-amd64"; sha="a92947c9556c9bfb0cc9bdc3814f342b30e0ee7269efc418658894a916ca9584" ;;
		linux-x86_64) nen_tang="linux-amd64"; sha="2335971394ef6596f95ded0833e85ee28755e13761716ef4c91d6b11f69162f5" ;;
		*)
			echo "Lỗi: chưa có butler cho máy này ($(uname -s) $(uname -m))." >&2
			exit 1
			;;
	esac
	local ten="butler-$BUTLER_VERSION-$nen_tang.zip"
	if [[ ! -f "$TAI_VE/$ten" ]]; then
		tai "$ten" "https://broth.itch.zone/butler/$nen_tang/$BUTLER_VERSION/archive/default"
	fi
	if [[ "$(sha256 "$TAI_VE/$ten")" != "$sha" ]]; then
		rm -f "$TAI_VE/$ten"
		echo "Lỗi: file $ten tải về bị hỏng (sai mã SHA-256). Đã xóa, hãy chạy lại." >&2
		exit 1
	fi
	echo "Đã kiểm tra mã SHA-256: $ten khớp."

	echo "Đang giải nén butler ..."
	rm -rf "$BUTLER_DIR"
	mkdir -p "$BUTLER_DIR"
	unzip -q "$TAI_VE/$ten" -d "$BUTLER_DIR"
	chmod +x "$BUTLER"
	if [[ "$GODOT_OS" == "macos" ]]; then
		xattr -dr com.apple.quarantine "$BUTLER_DIR" 2>/dev/null || true
	fi
	if ! "$BUTLER" --version 2>&1 | grep -q "v$BUTLER_VERSION"; then
		echo "Lỗi: butler không chạy được sau khi cài." >&2
		exit 1
	fi
	touch "$BUTLER_DIR/.installed"
	echo "Đã cài xong butler $BUTLER_VERSION vào .tools/butler-$BUTLER_VERSION"
}

if [[ -f "$GODOT_DIR/.installed" && -x "$GODOT" ]]; then
	echo "Đã cài Godot 4.7.2"
else
	cai_godot
fi

if [[ -f "$BUTLER_DIR/.installed" && -x "$BUTLER" ]]; then
	echo "Đã cài butler $BUTLER_VERSION"
else
	cai_butler
fi

rm -rf "$TAI_VE"

# Công cụ AI (MCP): cài bằng npm ci từ file khóa trong tools/mcp/ (ghim cả thư viện phụ thuộc, kèm SHA-512).
# Đặt sau Godot và butler: thiếu Node.js thì báo lỗi, phần đã cài ở trên vẫn dùng được.
# Context7 4.1.1 đòi Node >= 20.18.1.
kiem_node() {
	local ban=""
	if command -v node >/dev/null 2>&1; then
		ban="$(node -p 'process.versions.node' 2>/dev/null || true)"
	fi
	local chinh phu va
	IFS=. read -r chinh phu va <<< "${ban:-0.0.0}"
	va="${va%%[!0-9]*}"
	if [[ -z "$ban" ]] || (( chinh < 20 || (chinh == 20 && (phu < 18 || (phu == 18 && ${va:-0} < 1))) )); then
		echo "Lỗi: chưa có Node.js 20.18.1 trở lên (cần cho công cụ AI). Cài từ https://nodejs.org rồi chạy lại." >&2
		exit 1
	fi
	if ! command -v npm >/dev/null 2>&1; then
		echo "Lỗi: có Node.js nhưng thiếu npm (cần cho công cụ AI). Cài lại Node.js từ https://nodejs.org rồi chạy lại." >&2
		exit 1
	fi
}

cai_mcp() {
	local khoa="$REPO_ROOT/tools/mcp/package-lock.json"
	local ma
	ma="$(ma_cai_mcp)"
	if [[ -f "$MCP_DIR/.installed" && "$(cat "$MCP_DIR/.installed")" == "$ma" ]]; then
		echo "Đã cài GoPeak $GOPEAK_VERSION và Context7 $CONTEXT7_VERSION"
		return
	fi

	echo "Đang cài công cụ AI (GoPeak $GOPEAK_VERSION, Context7 $CONTEXT7_VERSION) ..."
	rm -rf "$MCP_DIR"
	mkdir -p "$MCP_DIR"
	cp "$REPO_ROOT/tools/mcp/package.json" "$khoa" "$MCP_DIR/"
	# --ignore-scripts: không chạy postinstall của gói nào (GoPeak có postinstall cài hook vào shell).
	if ! npm ci --ignore-scripts --no-audit --no-fund --prefix "$MCP_DIR"; then
		echo "Lỗi: không cài được công cụ AI. Kiểm tra mạng rồi chạy lại." >&2
		exit 1
	fi

	local goi ban_mong_doi file_chay ban
	for goi in gopeak @upstash/context7-mcp; do
		case "$goi" in
			gopeak) ban_mong_doi="$GOPEAK_VERSION"; file_chay="build/cli.js" ;;
			*) ban_mong_doi="$CONTEXT7_VERSION"; file_chay="dist/index.js" ;;
		esac
		if [[ ! -f "$MCP_DIR/node_modules/$goi/$file_chay" ]]; then
			echo "Lỗi: cài xong mà không thấy $goi/$file_chay." >&2
			exit 1
		fi
		ban="$(node -p "require(process.argv[1]).version" "$MCP_DIR/node_modules/$goi/package.json")"
		if [[ "$ban" != "$ban_mong_doi" ]]; then
			echo "Lỗi: $goi cài ra bản $ban, cần đúng $ban_mong_doi." >&2
			exit 1
		fi
	done

	echo "$ma" > "$MCP_DIR/.installed"
	echo "Đã cài GoPeak $GOPEAK_VERSION và Context7 $CONTEXT7_VERSION"
}

kiem_node
cai_mcp
