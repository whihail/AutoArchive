# 说明：以下代码用到的项目名，账号，地址等信息均已经过修改。
# 工程名
APP_NAME="demo"
# target名
TARGET_NAME="demo-ent"
# workspace名
WORK_SPACE="demo.xcworkspace"
# 证书
CODE_SIGN_DISTRIBUTION="iPhone Distribution: ******* ***** (Shenzhen) Company Limited"
# info.plist路径
project_infoplist_path="./${APP_NAME}/${TARGET_NAME}-Info.plist"
# 取版本号
bundleShortVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleShortVersionString" "${project_infoplist_path}")
# 取build值
bundleVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleVersion" "${project_infoplist_path}")
DATE="$(date +%Y%m%d%H%M)"

# IPA路径
IPAPATH="${TARGET_NAME}_V${bundleShortVersion}_Build${bundleVersion}_${DATE}"
# IPA包名
IPANAME="${TARGET_NAME}_V${bundleShortVersion}_Build${bundleVersion}_${DATE}.ipa"
# xcarchive
XCARCHIVE="${TARGET_NAME}_V${bundleShortVersion}_Build${bundleVersion}_${DATE}.xcarchive"
# 蒲公英用户key
USER_KEY="b68c3ead9cc3846aa4f806se3c5327dd"
# 蒲公英apiKey
API_KEY="fr4a2660ddae5856bd70d93027882290"
# FTP路径
DIR_UD="pub/iOS/Demo/Enterprise/V${bundleShortVersion}"
# FTP包地址
FTP_PATH="ftp://10.0.54.27/${DIR_UD}/${IPANAME}"


# 打包
~/jenkins_sh/HrtBuildIpa.sh "${WORK_SPACE}" "${TARGET_NAME}" "${XCARCHIVE}" "${IPAPATH}" "${IPANAME}"
cd "./build/${IPAPATH}"
mv "${TARGET_NAME}.ipa" "${IPANAME}"


# 上传到FTP服务器
~/jenkins_sh/HrtFtpUpload.sh "${IPANAME}" "${DIR_UD}" "${FTP_PATH}"


# 上传到蒲公英
~/jenkins_sh/HrtPgyerUpload.sh "${IPANAME}" "${FTP_PATH}" "${USER_KEY}" "${API_KEY}" "${PackageResume}"

