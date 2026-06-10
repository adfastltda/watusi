clone:
	@echo "Cloning IPA..."
	@echo ""
	if [ ! -f "source/whatsapp.ipa" ]; then \
		echo "Downloading IPA..."; \
		make download; \
	fi
	bash scripts/clone_ipa.sh

release:
	@echo "Creating release..."
	@echo ""
	if [ ! -d "clones" ]; then \
		echo "No clones found. Run 'make clone' first."; \
		exit 1; \
	fi
	bash scripts/create_release.sh
	@echo "Release created successfully!"
	@echo ""
	make clean;
	@echo "Archive cleaned up!"

json:
	@echo "Generating apps.json..."
	if [ ! -d "clones" ]; then \
		echo "No clones found. Run 'make clone' first."; \
		exit 1; \
	fi
	bash scripts/generate_apps_json.sh

clean:
	@echo "Cleaning up..."
	if [ -d "clones" ]; then \
		rm -rf clones/*; \
	fi
	if [ -d "source" ]; then \
		rm -rf source/*; \
	fi

download:
	rm -f source/whatsapp.ipa
	@echo "Downloading IPA..."
	if [ ! -d "source" ]; then \
		mkdir source; \
	fi
	if [ ! -f "source/whatsapp.ipa" ]; then \
		wget $(shell cat .magiclink) -O source/whatsapp.ipa; \
	fi
