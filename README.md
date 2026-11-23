# docker-structs-crawler
**docker-structs-crawler** is a small agent that crawls across the Structs universe.

Most players within the Structs ecosystem will not need to operate the code in this repository.

## Guild webapp

The crawler reads the browser interface from `guild.webapp` in `guild.json`:

```json
{
  "guild": {
    "webapp": "https://guild.example/",
    "language": "EN"
  }
}
```

The crawler passes this document to `structs.guild_metadata_update`, which stores
`guild.webapp` in `structs.guild_meta.webapp` on insert and update. Values are
preserved as advertised, including hostnames without a URL scheme. An absent or
JSON-null webapp clears the column to SQL NULL.

Deploy the structs-pg `guild-meta-webapp-20261123` migration to enable this
mapping. It marks cached metadata stale so the next crawl populates the new
column. The crawler checks every two minutes for new or changed endpoints and
refreshes metadata older than one day to discover edits to the document itself.

## Guild language

`guild.language` is stored in `structs.guild_meta.language` on each crawl.
Missing, JSON-null, empty, or space-only values default to `EN`. Other values
are stored with surrounding spaces trimmed. The database column also defaults
to `EN` for direct inserts.

Deploy `guild-meta-language-20261123` after the webapp migration. Existing rows
start with `EN` and are marked stale so the next crawl reads their advertised
language. No additional crawler parsing is required: it passes the full guild
JSON to the database metadata updater.

## Structs
In the distant future the species of the galaxy are embroiled in a race for Alpha Matter, the rare and dangerous substance that fuels galactic civilization. Players take command of Structs, a race of sentient machines, and must forge alliances, conquer enemies and expand their influence to control Alpha Matter and the fate of the galaxy.

[Structs](https://playstructs.com) is a decentralized game in the Cosmos ecosystem, operated and governed by our community of players--ensuring Structs remains online as long as there are players to play it.


## Learn more

- [Structs](https://playstructs.com)
- [Project Wiki](https://watt.wiki)
- [@PlayStructs Twitter](https://twitter.com/playstructs)


## License

Copyright 2021 [Slow Ninja Inc](https://slow.ninja).

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.