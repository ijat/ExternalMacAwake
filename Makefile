.PHONY: help build test lint format bundle zip run install preview clean

APP := build/ExternalMacAwake.app
PREVIEW_DIR ?= build/preview

help: ## List targets
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  %-10s %s\n", $$1, $$2}'

build: ## Debug build
	swift build

test: ## Run the unit tests
	swift test

lint: ## Check formatting with swift-format (strict)
	swift format lint --strict -r Sources Tests

format: ## Format the sources in place
	swift format -i -r Sources Tests

bundle: ## Build the universal, ad-hoc signed .app into build/
	scripts/bundle.sh

zip: ## Like bundle, plus build/ExternalMacAwake-<version>.zip
	scripts/bundle.sh --zip

run: bundle ## Build and open the app
	open $(APP)

install: bundle ## Copy the app to ~/Applications
	mkdir -p $(HOME)/Applications
	rm -rf $(HOME)/Applications/ExternalMacAwake.app
	cp -R $(APP) $(HOME)/Applications/
	@echo "Installed to $(HOME)/Applications/ExternalMacAwake.app"

preview: ## Render the popover to PNGs in build/preview (offscreen)
	swift run ExternalMacAwake --render-preview $(PREVIEW_DIR)

clean: ## Remove build output
	rm -rf build .build
