#!/bin/bash
set -x

RUN="${RS_REGISTER:-no}"
HOST="${HOST:-mongo}"
MEMBER_NAME="${MEMBER_NAME:-$HOSTNAME}"

if [ "$RUN" != "yes" ] ; then  
	echo "not registering with master - to do otherwise, set RS_REGISTER to 'yes'"
else
	echo "registering with master (first, sleeping until ready)"
	TEST_MASTER=$( mongo --quiet --host "$HOST"  --eval 'rs.status().ok' )
	until [ "$TEST_MASTER" == "1" ]; do
		echo "mongo --quiet --host $HOST  --eval 'rs.status().ok' == $TEST_MASTER, sleeping"
		sleep 1
		TEST_MASTER=$( mongo --quiet --host "$HOST" --eval 'rs.status().ok' )
	done
#	MY_IP="$( hostname )"
	RS_MASTER="${HOST:-mongo}"
	mongo --host "$RS_MASTER" --eval "rs.add('$MEMBER_NAME');"
fi
