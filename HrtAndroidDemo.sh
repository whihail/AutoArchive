# json字符串
JSON_STRING=$(cat version_config)
# 工程名
TARGET_NAME="demo"
# 版本号
bundleShortVersion=$(echo `echo ${JSON_STRING}| jq .bundleShortVersion` | sed 's/\"//g')
# build号
bundleVersion=$(echo `echo ${JSON_STRING}| jq .bundleVersion` | sed 's/\"//g')
DATE="$(date +%Y%m%d%H%M)"

# IPA包名
IPANAME="${TARGET_NAME}_V${bundleShortVersion}_Build${bundleVersion}_${DATE}.apk"
# 用户key
USER_KEY="b68c3ead9cc3846aa4f806se3c5327dd"
# apiKey
API_KEY="fr4a2660ddae5856bd70d93027882290"
# FTP路径
DIR_UD="pub/Android/Dome/V${bundleShortVersion}"
# FTP包地址
FTP_PATH="ftp://10.0.54.27/${DIR_UD}/${IPANAME}"

# apk改名
cd "./app/build/outputs/apk/"
mv "Dome_V${bundleShortVersion}_${bundleVersion}.apk" "${IPANAME}"


# 上传到FTP服务器
~/jenkins_sh/HrtFtpUpload.sh "${IPANAME}" "${DIR_UD}" "${FTP_PATH}"


# 上传到蒲公英
~/jenkins_sh/HrtPgyerUpload.sh "${IPANAME}" "${FTP_PATH}" "${USER_KEY}" "${API_KEY}" "${PackageResume}"

