#!/bin/bash

# Author: FFMT
# Date: 03/09/2013
# Summary: Extraer el nombre de todos las IPs que se pasan en un fichero

# First argument for the IP list
if [ -f $1 ]
then
    IP_LIST=$1
else
    echo "Usage: $0 <file_with_ips> [<comunity_string>]"
    exit 1
fi
# Second argument for the comunity string
if [ $2 ]
then
    COMMUNITY=$2
else
    COMMUNITY="public"
fi


echo "IP;sysName;sysLocation;sysDescr;sysContact"
for ip in `cat $IP_LIST`
do
    # system=$(snmpwalk -c public -v1 $ip system)
    sysName=$(snmpwalk -c $COMMUNITY -v1 $ip sysName.0)
    # If there is a problem, exit this loop item
    if [ "$?" -ne "0" ]
    then
        echo "Skipping $ip..."
        continue
    fi
    sysName=$(echo $sysName | cut -f2 -d= | cut -f2 -d:)
    sysLocation=$(snmpwalk -c $COMMUNITY -v1 $ip sysLocation.0 | cut -f2 -d= | cut -f2 -d:)
    sysDescr=$(snmpwalk -c $COMMUNITY -v1 $ip sysDescr.0 | cut -f2 -d= | cut -f2 -d:)
    sysContact=$(snmpwalk -c $COMMUNITY -v1 $ip sysContact.0 | cut -f2 -d= | cut -f2 -d:)
    echo "$ip;$sysName;$sysLocation;$sysDescr;$sysContact"
done
