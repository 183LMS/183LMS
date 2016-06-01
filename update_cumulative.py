#!/usr/bin/python

import sys, math
import MySQLdb
import argparse

MYSQL_USER = "root"
MYSQL_PASS = "rootpass"

parser = argparse.ArgumentParser(description="Updates cumulative bytes in/out in database")
parser.add_argument("table", help="name of the table to update")
args = parser.parse_args()
TABLE =  args.table

# Open database connection
db = MySQLdb.connect("localhost",MYSQL_USER,MYSQL_PASS,"cs183")
cursor = db.cursor()

# Get the earliest time where cumulative values are NULL
# We don't need to work with eariler records that already have cumulative values
cursor.execute("SELECT MIN(time) FROM %s WHERE inB_cumulative is NULL" % TABLE)
startTime = cursor.fetchone()[0]
# TODO: load last start time from another table because faster than searching
# entire table
if (startTime == None):
	print("Cumulative values already up to date. Nothing done.")
	sys.exit()

# Get all rows including and after that time
cursor.execute("SELECT time,inB,outB,inB_cumulative,outB_cumulative FROM %s WHERE time >= '%s' ORDER BY time" % (TABLE, startTime))
data = cursor.fetchall()

# Check if startTime is the earilest record in the table
# Try to get a record that is earlier that startTime...
cursor.execute("SELECT MAX(time) FROM %s WHERE time < '%s'" % (TABLE, startTime))
lastTime = cursor.fetchone()[0]
if (lastTime == None):
	# There were no previous records, pretend there was one that contained all zeros
	print("There are no previous cumulative values")
	last = [lastTime,
		0,  # inB
		0,  # outB
		0,  # inB_cumulative
		0]  # outB_cumulative
else:
	cursor.execute("SELECT time,inB,outB,inB_cumulative,outB_cumulative FROM %s WHERE time='%s'" % (TABLE,lastTime))
	last = list(cursor.fetchone())

records = len(data)
for i in range(records):
	curr = list(data[i])
	
	# Calculate differential between this and last record
	# Check and fix TP-Link overflow
	diffIn  = curr[1] - last[1]
	if (diffIn  < 0):
		diffIn = (2**32) - last[1] + curr[1]
	diffOut = curr[2] - last[2]
	if (diffOut < 0):
		diffOut = (2**32) - last[2] + curr[2]
	
	# Add differential to running total
	curr[3] = last[3] + diffIn
	curr[4] = last[4] + diffOut	
	

	sys.stdout.write("\r[%d/%d] Updating time %s -> In: %.2f GB, Out: %.2f GB" % (i+1, records, curr[0], curr[3]/1000000000.0, curr[4]/1000000000.0))
	cursor.execute("UPDATE %s SET inB_cumulative=%d, outB_cumulative=%d WHERE time='%s'" % (TABLE, curr[3], curr[4], curr[0]))

	last = curr

db.commit()
print("")
print("Done: %d records updated." % records)
