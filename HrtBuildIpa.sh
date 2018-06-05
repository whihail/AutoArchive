function buildIpa() {  #构建企业包

    # 参数$1：xcworkspace文件路径
    # 参数$2：需要构建的target名字
    # 参数$3：xcarchive文件相对路径
    # 参数$4：包需要存放的相对路径
    # 参数$5：这里用不到，可不传
    WORK_SPACE=$1
    TARGET_NAME=$2
    XCARCHIVE=$3
    IPAPATH=$4
    IPANAME=$5

    # 开始计时
    SECONDS=0

    # 清理
    echo "\n\n\033[32m +++++++++++++++++清理中+++++++++++++++++\033[0m\n\n\n"
    xcodebuild -workspace "${WORK_SPACE}" -scheme "${TARGET_NAME}" -configuration 'Release' clean

    # 编译
    echo "\n\n\033[32m +++++++++++++++++编译中+++++++++++++++++\033[0m\n\n\n"
    xcodebuild -workspace "${WORK_SPACE}" -sdk iphoneos -scheme "${TARGET_NAME}" -archivePath "./build/${XCARCHIVE}" -configuration 'Release' archive

    # 打包
    echo "\n\n\033[32m +++++++++++++++++打包中++++++++++++++++++\033[0m\n\n\n"
    xcodebuild -exportArchive -archivePath "./build/${XCARCHIVE}" -exportPath "./build/${IPAPATH}" -exportOptionsPlist "./EnterpriseExportOptionsPlist.plist" -allowProvisioningUpdates

    # 验证
    if [ -f "./build/${IPAPATH}/${TARGET_NAME}.ipa" ] ; then
    echo "\n\n\033[32m +++++++++++++++++打包成功，用时 ${SECONDS}s ++++++++++++++++++\033[0m\n\n\n"
    else
    echo "\n\n\033[32m +++++++++++++++++打包失败++++++++++++++++++\033[0m\n\n\n"
    fi
}

buildIpa $1 $2 $3 $4 $5



