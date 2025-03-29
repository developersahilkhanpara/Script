
#!/bin/bash

# Function to clone repositories if not already present
clone_repo() {
  local repo_url=$1
  local dest_dir=$2
  local branch=$3
  if [ -d "$dest_dir" ]; then
    echo "Directory $dest_dir exists, removing it first..."
    rm -rf "$dest_dir"
  fi
  git clone "$repo_url" -b "$branch" "$dest_dir" || { echo "Failed to clone $repo_url"; exit 1; }
  echo "Cloned $repo_url into $dest_dir"
}

# Remove Unnecessary Files
echo "===================================="
echo "     Removing Unnecessary Files"
echo "===================================="

dirs_to_remove=(
  "vendor/xaga"
  "kernel/xaga"
  "device/xaga"
  "device/xaga/mt6895-common"
  "vendor/xaga/mt6895-common"
  "hardware/xaga"
  "prebuilts/clang/host/linux-x86/clang-rastamod"
  "out/target/product/*/*zip"
  "out/target/product/*/*txt"
  "out/target/product/*/boot.img"
  "out/target/product/*/recovery.img"
  "out/target/product/*/super*img"
  ".repo/local_manifests/"
)

for dir in "${dirs_to_remove[@]}"; do
  [ -e "$dir" ] && rm -rf "$dir"
done

echo "===================================="
echo "  Removing Unnecessary Files Done"
echo "===================================="

# Initialize repo
echo "=============================================="
echo "         Cloning Manifest..........."
echo "=============================================="
if ! repo init -u https://github.com/AxionAOSP/android.git -b lineage-22.2 --git-lfs; then
  echo "Repo initialization failed. Exiting."
  exit 1
fi
echo "=============================================="
echo "       Manifest Cloned successfully"
echo "=============================================="

# Sync
if ! /opt/crave/resync.sh || ! repo sync -j$(nproc --all); then
  echo "Repo sync failed. Exiting."
  exit 1
fi
echo "============="
echo " Sync success"
echo "============="

# Clone device trees and other dependencies
echo "=============================================="
echo "       Cloning Trees..........."
echo "=============================================="

clone_repo "https://github.com/XagaForge/android_device_xiaomi_xaga.git" "device/xiaomi/xaga" "15"
clone_repo "https://github.com/XagaForge/android_device_xiaomi_mt6895-common.git" "device/xiaomi/mt6895-common" "15"
clone_repo "https://github.com/XagaForge/android_kernel_xiaomi_mt6895.git" "kernel/xiaomi/mt6895" "15"
clone_repo "https://gitlab.com/priiii08918/android_vendor_xiaomi_xaga.git" "vendor/xiaomi/xaga" "15"
clone_repo "https://github.com/XagaForge/android_vendor_xiaomi_mt6895-common.git" "vendor/xiaomi/mt6895-common" "15"
clone_repo "https://github.com/XagaForge/android_vendor_firmware.git" "vendor/firmware" "15"
clone_repo "https://gitlab.com/priiii08918/proprietary_vendor_xiaomi_miuicamera-xaga.git" "vendor/xiaomi/miuicamera-xaga" "15"
clone_repo "https://github.com/xiaomi-mediatek-devs/android_hardware_mediatek.git" "hardware/mediatek" "lineage-22.2"
clone_repo "https://github.com/xiaomi-mt6895-devs/android_hardware_xiaomi.git" "hardware/xiaomi" "lineage-22.2"
clone_repo "https://github.com/xiaomi-mediatek-devs/android_device_mediatek_sepolicy_vndr.git" "device/mediatek/sepolicy_vndr" "lineage-22.2"

# Resync (again)
/opt/crave/resync.sh

# Export Environment Variables
echo "======= Exporting........ ======"
export BUILD_USERNAME=Sahil
export BUILD_HOSTNAME=crave
export TARGET_DISABLE_EPPE=true
export TZ=Asia/Dhaka
export ALLOW_MISSING_DEPENDENCIES=true
echo "======= Export Done ======"

# Set up build environment
echo "====== Starting Envsetup ======="
source build/envsetup.sh || { echo "Envsetup failed"; exit 1; }
echo "====== Envsetup Done ======="

# Build ROM
echo "===================================="
echo "        Build Infinity.."
echo "===================================="
gk -s
axion xaga user gms core
ax -b -j$(nproc --all) user
