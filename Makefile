.PHONY: clone build release json clean download

clone:
	@echo "Cloning IPA..."
	@echo ""
	@if ! find source -maxdepth 1 -name '*.ipa' -print -quit 2>/dev/null | grep -q .; then \
		echo "Downloading IPA..."; \
		$(MAKE) download; \
	fi
	bash scripts/clone_ipa.sh

build:
	@echo "Building clones and apps.json..."
	@echo ""
	$(MAKE) clone
	$(MAKE) json

release: build
	@echo "Creating release..."
	@echo ""
	bash scripts/create_release.sh
	@echo "Release created successfully!"
	@echo ""
	$(MAKE) clean
	@echo "Archive cleaned up!"
	@echo "Updating version in README.md..."
	sed -Ei "s|https://raw.githubusercontent.com/adfastltda/watusi/v[0-9]+\.[0-9]+\.[0-9]+/apps\.json|https://raw.githubusercontent.com/adfastltda/watusi/v$(shell cat VERSION)/apps.json|g" README.md
	@echo "Pushing to GitHub..."
	git add .
	git commit -m "release $(shell cat VERSION)"
	git push

json:
	@echo "Generating apps.json..."
	@if [ ! -d "clones" ]; then \
		echo "No clones found. Run 'make clone' first."; \
		exit 1; \
	fi
	bash scripts/generate_apps_json.sh

clean:
	@echo "Cleaning up..."
	@if [ -d "clones" ]; then \
		rm -rf clones/*; \
	fi
	@if [ -d "source" ]; then \
		rm -rf source/*; \
	fi

download:
	@echo "Downloading IPA..."
	@if [ ! -d "source" ]; then \
		mkdir source; \
	fi
	@if [ ! -f "source/whatsapp.ipa" ]; then \
		wget $(shell cat .magiclink) -O source/whatsapp.ipa; \
	fi
