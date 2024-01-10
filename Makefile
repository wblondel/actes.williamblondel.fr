.DEFAULT_GOAL := help

MAPPINGS_ROUTE := "/config/apps/http/servers/srv0/routes/0/handle/0/routes/0/handle/0/mappings"

include .env
export

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
	@flyctl ssh console --command "curl -X PUT -H 'Content-Type: application/json' -d '{\"@id\":\"$(encoded_title)\",\"input\":\"/$(shortcode)\",\"outputs\":[\"$(url)\"]}' $(CADDY_ADMIN_API)$(MAPPINGS_ROUTE)/0"
	@echo "$(APP_URL)/$(shortcode)"

.PHONY: delete # Delete a URL by ID
delete:
ifndef id
	$(error id is undefined)
endif
	@echo "Deleting route with ID $(id)"
	@flyctl ssh console --command "curl -X DELETE -H 'Content-Type: application/json' $(CADDY_ADMIN_API)/id/$(id)"

.PHONY: restart
restart:
	@flyctl apps restart

.PHONY: reload
reload:
	@flyctl ssh console --command "curl -X POST $(CADDY_ADMIN_API)/stop"

.PHONY: print_config
print_config:
	@flyctl ssh console --quiet --command "curl -s $(CADDY_ADMIN_API)/config/" | jq

.PHONY: print_routes
print_routes:
ifndef output_format
	@flyctl ssh console --quiet --command "curl -s $(CADDY_ADMIN_API)$(MAPPINGS_ROUTE)" | jq
else
ifeq ($(output_format),json)
	@flyctl ssh console --quiet --command "curl -s $(CADDY_ADMIN_API)$(MAPPINGS_ROUTE)" | jq
else ifeq ($(output_format),table)
	@flyctl ssh console --quiet --command "curl -s $(CADDY_ADMIN_API)$(MAPPINGS_ROUTE)" | jq -r '["@id", "input", "outputs"], (.[] | [.["@id"], .input, .outputs[]]) | @tsv' | column -t
else ifeq ($(output_format),csv)
	@flyctl ssh console --quiet --command "curl -s $(CADDY_ADMIN_API)$(MAPPINGS_ROUTE)" | jq -r '["@id", "input", "outputs"], (.[] | [.["@id"], .input, .outputs[]]) | @csv'
else
	@echo "Invalid output format: $(output_format)"
	@echo "Should be json or table"
endif
endif

.PHONY: help # List available commands
help:
	@echo "Available commands:"
	@echo
	@grep '^.PHONY: .* #' Makefile | sed 's/\.PHONY: \(.*\) # \(.*\)/\1 >> \2/' | expand -t20
