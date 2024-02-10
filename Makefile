.DEFAULT_GOAL := help
MAPPINGS_ROUTE := "/config/apps/http/servers/srv0/routes/0/handle/0/routes/0/handle/0/mappings"
# Thank you Renaud Pacalet!
# @see https://stackoverflow.com/a/53865416/2699597
NULL :=
TAB := $(NULL)	$(NULL)

include .env
export

base64url_encode = $(shell printf '%s' "$1" | base64 | tr '/+' '_-' | tr -d '=')

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
	@flyctl ssh console --command "curl -s -X PUT -H 'Content-Type: application/json' -d '{\"@id\":\"$(encoded_title)\",\"input\":\"/$(shortcode)\",\"outputs\":[\"$(url)\"]}' $(CADDY_ADMIN_API)$(MAPPINGS_ROUTE)/0"
	@echo "$(APP_URL)/$(shortcode)"

.PHONY: delete # Delete a URL by ID or shortcode
delete:
ifdef id
	@echo "Deleting route with ID $(id)"
	@flyctl ssh console --command "curl -s -X DELETE -H 'Content-Type: application/json' $(CADDY_ADMIN_API)/id/$(id)"
else ifdef shortcode
	@echo "Fetching route..."
	@make shortcode= id=$$(flyctl ssh console --quiet --command "curl -s $(CADDY_ADMIN_API)$(MAPPINGS_ROUTE)" | jq -r '.[] | select(.["input"] == "/$(shortcode)") | .["@id"]') delete
else
	$(error id or shortcode should be defined)
endif

.PHONY: show_config # Show the Caddy configuration
show_config:
	@flyctl ssh console --quiet --command "curl -s $(CADDY_ADMIN_API)/config/" | jq

.PHONY: show_routes # Show the list of routes (JSON, CSV or table format)
show_routes:
ifndef output_format
	@flyctl ssh console --quiet --command "curl -s $(CADDY_ADMIN_API)$(MAPPINGS_ROUTE)" | jq
else
ifeq ($(output_format),json)
	@flyctl ssh console --quiet --command "curl -s $(CADDY_ADMIN_API)$(MAPPINGS_ROUTE)" | jq
else ifeq ($(output_format),table)
	@flyctl ssh console --quiet --command "curl -s $(CADDY_ADMIN_API)$(MAPPINGS_ROUTE)" | \
		jq -r 'map(.["@id"] |= @base64d) | ["@id", "input", "outputs"], (.[] | [.["@id"], .input, .outputs[]]) | @tsv' | \
		column -t -s'$(TAB)'
else ifeq ($(output_format),csv)
	@flyctl ssh console --quiet --command "curl -s $(CADDY_ADMIN_API)$(MAPPINGS_ROUTE)" | \
		jq -r 'map(.["@id"] |= @base64d) | ["@id", "input", "outputs"], (.[] | [.["@id"], .input, .outputs[]]) | @csv'
else
	@echo "Invalid output format: $(output_format)"
	@echo "Should be json, table, or csv"
endif
endif

.PHONY: restart_app # Restart the app
restart_app:
	@flyctl apps restart

.PHONY: stop_caddy # Gracefully shut down Caddy and exit the process
stop_caddy:
	@flyctl ssh console --command "curl -X POST $(CADDY_ADMIN_API)/stop"

.PHONY: help # List available commands
help:
	@echo "Available commands:"
	@echo
	@grep '^.PHONY: .* #' Makefile | sed 's/\.PHONY: \(.*\) # \(.*\)/\1 >> \2/' | expand -t20
