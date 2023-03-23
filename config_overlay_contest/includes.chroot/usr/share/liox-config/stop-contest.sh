cat > /etc/iptables/rules.v4 <<EOF
*filter
:INPUT ACCEPT
:FORWARD ACCEPT
:OUTPUT ACCEPT

-F

COMMIT
EOF

iptables-restore /etc/iptables/rules.v4

systemctl unmask udisks2.service
systemctl start udisks2.service
