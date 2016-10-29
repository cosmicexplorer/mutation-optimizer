.PHONY: all clean distclean
.DELETE_ON_ERROR:

NODE_DIR := node_modules
NPM_BIN := $(NODE_DIR)/.bin
COFFEE_CC := $(NPM_BIN)/coffee

in := $(wildcard *.coffee)
bin := $(patsubst %.coffee,%,$(in))

all: $(bin)

%: %.coffee $(COFFEE_CC)
	echo "#!/usr/bin/env node" > $@
	$(COFFEE_CC) -bcp --no-header $< >> $@
	chmod +x $@

clean:
	rm -f $(bin)

distclean: clean
	rm -rf $(NODE_DIR)

$(COFFEE_CC):
	npm install
