SOURCE="./web"
DESTINATION="./iOS/Eisenstein/web"

# ---------------------------------------------------------------------------

build:
	rm -rf $(DESTINATION)
	mkdir -p $(DESTINATION)

	cp $(SOURCE)/index.html $(DESTINATION)/index.html
	cp -r $(SOURCE)/css $(DESTINATION)
	cp -r $(SOURCE)/images $(DESTINATION)
	cp -r $(SOURCE)/js $(DESTINATION)
	cp -r $(SOURCE)/media $(DESTINATION)
	# cp -r $(SOURCE)/sounds $(DESTINATION)

	mkdir -p $(DESTINATION)/lib
	mkdir -p $(DESTINATION)/lib/blocks
	mkdir -p $(DESTINATION)/lib/closure-library
	mkdir -p $(DESTINATION)/lib/vm/dist/web/
	# mkdir -p $(DESTINATION)/lib/audio

	cp -r $(SOURCE)/lib/blocks $(DESTINATION)/lib
	cp -r $(SOURCE)/lib/closure-library/closure $(DESTINATION)/lib/closure-library
	cp $(SOURCE)/lib/vm/dist/web/scratch-vm.js $(DESTINATION)/lib/vm/dist/web/scratch-vm.js
	cp $(SOURCE)/lib/vm/dist/web/scratch-vm.min.js $(DESTINATION)/lib/vm/dist/web/scratch-vm.min.js
	# cp -r $(SOURCE)/lib/audio/audio.js $(DESTINATION)/lib/audio
	rm -rf $(DESTINATION)/lib/blocks/gh-pages
	rm -rf $(DESTINATION)/lib/blocks/node_modules

clean:
	rm -rf $(DESTINATION)

# ---------------------------------------------------------------------------

.PHONY: build clean
