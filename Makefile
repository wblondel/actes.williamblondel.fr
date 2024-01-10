.DEFAULT_GOAL := help

# Function to encode a string to base64url
base64url_encode = $(shell printf '%s' '$1' | openssl base64 -e -A | tr '+/' '-_' | tr -d '=')

.PHONY: all
all:

.PHONY: short # Shorten a URL
short:
ifndef url
	$(error url is undefined)
endif
ifndef shortcode
	$(eval shortcode := $(shell dd if=/dev/urandom bs=4 count=2 2>/dev/null | xxd -p -c 4 | tr -dc 'a-zA-Z0-9' | head -c 8))
endif
ifndef title
	$(error title is undefined)
endif
	$(eval encoded_title := $(call base64url_encode,$(title)))

	@echo "Shortcode: $(shortcode)..."
	@echo "Encoded title: $(encoded_title)"
	@flyctl ssh console --command "curl -X PUT -H 'Content-Type: application/json' -d '{\"@id\":\"$(encoded_title)\",\"input\":\"/$(shortcode)\",\"outputs\":[\"$(url)\"]}' http://127.0.0.1:2019/config/apps/http/servers/srv0/routes/0/handle/0/routes/0/handle/0/mappings/0"
	@echo "https://actes.williamblondel.fr/$(shortcode)"

.PHONY: delete # Delete a URL by ID
delete:
ifndef id
	$(error id is undefined)
endif
	@echo "Deleting route with ID $(id)"
	@flyctl ssh console --command "curl -X DELETE -H 'Content-Type: application/json' http://127.0.0.1:2019/id/$(id)"

.PHONY: restart
restart:
	@flyctl apps restart

.PHONY: reload
reload:
	@flyctl ssh console --command "curl -X POST http://localhost:2019/stop"

.PHONY: print_config
print_config:
	@flyctl ssh console --quiet --command "curl -s http://127.0.0.1:2019/config" | jq

.PHONY: print_routes
print_routes:
	@flyctl ssh console --quiet --command "curl -s http://127.0.0.1:2019/config/apps/http/servers/srv0/routes/0/handle/0/routes/0/handle/0/mappings" | jq

.PHONY: help # List available commands
help:
	@echo "Available commands:"
	@echo
	@grep '^.PHONY: .* #' Makefile | sed 's/\.PHONY: \(.*\) # \(.*\)/\1 >> \2/' | expand -t20
