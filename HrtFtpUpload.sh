# 上传到FTP服务器
function ftpUpload() {

# 参数$1：目标文件名
# 参数$2：目标文件在FTP服务器上的路径
# 参数$3：目标文件的完整URL路径
IPANAME=$1
DIR_UD=$2
FTP_PATH=$3

echo "\n\n\033[32m +++++++++++++++++上传到FTP服务器++++++++++++++++++\033[0m\n\n\n"
ftp -n 10.0.36.46 <<!
user Anonymous Anonymous
binary
mkdir "${DIR_UD}"
put "${IPANAME}" "${DIR_UD}/${IPANAME}"
quit
!
echo "\033[33m 上传FTP服务器成功，当前版本FTP服务器地址: ${FTP_PATH} \033[0m"
}

ftpUpload $1 $2 $3



