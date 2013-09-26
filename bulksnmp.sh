#!/bin/bash

# Author: Felipe Molina (@felmoltor)
# Date: 03/09/2013
# Summary: Extraer el nombre de todos las IPs que se pasan en un fichero
# TODO: (26/09/2013) Contar el numero de interfaces que tiene el equipo y obtener todas las IP de estas
#   * Numero de interfaces: ifNumber.0
#   * Detalles de la interfaz:
#       + ifDescr.X: Descripcion de la interfaz (Loopback, Ethernet, etc...)
#       + ifPhysAddress.XXX:: MAC de la interfaz
#       + ifAdEntIfIndex.X.X.X.X: Las IPs del dispositivo, donde la IP es X.X.X.X.

function printBanner
{
cat << EOF
   ___.         .__   __                                          ____    _______   
   \\_ |__  __ __|  | |  | __  ______ ____   _____ ______   ___  _/_   |   \\   _  \\  
    | __ \\|  |  \\  | |  |/ / /  ___//    \\ /     \\\\____ \\  \\  \\/ /|   |   /  /_\\  \\ 
    | \\_\\ \\  |  /  |_|    <  \\___ \\|   |  \\  Y Y  \\  |_> >  \\   / |   |   \\  \\_/   \\
    |___  /____/|____/__|_ \\/____  >___|  /__|_|  /   __/    \\_/  |___| /\\ \\_____  /
        \\/                \\/     \\/     \\/      \\/|__|                  \\/       \\/ 

    Tool for asking masively basic information to devices with SNMP enabled.
    Output is provided separated with ";" to redirect easyly to a CSV file.
    Information asked to SNMP device is:
        * System Name
        * Location
        * System Description (S.O. and Hardware)
        * Administrative Contact
        * TODO: All interfaces addresses

    Felipe Molina (@felmoltor)

EOF
}

###############
# CONFIG VARS #
###############
DEFAULT_COMMUNITY="public"
DEFAULT_SNMP_VER=1

########
# MAIN #
########

printBanner


# 
# root@SeOS:~/ffmt/Tools/bulksnmp# snmpwalk -c private -v1  10.229.28.125 ipAdEntAddr
# IP-MIB::ipAdEntAddr.10.40.85.70 = IpAddress: 10.40.85.70
# IP-MIB::ipAdEntAddr.127.0.0.1 = IpAddress: 127.0.0.1
#

# First argument for the IP list
if [[ -f $1 ]]
then
    IP_LIST=$1
else
    echo "Usage: $0 <file_with_ips> [<comunity_string>]"
    exit 1
fi
# Second argument for the comunity string
if [[ $2 != "" ]]
then
    COMMUNITY=$2
else
    COMMUNITY=$DEFAULT_COMMUNITY
fi


echo "IP;sysName;sysLocation;sysDescr;sysContact;Address List"
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
    sysLocation=$(snmpwalk -c $COMMUNITY -v$DEFAULT_SNMP_VER $ip sysLocation.0 | cut -f2 -d= | cut -f2 -d:)
    sysDescr=$(snmpwalk -c $COMMUNITY -v$DEFAULT_SNMP_VER $ip sysDescr.0 | cut -f2 -d= | sed 's/.*STRING: //gi' ) #  cut -f2 -d:)
    sysContact=$(snmpwalk -c $COMMUNITY -v$DEFAULT_SNMP_VER $ip sysContact.0 | cut -f2 -d= | cut -f2 -d:)
    ipAddrs=$(snmpwalk -c $COMMUNITY -v$DEFAULT_SNMP_VER $ip ipAdEntAddr)
    address_List=""
    for addrLine in $ipAddrs; do
        if [[ $addrLine =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
            address_List="$address_List $addrLine"
        fi
    done
    echo "$ip;$sysName;$sysLocation;$sysDescr;$sysContact;$address_List"
done
