#!/bin/bash
 
 echo "Filter table:"
 echo
 echo  ---*--------------------------------Filter table---------------------------------*---
 iptables -t filter -vL -n
 echo
 echo  ---*--------------------------------NAT table------------------------------------*---
 echo "NAT table:"
 iptables -t nat -vL -n
 echo
 echo  ---*-------------------------------Mangle table----------------------------------*---
 echo "Mangle table:"
 iptables -t mangle -vL -n
 echo
 echo  ---*-------------------------------RAW table-------------------------------------*---
 echo "RAW table:"
 iptables -t raw -vL -n
 echo
 echo  ---*-------------------------------Security table--------------------------------*---
 echo "Security table:"
 iptables -t security -vL -n
 echo  ---*-----------------------------------------------------------------------------*---

 echo "All rules in all tables printed"