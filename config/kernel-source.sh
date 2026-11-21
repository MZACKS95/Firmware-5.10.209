
#!/usr/bin/env bash
set -euo pipefail

# ==========================================
# KERNEL SOURCE CONFIGURATION
# ==========================================

KERNEL_URL="https://android.googlesource.com/kernel/common"
KERNEL_COMMIT="7c6bbcca33e1"

KERNEL_DIR="$GITHUB_WORKSPACE/android/kernel/common/$KERNEL_COMMIT"

echo "===== PREPARE GOOGLE KERNEL SOURCE ====="

mkdir -p "$(dirname "$KERNEL_DIR")"

# ==========================================
# CLONE OR REUSE SOURCE
# ==========================================

if [ ! -d "$KERNEL_DIR/.git" ]; then

    echo "===== CLONE GOOGLE KERNEL ====="

    git clone "$KERNEL_URL" "$KERNEL_DIR"

else

    echo "===== REUSE EXISTING KERNEL SOURCE ====="

    git -C "$KERNEL_DIR" remote set-url origin "$KERNEL_URL"

fi

# ==========================================
# FETCH REQUIRED COMMIT
# ==========================================

cd "$KERNEL_DIR"

if ! git cat-file -e "${KERNEL_COMMIT}^{commit}" 2>/dev/null; then

    echo "===== FETCH REQUIRED COMMIT ====="

    git fetch --depth=1 origin "$KERNEL_COMMIT"

fi

# ==========================================
# CHECKOUT
# ==========================================

git checkout --detach "$KERNEL_COMMIT"

# ==========================================
# VERIFY COMMIT
# ==========================================

ACTUAL_COMMIT=$(git rev-parse HEAD)

echo "Expected: $KERNEL_COMMIT"
echo "Actual:   $ACTUAL_COMMIT"

if [ "${ACTUAL_COMMIT:0:12}" != "$KERNEL_COMMIT" ]; then
    echo "ERROR: Kernel commit mismatch"
    exit 1
fi

# ==========================================
# VERIFY SOURCE
# ==========================================

test -f Makefile
test -d drivers
test -d include

echo "===== KERNEL SOURCE READY ====="

git log -1 --oneline
