#!/bin/sh

# Set ARG
PLATFORM=$1
TAG=$2
if [ -z "$PLATFORM" ]; then
    ARCH="64"
else
    case "$PLATFORM" in
        linux/386)
            ARCH="32"
            ;;
        linux/amd64)
            ARCH="64"
            ;;
        linux/arm/v6)
            ARCH="arm32-v6"
            ;;
        linux/arm/v7)
            ARCH="arm32-v7a"
            ;;
        linux/arm64|linux/arm64/v8)
            ARCH="arm64-v8a"
            ;;
        *)
            ARCH=""
            ;;
    esac
fi
[ -z "${ARCH}" ] && echo "Error: Not supported OS Architecture" && exit 1

# Download files
XRAY_FILE="Xray-linux-${ARCH}.zip"
DGST_FILE="Xray-linux-${ARCH}.zip.dgst"
echo "Downloading binary file: ${XRAY_FILE}"
echo "Downloading binary file: ${DGST_FILE}"

curl -fsSLo ${PWD}/xray.zip https://github.com/XTLS/Xray-core/releases/download/${TAG}/${XRAY_FILE}
curl -fsSLo ${PWD}/xray.zip.dgst https://github.com/XTLS/Xray-core/releases/download/${TAG}/${DGST_FILE}
curl -fsSLo /usr/local/share/xray/h2y.dat https://raw.githubusercontent.com/ToutyRater/V2Ray-SiteDAT/master/geofiles/h2y.dat

if [ $? -ne 0 ]; then
    echo "Error: Failed to download binary file: ${XRAY_FILE} ${DGST_FILE}" && exit 1
fi
echo "Download binary file: ${XRAY_FILE} ${DGST_FILE} completed"

# Check SHA512
LOCAL=$(openssl dgst -sha512 xray.zip | sed 's/([^)]*)//g')
STR=$(cat xray.zip.dgst | grep 'SHA2-512' | head -n1)

if [ "${LOCAL}" = "${STR}" ]; then
    echo " Check passed" && rm -fv xray.zip.dgst
else
    echo " Check have not passed yet " && exit 1
fi

# Prepare
echo "Prepare to use"
unzip xray.zip && chmod +x xray
mv xray /usr/bin/
mv geosite.dat geoip.dat /usr/local/share/xray/

# Clean
rm -rf ${PWD}/*
echo "Done"
