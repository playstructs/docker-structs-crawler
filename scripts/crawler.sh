#!/usr/bin/env bash

CRAWL_SLEEP=120

echo "Loading The Crawler"

while :
do
  # Get latest guild updates
  echo "CRAWLER ($BASHPID): ${PENDING_TRANSACTION_COUNT} Checking for updated endpoints "

  # select
  #   to_json(guild.*)
  # from
  #   structs.guild
  # where
  #   exists (select 1 from structs.guild_meta where guild.id = guild_meta.id and guild.updated_at > guild_meta.updated_at)
  #   or (
  #     endpoint is not null
  #     and not exists (select 1 from guild_meta where guild_meta.id = guild.id)
  #   );

  # TODO Alter the above query to also grab stale meta_data rows. Maybe a day old?

  CRAWL_JSON=$(psql $DATABASE_URL -c 'with g as (select guild.id, guild.endpoint from structs.guild where exists (select 1 from structs.guild_meta where guild.id = guild_meta.id and guild.updated_at > guild_meta.updated_at) or (endpoint is not null and not exists (select 1 from guild_meta where guild_meta.id = guild.id))) select jsonb_agg(g.*) from g;' --no-align -t)
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
    CRAWL_GUILD_JSON=$( cat crawl_endpoint_data.json.tmp | jq -c .)
    rm crawl_endpoint_data.json.tmp

    # Update Guild
    echo "select structs.GUILD_METADATA_UPDATE('${CRAWL_GUILD_ID}','${CRAWL_GUILD_JSON}');" > crawl_endpoint_query.sql.tmp
    psql $DATABASE_URL -f crawl_endpoint_query.sql.tmp  --no-align -t
    rm crawl_endpoint_query.sql.tmp

  done

  sleep $CRAWL_SLEEP
  echo "CRAWLER ($BASHPID): Awaking from slumber"
done


