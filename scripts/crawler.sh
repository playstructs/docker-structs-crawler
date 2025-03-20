#!/usr/bin/env bash

STAT_SLEEP=20

echo "Loading The Crawler"

while :
do
  # Get latest guild updates
  PENDING_TRANSACTION_COUNT=$(psql $DATABASE_URL -c "SELECT COUNT(1) FROM signer.tx WHERE status = 'pending';" --no-align -t)

  echo "CRAWLER: ${PENDING_TRANSACTION_COUNT} Pending Transactions "

  sleep $STAT_SLEEP
done
