.PHONY: test install

test:
	node --test tests/test_status_line.js

install:
	bash install.sh
