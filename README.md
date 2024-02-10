# Caddy-only go-link/URL shortener service

[![en](https://img.shields.io/badge/lang-en-red.svg)](./README.md)
[![fr](https://img.shields.io/badge/lang-fr-blue.svg)](./docs/i18n/fr/README.md)


This repository holds the configuration of my [Caddy](https://caddyserver.com/)-only go-link service, used to have clean links in my genealogy data.
    
## How does it work?

The service is deployed on [Fly.io](https://fly.io) and its public URL is https://actes.williamblondel.fr.

Upon deployment, Fly builds a Docker image based on the [official Caddy's Docker image](https://hub.docker.com/_/caddy).
Caddy is configured to load the [conf/caddy-config-loader.json](conf/caddy-config-loader.json) configuration on start up.

This configuration tells Caddy [to load via HTTP](https://caddyserver.com/docs/modules/caddy.config_loaders.http) the configuration located at [conf/caddy-config.json](conf/caddy-config.json), which contains the defined links. 

The links are managed via the [Caddy API](https://caddyserver.com/docs/api), exclusively through the [Makefile](Makefile).

Every 30 minutes, a [workflow](.github/workflows/backup-caddy-config.yml) fetches the current Caddy configuration and commits it to the repository if changes were detected.
This prevents the configuration from being lost when restarting the machine or Caddy. 

## Usage

The [Fly.io](https://fly.io/docs/hands-on/install-flyctl/) CLI is required.

To get the list of available commands, execute `make help` (or `make`).

### Shorten a URL
```sh
make short \
  url=https://example.org \
  shortcode=optional_shortcode \
  title="Page title"
```

This command allows you to create a go link to a specific `url`. A `shortcode` can be provided, otherwise it will be generated automatically.

A `title` is required. It will be encoded to [Base64URL](https://base64.guru/standards/base64url) and saved into the [`@id` field](https://caddyserver.com/docs/api#using-id-in-json).

### Delete a URL
```sh
make delete id="VGVzdCBQYWdl"
```
or
```sh
make delete shortcode="62f21770"
```

This command allows you to delete a URL by its `id` (the encoded title) or by its `shortcode`.

### Show the Caddy configuration
```sh
make show_config
```

This command pretty prints the JSON full Caddy configuration.

###  Show the list of routes
```sh
make output_format=table show_routes
```

This command shows the list of routes defined in the Caddy configuration.

The `output_format` variable is optional and defaults to `json`, which pretty prints the JSON.
Available output formats are `json`, `table`, and `csv`.

### Restart the Fly.io application
```sh
make restart_app
```

This command restarts the Fly.io application.

### Shut down Caddy
```sh
make stop_caddy
```

This command gracefully shuts down Caddy and exits the process.
Because of the Fly.io configuration, the application restarts automatically.
