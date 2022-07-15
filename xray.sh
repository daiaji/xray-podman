#!/bin/sh

if [[ "$(uname)" == 'Linux' ]]; then
  case "$(uname -m)" in
    'i386' | 'i686')
      ARCH='32'
      ;;
    'amd64' | 'x86_64')
      ARCH='64'
      ;;
    'armv5tel')
      ARCH='arm32-v5'
      ;;
    'armv6l')
      ARCH='arm32-v6'
      ;;
    'armv7' | 'armv7l')
      ARCH='arm32-v7a'
      ;;
    'armv8' | 'aarch64')
      ARCH='arm64-v8a'
      ;;
    'mips')
      ARCH='mips32'
      ;;
    'mipsle')
      ARCH='mips32le'
      ;;
    'mips64')
      ARCH='mips64'
      ;;
    'mips64le')
      ARCH='mips64le'
      ;;
    'ppc64')
      ARCH='ppc64'
      ;;
    'ppc64le')
      ARCH='ppc64le'
      ;;
    'riscv64')
      ARCH='riscv64'
      ;;
    's390x')
      ARCH='s390x'
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
TMP_DIRECTORY="$(mktemp -d)"
XRAY_PATH="${TMP_DIRECTORY}/${XRAY_FILE}"
DGST_PATH="${TMP_DIRECTORY}/${DGST_FILE}"
echo "Downloading binary file: ${XRAY_FILE}"
echo "Downloading binary file: ${DGST_FILE}"

curl -fsSLo ${XRAY_PATH} https://github.com/XTLS/Xray-core/releases/latest/download/${XRAY_FILE}
curl -fsSLo ${DGST_PATH} https://github.com/XTLS/Xray-core/releases/latest/download/${DGST_FILE}

if [ $? -ne 0 ]; then
    echo "Error: Failed to download binary file: ${XRAY_FILE} ${DGST_FILE}" && exit 1
fi
echo "Download binary file: ${XRAY_FILE} ${DGST_FILE} completed"

# Check SHA512
LOCAL=$(openssl dgst -sha512 ${XRAY_PATH} | sed 's/([^)]*)//g')
STR=$(cat ${DGST_PATH} | grep 'SHA512' | head -n1)

if [ "${LOCAL}" = "${STR}" ]; then
    echo " Check passed" && rm -fv ${DGST_PATH}
else
    echo " Check have not passed yet " && exit 1
fi

# Prepare
echo "Prepare to use"
unzip ${XRAY_PATH} -d ${TMP_DIRECTORY} && cd ${TMP_DIRECTORY} && chmod +x xray && mkdir /usr/local/share/xray
mv xray /usr/bin/
mv geosite.dat geoip.dat /usr/local/share/xray/

# Clean
rm -rf ${TMP_DIRECTORY}
echo "Done"
