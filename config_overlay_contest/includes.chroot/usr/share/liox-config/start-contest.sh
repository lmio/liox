cat > /etc/iptables/rules.v4 <<EOF
*filter
:INPUT DROP
:FORWARD DROP
:OUTPUT DROP

-A INPUT -p tcp -s olimp.cms.lmio.lt -j ACCEPT
-A INPUT -p tcp -s ctrl.lmio.lt -j ACCEPT
-A INPUT -j REJECT

-A OUTPUT -p tcp -d olimp.cms.lmio.lt -j ACCEPT
-A OUTPUT -p tcp -d ctrl.lmio.lt -j ACCEPT
-A OUTPUT -j REJECT

COMMIT
EOF

iptables-restore /etc/iptables/rules.v4

systemctl mask udisks2.service
systemctl stop udisks2.service
