#!/usr/bin/env bash

CRAWL_SLEEP=120

echo "Loading The Crawler"

while :
do
  # Get latest guild updates
  echo "CRAWLER ($BASHPID): ${PENDING_TRANSACTION_COUNT} Checking for updated endpoints "

  # Refresh changed endpoints and cached metadata older than a day so edits to
  # guild.json (including guild.webapp) are discovered off-chain.
  CRAWL_JSON=$(psql "$DATABASE_URL" -c "
    SELECT jsonb_agg(g.*)
    FROM (
      SELECT guild.id, guild.endpoint
      FROM structs.guild
      LEFT JOIN structs.guild_meta ON guild_meta.id = guild.id
      WHERE guild.endpoint IS NOT NULL
        AND (guild_meta.id IS NULL
          OR guild.updated_at > guild_meta.updated_at
          OR guild_meta.updated_at IS NULL
          OR guild_meta.updated_at < NOW() - INTERVAL '1 day')
    ) AS g;" --no-align -t)
  CRAWL_COUNT=$(echo ${CRAWL_JSON} | jq length )

  for (( p=0; p<CRAWL_COUNT; p++ ))
  do

    CRAWL_GUILD_ID=$(echo $CRAWL_JSON | jq -r ".[${p}].id")
    CRAWL_GUILD_ENDPOINT=$(echo $CRAWL_JSON | jq -r ".[${p}].endpoint")
    echo "CRAWLER ($BASHPID): Performing Crawl of ${CRAWL_GUILD_ID} for endpoint ${CRAWL_GUILD_ENDPOINT}"

    # Curl endpoint
    curl -o crawl_endpoint_data.json.tmp ${CRAWL_GUILD_ENDPOINT}

    # validate the json
    # Run it through jq so garbage falls away
    # Limit guild tags to their first four characters before import.
    CRAWL_GUILD_JSON=$( cat crawl_endpoint_data.json.tmp | jq -c 'if (.guild.tag | type) == "string" then .guild.tag |= .[:4] else . end')
    rm crawl_endpoint_data.json.tmp

    # Update Guild
    CRAWL_GUILD_JSON="${CRAWL_GUILD_JSON//\'/\'\'}"
    if [ "${CRAWL_GUILD_ID}" = "${GUILD_ID}" ]; then
      THIS_INFRASTRUCTURE="true"
    else
      THIS_INFRASTRUCTURE="false"
    fi
    echo "select structs.GUILD_METADATA_UPDATE('${CRAWL_GUILD_ID}','${CRAWL_GUILD_JSON}', ${THIS_INFRASTRUCTURE});" > crawl_endpoint_query.sql.tmp
    psql $DATABASE_URL -f crawl_endpoint_query.sql.tmp  --no-align -t
    rm crawl_endpoint_query.sql.tmp

  done

  sleep $CRAWL_SLEEP
  echo "CRAWLER ($BASHPID): Awaking from slumber"
done


