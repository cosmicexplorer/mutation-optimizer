.PHONY: all clean distclean
.DELETE_ON_ERROR:

NODE_DIR := node_modules

# node binaries
NPM_BIN = $(shell npm bin)
CJSX_CC = $(NPM_BIN)/cjsx
LESS_CC = $(NPM_BIN)/lessc
UGLIFY_JS = $(NPM_BIN)/uglifyjs
BROWSERIFY = $(NPM_BIN)/browserify

# external js
REACT_JS := react

# make deps
DEPS := $(CJSX_CC) $(LESS_CC) $(UGLIFY_JS) $(BROWSERIFY) $(REACT_JS)

# input/output files
SRC_DIR := src
SCRIPTS_DIR := $(SRC_DIR)/scripts
STYLES_DIR := $(SRC_DIR)/styles

CJSX_IN := $(wildcard $(SCRIPTS_DIR)/*.cjsx)
JS_OUT := $(patsubst %.cjsx,%.js,$(CJSX_IN))
JS_FINAL := $(SCRIPTS_DIR)/bundle.js

LESS_IN := $(wildcard $(STYLES_DIR)/*.less)
CSS_OUT := $(patsubst %.less,%.css,$(LESS_IN))

all: $(JS_FINAL) $(CSS_OUT)

# add -r to browserify for any external js
$(JS_FINAL): $(JS_OUT)
	$(BROWSERIFY) -r $(REACT_JS) $(JS_OUT) | \
		$(UGLIFY_JS) -mc --screw-ie8 -o $@

%.js: %.cjsx $(CJSX_CC)
	$(CJSX_CC) -bc --no-header $<

%.css: %.less $(LESS_CC)
	$(LESS_CC) -x --clean-css $< > $@

clean:
	rm -f $(JS_OUT) $(CSS_OUT)

$(DEPS):
	npm install

distclean: clean
	rm -rf $(NODE_DIR)
