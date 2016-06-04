#/bin/bash
sudo apt-get update
sudo apt-get install mysql-server ruby-rails snmp \
                     snmpd python-mysqldb git libmysqlclient-dev

cd /183LMS
mysql -u root -prootpass < /183LMS/setup_db.sql

CRONTAB_BITS=crontab_bits
CRONTAB_SYS=/etc/crontab
sudo bash -c "cat $CRONTAB_BITS >> $CRONTAB_SYS"

cd /183LMS/website
bundle install

