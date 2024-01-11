# Raccourcisseur d'URL Caddy

[![en](https://img.shields.io/badge/lang-en-red.svg)](../../../README.md)
[![fr](https://img.shields.io/badge/lang-fr-blue.svg)](./README.md)


Ce dépôt contient la configuration de mon raccourcisseur d'URL / réducteur de lien, qui fonctionne seulement avec le serveur [Caddy](https://caddyserver.com/). J'utilise mon raccourcisseur principalement pour avoir des liens propres dans mes fichiers généalogiques.

## Comment fonctionne-t-il ?

Le service est déployé sur [Fly.io](https://fly.io) et son lien public est https://actes.williamblondel.fr.

Lors du déploiement, Fly crée une image Docker basée sur [l'image Docker officielle de Caddy](https://hub.docker.com/_/caddy).
Caddy est configuré pour charger la configuration [conf/caddy-config-loader.json](../../../conf/caddy-config-loader.json) au démarrage.

Cette configuration indique à Caddy [de charger via HTTP](https://caddyserver.com/docs/modules/caddy.config_loaders.http) la configuration située dans [conf/caddy-config.json](../../../conf/caddy-config.json), qui contient les liens définis.

Les liens sont gérés via l'[API Caddy](https://caddyserver.com/docs/api), exclusivement via le [Makefile](../../../Makefile).

Toutes les 30 minutes, un [workflow](../../../.github/workflows/backup-caddy-config.yml) récupère la configuration actuelle de Caddy et la soumet dans le dépôt si des modifications ont été détectées.
Cela évite la perte de la configuration lors du redémarrage de la machine ou de Caddy.

## Utilisation

Le CLI [Fly.io](https://fly.io/docs/hands-on/install-flyctl/) est requis.

Pour obtenir la liste des commandes disponibles, exécutez `make help` (ou `make`).

### Raccourcir une URL
```sh
make short \
  url=https://example.org \
  shortcode=shortcode_optionnel \
  title="Titre de la page"
```

Cette commande vous permet to créer un lien vers une `url` spécifique. Un `shortcode` peut être fourni, sinon il sera généré automatiquement.

Un titre (`title`) est requis. Il sera encodé en [Base64URL](https://base64.guru/standards/base64url) et stocké dans le [champ `@id`](https://caddyserver.com/docs/api#using-id-in-json).

### Supprimer une URL
```sh
make delete id="VGVzdCBQYWdl"
```

Cette commande vous permet de supprimer une URL par son `id`. L'`id` est le titre encodé, pas le `shortcode`.

### Afficher la configuration de Caddy
```sh
make show_config
```

Cette commande affiche joliment la configuration de Caddy sous format JSON.

###  Afficher la liste des URLs
```sh
make output_format=table print_routes
```

Cette commande affiche la liste des liens définis dans la configuration de Caddy.

La variable `output_format` est facultative et sa valeur par défaut est `json`, qui affiche joliment le JSON.
Les formats de sortie disponibles sont `json`, `table` et `csv`.

### Redémarrer l'application Fly.io
```sh
make restart_app
```

Cette commande redémarre l'application Fly.io.

### Arrêter Caddy
```sh
make stop_caddy
```

Cette commande arrête progressivement Caddy et quitte le processus.
Du fait de la configuration de Fly.io, l'application redémarre automatiquement.

## TODO
- [ ] Pouvoir supprimer une URL par son shortcode