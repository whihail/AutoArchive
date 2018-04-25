function appStoreUpload() {

    #$1：需要上传的包路径
    IPANAME=$1
    userName="*******iConnet账号"
    password="*******iconnet账号密码"

    # 上传AppStore
    echo "\n\n\033[32m +++++++++++++++++AppStore开始验证+++++++++++++++++\033[0m\n\n\n"
    /Applications/Xcode.app/Contents/Applications/Application\ Loader.app/Contents/Frameworks/ITunesSoftwareService.framework/Support/altool --validate-app -f ${IPANAME} -u ${userName} -p ${password} -t ios --output-format xml

    echo "\n\n\033[32m +++++++++++++++++AppStore开始上传+++++++++++++++++\033[0m\n\n\n"
    /Applications/Xcode.app/Contents/Applications/Application\ Loader.app/Contents/Frameworks/ITunesSoftwareService.framework/Support/altool --upload-app -f ${IPANAME} -u ${userName} -p ${password} -t ios --output-format xml

    echo "\n\n\033[32m +++++++++++++++++AppStore上传完成+++++++++++++++++\033[0m\n\n\n"
}

appStoreUpload $1



