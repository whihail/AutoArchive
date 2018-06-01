# 上传到蒲公英
function pgyerUpload() {

    # 参数$1：包相对路径
    # 参数$2：包在ftp上的完整的URL地址
    # 参数$3：蒲公英USER_KEY
    # 参数$4：蒲公英API_KEY
    # 参数$5：版本更新说明
    ipaName="$1"
    ftpPath="$2"
    USER_KEY="$3"
    API_KEY="$4"
    UPDATE_DESC="$5"

    echo "\n\n\033[32m +++++++++++++++++上传蒲公英++++++++++++++++++\033[0m\n\n\n"
    local res=`curl -F "file=@${ipaName}" -F "uKey=${USER_KEY}" -F "_api_key=${API_KEY}" -F "updateDescription=${UPDATE_DESC}" https://qiniu-storage.pgyer.com/apiv1/app/upload`
    res=$(echo ${res} | sed ':a;N;$!ba;s/\n/ /g')
    local code=`echo ${res}| jq .code`
    echo "code=${code}"

    if [[ ${code} == "0" ]]; then

        local appName=$(echo `echo ${res}| jq .data.appName` | sed 's/\"//g')
        local appVersion=$(echo `echo ${res}| jq .data.appVersion` | sed 's/\"//g')
        local appVersionNo=$(echo `echo ${res}| jq .data.appVersionNo` | sed 's/\"//g')
        local appBuildVersion=$(echo `echo ${res}| jq .data.appBuildVersion` | sed 's/\"//g')
        local appIdentifier=$(echo `echo ${res}| jq .data.appIdentifier` | sed 's/\"//g')
        local appShortcutUrl=$(echo `echo ${res}| jq .data.appShortcutUrl` | sed 's/\"//g')
        local downloadUrl="https://www.pgyer.com/${appShortcutUrl}"
        local appKey=$(echo `echo ${res}| jq .data.appKey` | sed 's/\"//g')
        local cruBuildUrl="https://www.pgyer.com/${appKey}"
        local appFileSize=$(echo `echo ${res}| jq .data.appFileSize` | sed 's/\"//g')
        local appUpdated=$(echo `echo ${res}| jq .data.appUpdated` | sed 's/\"//g')
        local appQRCodeURL=$(echo `echo ${res}| jq .data.appQRCodeURL` | sed 's/\"//g')
        local appUpdateDescription=$(echo `echo ${res}| jq .data.appUpdateDescription` | sed 's/\"//g')

        echo "\n\n\n"
        echo "\033[32m ----------------------upload成功---------------------------\033[0m"
        echo "\n\n\n"
        echo "\033[33m app名称: ${appName} \033[0m"
        echo "\033[33m app version号: ${appVersion} \033[0m"
        echo "\033[33m app build号: ${appVersionNo} \033[0m"
        echo "\033[33m 密码: ${PASSWORD} \033[0m"
        echo "\033[33m 蒲公英build号: ${appBuildVersion} \033[0m"
        echo "\033[33m 更新说明:\r\n ${UPDATE_DESC} \033[0m"
        echo "\033[33m 全部版本地址: ${downloadUrl} \033[0m"
        echo "\033[33m 当前版本蒲公英地址: ${cruBuildUrl} \033[0m"
        echo "\033[33m 当前版本FTP服务器地址: ${ftpPath} \033[0m"
        echo "\033[33m 最新版本蒲公英二维码地址: ${appQRCodeURL} \033[0m"

        echo "\n\n\n"
        `echo "app名称:${appName}\r\napp version号:${appVersion}\r\napp build号:${appVersionNo}\r\n全部版本地址:${downloadUrl}\r\n当前版本地址: ${cruBuildUrl}\r\nFTP服务器地址: ${ftpPath}\r\n更新说明:\r\n${UPDATE_DESC} \r\n最新版本蒲公英二维码地址: ${appQRCodeURL}" | pbcopy`
        echo "\033[32m ---------------------蒲公英相关信息已复制--------------------\033[0m"
        echo "\n\n\n"

        # 删除旧文件
        if [ -f ~/jenkins_sh/propfile.txt ] ; then
        rm ~/jenkins_sh/propfile.txt
        fi

        # 输出变量到文件，以便发送邮件时使用
        echo "JOB_APP_NAME   =$appName\n"         > ~/jenkins_sh/propfile.txt
        echo "JOB_APP_VERSION=$appVersion\n"      >> ~/jenkins_sh/propfile.txt
        echo "JOB_PGY_VERSION=$appBuildVersion\n" >> ~/jenkins_sh/propfile.txt
        echo "JOB_APP_BUILD  =$appVersionNo\n"    >> ~/jenkins_sh/propfile.txt
        echo "JOB_ALL_URL    =$downloadUrl\n"     >> ~/jenkins_sh/propfile.txt
        echo "JOB_CRU_URL    =$cruBuildUrl\n"     >> ~/jenkins_sh/propfile.txt
        echo "JOB_FTP_PATH   =$ftpPath\n"         >> ~/jenkins_sh/propfile.txt
        echo "JOB_QRCODE_URL =$appQRCodeURL"      >> ~/jenkins_sh/propfile.txt

    else

        echo "\n\n\n"
        echo "\033[32m ---------------------upload失败---------------------------\033[0m"
        echo "失败原因res：${res}"
        echo "\n\n\n"
    fi
}

pgyerUpload "$1" "$2" "$3" "$4" "$5"



