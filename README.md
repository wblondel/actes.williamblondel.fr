# actes.williamblondel.fr

Add a URL:
```shell
curl -X PUT -H "Content-Type: application/json" -d '{"input":"/perdu","outputs":["https://perdu.com"]}' http://127.0.0.1:2019/config/apps/http/servers/srv0/routes/0/handle/0/routes/0/handle/0/mappings/0
```

Show the config:
```shell
curl "http://127.0.0.1:2019/config/" | jq
```
