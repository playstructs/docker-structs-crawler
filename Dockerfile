# Base image
FROM ubuntu:24.04

# Information
LABEL maintainer="Slow Ninja <info@slow.ninja>"

# Variables
ENV DEBIAN_FRONTEND=noninteractive

# Install packages
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
        postgresql-common \
        git \
        curl \
        wget \
        jq



RUN  sed -i "s/read enter//g" /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh
RUN  cat /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh && \
     /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh && \
     apt-get -y install postgresql-client


RUN  rm -rf /var/lib/apt/lists/*


# Add the user and groups appropriately
RUN addgroup --system structs && \
    adduser --system --home /src/structs --shell /bin/bash --group structs


# Setup the scripts
WORKDIR /src
RUN chown -R structs /src/structs
COPY scripts/* /src/structs/
RUN chmod a+x /src/structs/*

RUN mkdir /var/structs && \
    mkdir /var/structs/bin

# Run Structs
CMD [ "/src/structs/crawler.sh" ]
