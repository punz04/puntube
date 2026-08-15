#!/bin/bash
# rebrand.sh - Rebrand Revanced-And-Revanced-Extended-Non-Root -> Puntube (by punz04)
# Chạy trong thư mục gốc của repo đã clone (ví dụ: ~/Documents/puntube)
set -e

if [ ! -f "README.md" ] || [ ! -d "src" ]; then
	echo "[-] Không thấy README.md hoặc thư mục src/. Hãy cd vào thư mục repo trước khi chạy."
	exit 1
fi

echo "[+] 1. Tạo keystore riêng punz04.keystore"
if [ -f "src/punz04.keystore" ]; then
	echo "    -> src/punz04.keystore đã tồn tại, bỏ qua."
else
	keytool -genkey -v -keystore src/punz04.keystore \
		-alias punz04 -keyalg RSA -keysize 2048 -validity 10000 \
		-dname "CN=punz04, OU=Puntube, O=punz04, L=Toyohashi, ST=Aichi, C=JP" \
		-storepass punz04123 -keypass punz04123
fi

echo "[+] 2. Cập nhật src/build/utils.sh trỏ sang keystore mới"
# macOS dùng sed -i '' (BSD sed)
sed -i '' 's#--keystore=./src/morphe\.keystore#--keystore=./src/punz04.keystore#g' src/build/utils.sh
sed -i '' 's#-k \./src/fiorenmas\.ks "fiorenmas" "morphe" "fiorenmas"#-k ./src/punz04.keystore "punz04123" "punz04" "punz04123"#g' src/build/utils.sh

echo "[+] 3. Đổi text branding trong README.md và docs/"
find . -type f \( -name "*.md" \) -not -path "./.git/*" | while read -r f; do
	sed -i '' \
		-e 's/FiorenMas/punz04/g' \
		-e 's/Morphe/Puntube/g' \
		-e 's/morphe/puntube/g' \
		"$f"
done

echo "[+] 4. Đổi tên job/workflow trong .github/workflows/*.yml (chỉ phần 'name:' hiển thị, KHÔNG đổi tên file script .sh gọi bên trong)"
for f in .github/workflows/*.yml; do
	sed -i '' \
		-e 's/FiorenMas/punz04/g' \
		"$f"
done

echo "[+] 5. Thêm Custom branding option (đổi tên app hiển thị + icon) cho YouTube/YouTube Music"
add_branding() {
	local dir="src/patches/$1"
	local line='Custom branding|-OappName="Puntube" -OiconPath=Puntube*Logo'
	if [ -d "$dir" ]; then
		if ! grep -qF "Custom branding" "$dir/include-patches" 2>/dev/null; then
			echo "$line" >> "$dir/include-patches"
			echo "    -> Đã thêm vào $dir/include-patches"
		else
			echo "    -> $dir/include-patches đã có Custom branding, bỏ qua."
		fi
	fi
}
add_branding "youtube-morphe"
add_branding "youtube-music-morphe"

echo ""
echo "[✓] Rebrand xong. Kiểm tra lại thay đổi:"
echo "    git status"
echo "    git diff --stat"
echo ""
echo "[!] Lưu ý QUAN TRỌNG:"
echo "  - Icon 'Puntube*Logo' hiện CHƯA có file thật -> patch Custom branding có thể lỗi/không load icon."
echo "    Cần chuẩn bị icon riêng và trỏ đúng path (xem hướng dẫn bước tiếp theo)."
echo "  - src/morphe.keystore, src/fiorenmas.ks, src/ks.keystore, src/_ks.keystore của tác giả gốc"
echo "    VẪN CÒN trong repo (không xoá tự động để tránh vỡ script khác đang tham chiếu)."
echo "    Sau khi confirm build ổn, tự tay xoá các file này nếu không cần."
echo "  - keystore password đang set cứng là 'punz04123' trong script này, nên đổi lại cho an toàn."
