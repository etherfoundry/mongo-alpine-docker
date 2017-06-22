#!/bin/bash
set -x

RUN="${RS_INIT:-no}"
HOST="${RSHOST:-mongo}"

if [ "$RUN" != "yes" ] ; then  
  echo "not initializing replica set - to do otherwise, set RS_INIT to 'yes'"
else
  echo "initiating replica set"

  until mongo --quiet --eval 'db.version()'; do
    >&2 echo "mongo unavailable, sleeping"
    sleep 1
  done

  STATUS_CODE="`mongo --quiet --eval 'rs.status().codeName'`"
  STATUS_OK="`mongo --quiet --eval 'rs.status().ok'`"

  if [ "$STATUS_OK" == "0" ] ; then
    if [ "$STATUS_CODE" == "NotYetInitialized" ] ; then
      mongo --eval "rs.initiate({_id:'garnet', version:1, members: [ { _id: 0, host: '$HOST:27017'} ]})"
      # mongo --eval "rs.initiate()"
      until [ "$( mongo --quiet --eval 'rs.status().ok' )" == "1" ] ; do
          echo "waiting for replication ready..."
          sleep 1
      done

      # Do we have RS members to register?
      if [ "$RS_MEMBERS" ] ; then
         IFS=',' read -ra MEOW <<< "$RS_MEMBERS"
         for i in "${MEOW[@]}"; do
             mongo --eval "rs.add('${i}:27017')"
             sleep 1
         done
      fi

    fi
  fi
fi
