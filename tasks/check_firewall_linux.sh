#!/bin/bash

iptables_srv=$(systemctl is-enabled iptables.service 2>/dev/null)
firewalld_srv=$(systemctl is-enabled firewalld.service 2>/dev/null)
iptables=$(systemctl is-active iptables.service 2>/dev/null)
firewalld=$(systemctl is-active firewalld.service 2>/dev/null)

if [ "${iptables_srv}" = "enabled" -o "${iptables}" = "active" -o "${firewalls_srv}" = "enabled" -o "${firewalld}" = "active"] ; then
    fw="enabled"
else
    fw="disabled"
fi

echo "{ \"firewall\": \"${fw}\" }"

exit 0
