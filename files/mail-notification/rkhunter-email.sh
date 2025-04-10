#!/bin/bash
#
PATH=/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin
EMAIL="$1"
FQDN="$(hostname -f)"
if [[ "$#" -gt 1 ]]; then
    RKHUNTER_STDERR="$(rkhunter --cronjob --rwo --syslog >${2})"
else
    RKHUNTER_STDERR="$(rkhunter --cronjob --rwo --syslog)"
fi

if [ -n "$RKHUNTER_STDERR" ]; then
    if which mail &>/dev/null; then
        echo -e "$RKHUNTER_STDERR" | mail -s "RKHUNTER ALERT $FQDN" $EMAIL
    elif which mutt &>/dev/null; then
        echo -e "$RKHUNTER_STDERR" | mutt -s "RKHUNTER ALERT $FQDN" $EMAIL
    elif which mailx &>dev/null; then
        echo -e "$RKHUNTER_STDERR" | mailx -s "RKHUNTER ALERT $FQDN" $EMAIL
    elif which sendmail &>/dev/null; then
        echo -e "Subject: RKHUNTER ALERT $FQDN\n$RKHUNTER_STDERR" | sendmail -t $EMAIL
    else
        echo "RKHUNTER ALERT: $RKHUNTER_STDERR"
    fi
fi
