echo "root:$1" | chpasswd
sed -i 's|#PermitRootLogin prohibit-password|PermitRootLogin yes|g' /etc/ssh/sshd_config
systemctl restart ssh