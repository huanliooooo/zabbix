#! / bin / bash
# Sending MySQL server statistics to Zabbix server

# Get statistics line. Mysqladmin options:
#   --silent 'silent' exit when it is not possible to establish a connection;
#   --user MySQL user connection;
#   --password MySQL user password;
#   extended-status output server status variables
RespStr=$(/usr/bin/mysqladmin --silent --user=mysql_user --password=mysql_password extended-status 2>/dev/null)
# Statistics not available - return of service status - 'does not work'
[ $? != 0 ] && echo 0 && exit 1

# Filtering, formatting and sending statistics data to Zabbix server
(cat <<EOF
$RespStr
EOF
) | awk -F'|' '$2~/^ (Com_(delete|insert|replace|select|update)|Connections|Created_tmp_(files|disk_tables|tables)|Key_(reads|read_requests|write_requests|writes)|Max_used_connections|Qcache_(free_memory|hits|inserts|lowmem_prunes|queries_in_cache)|Questions|Slow_queries|Threads_(cached|connected|created|running)|Bytes_(received|sent)|Uptime) +/ {
 gsub(" ", "", $2);
 print "- mysql." $2, int($3)
}' | /usr/bin/zabbix_sender --config /etc/zabbix/zabbix_agentd.conf --input-file - >/dev/null 2>&1
# Return service status - 'works'
echo 1
exit 0
