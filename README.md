# Toybox PHP App Base

This is the environment for PHP Application based on Docker containers.
docker-compose.yml that is included this repository will start enginx, PHP-FPM and MariaDB container.
This is also included WordPress installer, so you can work with WordPress very easyly.

## Requirements
* docker
* docker-compose

## Getting started

### Installation

Download the latest release of toybox-app-php.

```
$ cd /path/to/download
$ git clone https://github.com/nutsllc/toybox-app-php.git
```
### Settings

Copy ``path/to/download/toybox-app-php/bin/.env.example`` to the same directory as ``.env``.
Edit ``.env`` file.  example below.

```bash
# ---------------------------------------------
# Application Settings
# ---------------------------------------------
REPOSITORY_ROOT=/path/to/download/toybox-app-php
TOYBOX_UID=1000
TOYBOX_GID=1000
```

```bash
# ---------------------------------------------
# Nginx(Web Server) settings
# ---------------------------------------------
SITE_URL=www.sample.com
LETSENCRYPT_EMAIL=sample@sample.com
PROXY_CACHE=true
```

```bash
# ---------------------------------------------
# DB settings
# ---------------------------------------------
DB_ROOT_PASSWORD=root
DB_NAME=wordpress
DB_USER=sakura
DB_PASSWORD=sakura_password
DB_TABLE_PREFIX=wp_
```

### Usage

#### Start Container
```bash
$ cd toybox-app-php/bin
$ docker-compose up -d
```

#### Installing WordPress
```bash
$ cd toybox-app-php/bin
$ rm -rf data/nginx/*
$ sh install_wordpress.sh
```
