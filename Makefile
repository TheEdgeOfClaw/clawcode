SYSTEMD_DIR = $(HOME)/.config/systemd/user
SERVICES = opencode-server.service

.PHONY: install uninstall lint typecheck check install-opencode install-plugin

OPENCODE_WORKSPACE ?= $(shell grep '^OPENCODE_WORKSPACE=' .env 2>/dev/null | cut -d= -f2)
$(if $(OPENCODE_WORKSPACE),,$(error OPENCODE_WORKSPACE is not set))
SERVER_WORKDIR = $(OPENCODE_WORKSPACE)

install: install-opencode install-plugin
	mkdir -p $(SYSTEMD_DIR)
	sed 's|{{WORKDIR}}|$(SERVER_WORKDIR)|g' opencode-server.service > $(SYSTEMD_DIR)/opencode-server.service
	systemctl --user daemon-reload

install-opencode:
	cp -r .opencode/. $(SERVER_WORKDIR)/.opencode/

install-plugin:
	ln -sf $(CURDIR)/src/main.ts $(SERVER_WORKDIR)/.opencode/plugins/clawcode.ts

uninstall:
	systemctl --user disable --now $(SERVICES) 2>/dev/null || true
	rm -f $(addprefix $(SYSTEMD_DIR)/,$(SERVICES))
	rm -f $(SERVER_WORKDIR)/.opencode/plugins/clawcode.ts
	systemctl --user daemon-reload

lint:
	bun run lint

typecheck:
	bun run typecheck

check: lint typecheck
