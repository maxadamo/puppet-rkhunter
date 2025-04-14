#!/bin/bash
#
PATH=/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin
EMAIL="$1"
FQDN="$(hostname -f)"
[[ "$#" -gt 1 ]]&& export http_proxy="$2"
[[ "$#" -gt 1 ]]&& export https_proxy="$2"
RKHUNTER_OUTPUT="$(rkhunter --cronjob --syslog --update &>/dev/null || true)"

if [ -n "$RKHUNTER_OUTPUT" ]; then
    if which mail &>/dev/null; then
        echo -e "$RKHUNTER_OUTPUT" | mail -s "RKHUNTER Update $FQDN" $EMAIL
    elif which mutt &>/dev/null; then
        echo -e "$RKHUNTER_OUTPUT" | mutt -s "RKHUNTER Update $FQDN" $EMAIL
    elif which mailx &>/dev/null; then
        echo -e "$RKHUNTER_OUTPUT" | mailx -s "RKHUNTER Update $FQDN" $EMAIL
    elif which sendmail &>/dev/null; then
        echo -e "Subject: RKHUNTER Update $FQDN\n$RKHUNTER_OUTPUT" | sendmail -t $EMAIL
    else
        echo "RKHUNTER Update: $RKHUNTER_OUTPUT"
    fi
fi
