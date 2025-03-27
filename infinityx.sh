#!/bin/bash
# crave run --no-patch -- "curl https://raw.githubusercontent.com/Zekerian/Android-Scripts/refs/heads/InfinityX/LOSP.sh | bash"

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
if ! repo init --depth=1 --no-repo-verify --git-lfs -u https://github.com/ProjectInfinity-X/manifest -b 15-QPR2 -g default,-mips,-darwin,-notdefault; then
  echo "Repo initialization failed. Exiting."
  exit 1
fi
echo "=============================================="
echo "       Manifest Cloned successfully"
echo "=============================================="
# Sync
if ! /opt/crave/resync.sh || ! repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j$(nproc --all); then
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
git clone https://github.com/developersahilkhanpara/android_device_xiaomi_xaga.git -b 15 device/xiaomi/xaga || { echo "Failed to clone device tree"; exit 1; }

git clone https://github.com/XagaForge/android_device_xiaomi_mt6895-common.git -b 15 device/xiaomi/mt6895-common || { echo "Failed to clone common device tree"; exit 1; }

git clone https://github.com/XagaForge/android_kernel_xiaomi_mt6895.git -b 15 kernel/xiaomi/mt6895 || { echo "Failed to clone kernel"; exit 1; }

git clone https://gitlab.com/priiii08918/android_vendor_xiaomi_xaga.git -b 15 vendor/xiaomi/xaga || { echo "Failed to clone vendor miami"; exit 1; }

git clone https://github.com/XagaForge/android_vendor_xiaomi_mt6895-common.git -b 15 vendor/xiaomi/mt6895-common || { echo "Failed to clone common vendor miami"; exit 1; }

git clone https://github.com/XagaForge/android_vendor_firmware.git -b 15 vendor/firmware || { echo "Failed to clone vendor firmware"; exit 1; }

git clone https://gitlab.com/priiii08918/proprietary_vendor_xiaomi_miuicamera-xaga.git -b 15 vendor/xiaomi/miuicamera-xaga || { echo "Failed to clone miuicamera-xaga"; exit 1; }

git clone https://github.com/xiaomi-mediatek-devs/android_hardware_mediatek.git hardware/mediatek || { echo "Failed to clone hardware mediatek"; exit 1; }

# git clone https://github.com/xiaomi-mediatek-devs/android_hardware_xiaomi.git hardware/xiaomi || { echo "Failed to clone hardware xiaomi"; exit 1; }

git clone https://github.com/xiaomi-mediatek-devs/android_device_mediatek_sepolicy_vndr.git device/mediatek/sepolicy_vndr || { echo "Failed to clone sepolicy_vndr"; exit 1; }

git clone https://gitlab.com/kutemeikito/rastamod69-clang prebuilts/clang/host/linux-x86/clang-rastamod || { echo "Failed to clone prebuilts clang-rastamod"; exit 1; }

# croot && git clone https://github.com/ProjectInfinity-X/vendor_infinity-priv_keys-template vendor/infinity-priv/keys || { echo "Failed to sign"; exit 1;}

# cd vendor/infinity-priv/keys && chmod +x keys.sh

# ./keys.sh && cd ../../../

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
lunch infinity_xaga-user
mka bacon
