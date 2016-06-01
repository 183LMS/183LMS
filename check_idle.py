#!/usr/bin/python

import sys, math, datetime
import MySQLdb
import argparse

MYSQL_USER = "root"
MYSQL_PASS = "rootpass"

DEFAULT_TABLE = "atable"
DEFAULT_MAX_MBPS = 0.1
DEFAULT_MINUTES = 5

parser = argparse.ArgumentParser(description="Check if the link is idle. The link is idle if the average traffic speed was less than some number of mbps over some number of minutes. Returns 0 is the link is idle, 1 is the link is not idle, and 2 if there was not enough information to tell (probably not idle).")
parser.add_argument("--table", help="name of the table to check", default=DEFAULT_TABLE)
parser.add_argument("--max_mbps", type=float, help="maximum traffic on the link that should be considered idle", default=DEFAULT_MAX_MBPS)
parser.add_argument("--minutes", type=int, help="number of integer minutes to check for traffic", default=DEFAULT_MINUTES)
args = parser.parse_args()
TABLE = args.table
MAX_MBPS = args.max_mbps
MINUTES = args.minutes

# print TABLE, MAX_MBPS, MINUTES

# Open database connection
db = MySQLdb.connect("localhost",MYSQL_USER,MYSQL_PASS,"cs183")
cursor = db.cursor()


# Try to get the latest time in the table
# TODO: Yea, this is slow b/c it searched the entire DB
# TODO: Manually iterate backwards until find a record with a cumulative value
# TODO: Maybe we can give mysql hints as to search order
cursor.execute("SELECT MAX(time) FROM %s WHERE inB_cumulative IS NOT NULL" % (TABLE))
endTime = cursor.fetchone()[0]
if (endTime == None):
	# No records means that link hasn't been up long enough to check for idleness
	sys.exit(2)


latestStartTime = endTime - datetime.timedelta(minutes=MINUTES)
# Try to get latest recorded time that is at least MINUTES back
cursor.execute("SELECT MAX(time) FROM %s WHERE time <= '%s'" % (TABLE, latestStartTime))
startTime = cursor.fetchone()[0]
if (startTime == None):
	# No records means that link hasn't been up long enough to check for idleness
	sys.exit(2)

# Get cumulative values for each time

cursor.execute("SELECT inB_cumulative,outB_cumulative FROM %s WHERE time='%s'" % (TABLE, startTime))
startBytes = cursor.fetchone()
cursor.execute("SELECT inB_cumulative,outB_cumulative FROM %s WHERE time='%s'" % (TABLE, endTime))
endBytes = cursor.fetchone()

link_timedelta = endTime - startTime
link_seconds = (link_timedelta.days * 86400) + link_timedelta.seconds

mbps_in = (endBytes[0] - startBytes[0]) * 8 / 1000000.0 / link_seconds
mbps_out = (endBytes[1] - startBytes[1]) * 8 / 1000000.0 / link_seconds

print("Link: %.3f mbps in, %.3f mbps out over %d seconds" % (mbps_in, mbps_out, link_seconds))

if (mbps_in > MAX_MBPS or mbps_out > MAX_MBPS):
	print("Link not idle")
	sys.exit(1)
else:
	print("Link is idle")
	sys.exit(0)



