# CentOS / Linux 系統管理與 Bash 筆記小抄

> 一份可快速查找的 GitHub README：涵蓋服務管理、網路、檔案系統、使用者/權限、套件管理、排程、Bash 腳本與常用文字處理（grep/awk/cut）。以 CentOS/RHEL 為主，兼顧 6/7/8/Stream 差異。

---

## 目錄

* [快速上手](#快速上手)
* [檔案與目錄](#檔案與目錄)
* [權限與擁有者](#權限與擁有者)
* [使用者與群組](#使用者與群組)
* [服務／開機等級](#服務開機等級)
* [網路與防火牆](#網路與防火牆)
* [容量與檔案系統](#容量與檔案系統)
* [行程／程序管理](#行程程序管理)
* [搜尋與文字處理](#搜尋與文字處理)
* [壓縮與打包](#壓縮與打包)
* [套件管理（RPM / YUM / DNF）](#套件管理rpm--yum--dnf)
* [時間與排程](#時間與排程)
* [Bash 腳本基礎](#bash-腳本基礎)
* [流程控制與互動](#流程控制與互動)
* [awk / cut 精要](#awk--cut-精要)
* [安全小提醒](#安全小提醒)

---

## 快速上手

```bash
# 你是誰 / 哪台機器
whoami; hostnamectl status

# 看服務狀態（CentOS 7+）
systemctl status <service>

# 看網路與埠（建議用 ss）
ss -ltnp     # TCP 監聽 + 進程

# 檔案大小與磁碟使用
ls -lh; df -h; du -sh * | sort -h

# 幫助 / 手冊
<cmd> --help
man <cmd>
```

---

## 檔案與目錄

```bash
pwd                        # 目前路徑
ls -al                     # 顯示含隱藏檔
cd .. | cd -               # 上一層 / 回到前一個位置
mkdir -p a/b/c             # 建多層目錄
rmdir <dir>                # 只能刪空目錄；非空用 rm -r（小心！）
cp <src> <dst>             # 複製；目錄用 -r
mv <src> <dst>             # 移動/改名
rm -f <file>               # 直接刪除
rm -rf <dir>               # 遞迴強制（危險）

cat -n file                # 顯示並附行號
less -N file               # 分頁（可搜尋 /xxx；q 離開）
head -n 20 file; tail -f file

ln -s <target> <link>      # 建立符號連結（捷徑）
```

---

## 權限與擁有者

**`ls -l` 前 10 碼：** `[0]型態 [1-3]u [4-6]g [7-9]o`，`r=4 w=2 x=1`
型態：`-` 檔、`d` 目錄、`l` 連結、`c/b` 裝置、`p` 管線、`s` socket

```bash
# 改權限（符號式 / 數字式）
chmod u+x script.sh
chmod go-rw secret
chmod 755 dir      # u:rwx g:r-x o:r-x

# 變更擁有者/群組
sudo chown user:group file
sudo chgrp group file
```

---

## 使用者與群組

```bash
# 新增與密碼
sudo useradd -m alice
sudo useradd -m -d /data/home/alice alice
sudo passwd alice

# sudo 權限（CentOS：wheel）
sudo usermod -aG wheel alice
sudo visudo   # 確認 %wheel ALL=(ALL) ALL

# 刪除與查詢
sudo userdel -r bob
id alice; groups alice; getent passwd alice

# 切 root
su -           # 有 root 密碼
sudo -i        # 你是 sudoer
```

---

## 服務／開機等級

```bash
# systemd（CentOS 7/8/Stream）
systemctl status <svc>
systemctl enable --now <svc>
systemctl get-default            # 開機 target（multi-user/graphical）

# SysV（CentOS 6 / 少數舊環境）
chkconfig --list
chkconfig --level 3 <svc> on
```

---

## 網路與防火牆

```bash
# 監聽中的埠
ss -ltnp
# 舊：netstat -nlp | grep :80

# 防火牆（firewalld）
systemctl status firewalld
firewall-cmd --add-service=ssh --permanent && firewall-cmd --reload
```

---

## 容量與檔案系統

```bash
df -h                 # 檔案系統用量
lsblk -f              # 裝置/分割/檔案系統/UUID
free -h               # 記憶體

# 掛載/卸載
sudo mount /dev/sdb1 /mnt/data
sudo umount /mnt/data

# 開機自動掛載（/etc/fstab）
# UUID=<xxxx>  /data  ext4  defaults,noatime  0 2
sudo mount -a         # 測試 fstab 條目

# 檔案系統檢查（未掛載分割）
sudo fsck -f /dev/sdb1
# XFS：sudo xfs_repair /dev/sdb1
```

---

## 行程／程序管理

```bash
ps aux --sort=-%mem | head         # 看吃資源的行程
ps -ef | grep nginx                # 依名稱找
pstree -p                          # 父子關係

top                                # 互動監控：P/M/N 排序、1 顯示各核心、q 離開

kill <PID>                         # SIGTERM(15)
kill -9 <PID>                      # SIGKILL（最後手段）
killall <name>
```

---

## 搜尋與文字處理

```bash
# 檔名/屬性搜尋
find /var -type f -name "*.log" -size +100M -mtime -7 -print
locate httpd.conf   # 需 updatedb 建索引

# 指令/檔路徑
which nginx

# 文字篩選
grep -n "keyword" file
ls | grep boot
```

---

## 壓縮與打包

```bash
# gzip / gunzip（單檔）
gzip file; gunzip file.gz; zcat file.gz

# zip / unzip
zip -r site.zip /var/www/site
unzip site.zip -d /tmp/site

# tar（打包＋壓縮）
tar -czvf data.tar.gz /data
tar -xzvf data.tar.gz -C /restore
```

---

## 套件管理（RPM / YUM / DNF）

```bash
# rpm：對本機 .rpm 的安裝/查詢（不解相依）
sudo rpm -ivh pkg.rpm
sudo rpm -Uvh pkg.rpm
sudo rpm -e  package_name
rpm -qi package_name; rpm -ql package_name

# yum / dnf：自動處理相依
sudo yum install <pkg>
sudo yum remove <pkg>
sudo yum info <pkg>; sudo yum search <kw>
sudo yum provides '*/sshd'; sudo yum repolist
# CentOS 8/Stream 用 dnf，同參數
```

---

## 時間與排程

```bash
# 顯示時間/月曆
date
date "+%Y-%m-%d %H:%M:%S"
cal -3; cal -y 2025

# crond
sudo systemctl enable --now crond
crontab -e          # 進入編輯（vim）
# 例：每天 02:30 執行腳本
# 30 2 * * * /root/backup_etc.sh >> /var/log/backup_etc.log 2>&1
```

---

## Bash 腳本基礎

```bash
#!/bin/bash
# 執行方式
bash script.sh
./script.sh      # 需 chmod +x script.sh
source script.sh # 在當前 shell 跑（會影響目前環境）

# 變數與環境
name="Alice"; echo "$name"
export PATH="$PATH:/opt/bin"   # 匯出成環境變數
readonly ver=1.0

# 特殊變數
$0 $1 $2  "$@"  $#  $?  $$  $!

# 算術
expr 1 + 2
echo $(( 1+2 ))
let x+=1

# 檔案/字串/數值判斷
[ -f file ]  [ -d dir ]  [ -n "$s" ]  [ -z "$s" ]
[[ $a -gt 18 && $a -lt 35 ]]
```

---

## 流程控制與互動

```bash
# if / elif / else
if [[ $a -gt 10 ]]; then
  echo gt10
elif [[ $a -eq 10 ]]; then
  echo eq10
else
  echo lt10
fi

# case
case "$x" in
  start|up)  do_start ;;
  stop|down) do_stop  ;;
  *)         echo "unknown" ;;
esac

# 迴圈
for (( i=1; i<=N; i++ )); do echo $i; done
for os in linux windows macos; do echo $os; done

# while
sum=0; a=1
while (( a<=N )); do (( sum+=a, a++ )); done

echo "請輸入您的芳名: "; read name
# 或：read -t 10 -p "請輸入您的芳名: " name
```

---

## awk / cut 精要

```bash
# cut：單字元分隔（快速）
cut -d: -f1,7 /etc/passwd
cut -d, -f2- data.csv

# awk：欄位導向、可計算/篩選/排序
awk -F: 'BEGIN{OFS=","; print "user","shell"} {print $1,$7}' /etc/passwd
awk -F, 'NR>1 {sum+=$3} END{print sum}' data.csv
# 多空白分隔的第 10 欄（比 cut 穩定）
ifconfig | awk '/netmask/ {print $10}'
```

---


