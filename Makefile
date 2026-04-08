.PHONY: test install install-win

test:
	node --test tests/test_status_line.js

install:
	bash install.sh

install-win:
	powershell -ExecutionPolicy Bypass -File install.ps1