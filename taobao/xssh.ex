#!/usr/bin/expect -f
#
# xssh's expect shell
# author: dukun@taobao.com
#
# 参数说明



# 解析传递进来的参数
# 因为这个是内部脚本，只有我们自己在调用，所以这里就不对参数进行非常详尽的校验了
# 	argv[0] XSSH_FILE，这个文件用于存放ssh登录时候所必须账号和密码
# 	argv[1] 需要访问的远程主机ip
#	stdin	从管道进来的都是需要发送到远端执行的命令
if {$argc != 2} {
	puts stderr "ERROR! The arg's numbers was incorrect. argc=$argc."
	flush stderr
	exit 1
}
set xssh_file 	[lindex $argv 0]
set xssh_ip 	[lindex $argv 1]


# 从XSSH_FILE文件中解析出用户名和密码
set xssh_file_fd [open $xssh_file]
while {[gets $xssh_file_fd line] >= 0} {
	set line_args [split $line "="]
	if {[lindex $line_args 0] == "username"} {
		set xssh_username [lindex $line_args 1]
	} elseif {[lindex $line_args 0] == "password"} {
		set xssh_password [lindex $line_args 1]
	} else {
		# do nothing...
	}
}
close $xssh_file_fd


# 开始执行SSH
spawn -noecho ssh \
	-o ConnectTimeout=5 \
	-o NumberOfPasswordPrompts=2 \
	-o StrictHostKeyChecking=no \
	$xssh_username@$xssh_ip bash -s
	
expect {
	"Enter*" {send "\n";exp_continue}
	"*yes/no*" {send "yes\n";exp_continue}
	"*?assword:*" {send "$xssh_password\n"}
}

while {[gets stdin line] != -1} {
    send "$line\n"
}

# send CTRL+D
send \004


expect {
	eof {flush stdout;exit 0;}
	
}