#!/usr/bin/env bash

STAT_SLEEP=20

echo "Loading The Crawler"

while :
do
  # Get latest guild updates
  PENDING_TRANSACTION_COUNT=$(psql $DATABASE_URL -c "SELECT COUNT(1) FROM signer.tx WHERE status = 'pending';" --no-align -t)
  echo "CRAWLER: ${PENDING_TRANSACTION_COUNT} Pending Transactions "
  CRAWL_JSON=$(psql $DATABASE_URL -c 'select structs.GET_GUILD_UPDATES;' --no-align -t)
  CRAWL_GUILD_ID=$(echo $STUB_ACCOUNT_JSON | jq -r '.id')

  if [[ ! -z "$CRAWL_JSON" ]]; then
    if [ "$CRAWL_GUILD_ID" != "null" ]; then
      echo $CRAWL_JSON > /var/structs/tmp/crawl_${CRAWL_GUILD_ID}.json

      echo "CRAWLER ($BASHPID): Performing Crawl of ${CRAWL_GUILD_ID}"

      # Curl endpoint

      # Update Guild

    else
        sleep $STAT_SLEEP
    fi
  else
      sleep $STAT_SLEEP
  fi

done
