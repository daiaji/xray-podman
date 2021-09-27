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
V2RAY_FILE="v2ray-linux-${ARCH}.zip"
DGST_FILE="v2ray-linux-${ARCH}.zip.dgst"
TMP_DIRECTORY="$(mktemp -d)"
V2RAY_PATH="${TMP_DIRECTORY}/${V2RAY_FILE}"
DGST_PATH="${TMP_DIRECTORY}/${DGST_FILE}"
echo "Downloading binary file: ${V2RAY_FILE}"
echo "Downloading binary file: ${DGST_FILE}"

curl -fsSLo ${V2RAY_PATH} https://github.com/v2fly/v2ray-core/releases/latest/download/${V2RAY_FILE}
curl -fsSLo ${DGST_PATH} https://github.com/v2fly/v2ray-core/releases/latest/download/${DGST_FILE}

if [ $? -ne 0 ]; then
    echo "Error: Failed to download binary file: ${V2RAY_FILE} ${DGST_FILE}" && exit 1
fi
echo "Download binary file: ${V2RAY_FILE} ${DGST_FILE} completed"

# Check SHA512
LOCAL=$(openssl dgst -sha512 ${V2RAY_PATH} | sed 's/([^)]*)//g')
STR=$(cat ${DGST_PATH} | grep 'SHA512' | head -n1)

if [ "${LOCAL}" = "${STR}" ]; then
    echo " Check passed" && rm -fv ${DGST_PATH}
else
    echo " Check have not passed yet " && exit 1
fi

# Prepare
echo "Prepare to use"
unzip ${V2RAY_PATH} -d ${TMP_DIRECTORY} && cd ${TMP_DIRECTORY} && chmod +x v2ray v2ctl && mkdir /usr/local/share/v2ray /etc/v2ray
mv v2ray v2ctl /usr/bin/
mv geosite.dat geoip.dat /usr/local/share/v2ray/
mv config.json /etc/v2ray/config.json

# Clean
rm -rf ${TMP_DIRECTORY}
echo "Done"
