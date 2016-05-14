while (true)
do
MYSTR=`ping 192.168.2.11 -c 1 | grep time= | awk {'print substr($7,6) $8'}`
# touch /cs183/ping.sql
echo "INSERT INTO testpings(ping) VALUES (\"$MYSTR\");" > /cs183/ping.sql
mysql cs183 < /cs183/ping.sql
sleep 5s
done
exit
