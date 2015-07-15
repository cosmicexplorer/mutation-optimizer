.PHONY: all clean distclean
.DELETE_ON_ERROR:

NODE_DIR := node_modules

# node binaries
NPM_BIN = $(shell npm bin)
CJSX_CC = $(NPM_BIN)/cjsx
COFFEE_CC = $(NPM_BIN)/coffee
LESS_CC = $(NPM_BIN)/lessc
UGLIFY_JS = $(NPM_BIN)/uglifyjs
BROWSERIFY = $(NPM_BIN)/browserify
CLEAN_CSS = $(NPM_BIN)/cleancss

UGLIFY_JS_OPTS := -mc --screw-ie8

# external js
REACT_JS := react
EXTERN_JS := $(REACT_JS) $(FUSE_JS)

BOOTSTRAP := bootstrap
FONT_AWESOME := font-awesome
EXTERN_CSS := $(BOOTSTRAP) $(FONT_AWESOME)

EXTERN_JS_PROOFS := $(patsubst %,$(NODE_DIR)/%/README.md,$(EXTERN_JS))
EXTERN_CSS_PROOFS := $(patsubst %,$(NODE_DIR)/%/README.md,$(EXTERN_CSS))

# make deps
DEPS := $(CJSX_CC) $(LESS_CC) $(UGLIFY_JS) $(BROWSERIFY) $(CLEAN_CSS) \
	$(COFFEE_CC) $(EXTERN_JS_PROOFS)

# input/output files
# github pages sucks
SRC_DIR := .
SCRIPTS_DIR := $(SRC_DIR)/scripts
STYLES_DIR := $(SRC_DIR)/styles

CJSX_IN := $(wildcard $(SCRIPTS_DIR)/*.cjsx)
COFFEE_IN := $(wildcard $(SCRIPTS_DIR)/*.coffee)
COFFEE_OPTS := -bc --no-header
JS_OUT := $(patsubst %.cjsx,%.js,$(CJSX_IN)) \
	$(patsubst %.coffee,%.js,$(COFFEE_IN))
JS_FINAL := $(SCRIPTS_DIR)/bundle.js

LESS_IN := $(wildcard $(STYLES_DIR)/*.less)
CSS_OUT := $(patsubst %.less,%.css,$(LESS_IN))

# browserify
BROWSERIFY_EXTERN_REQUIRE := $(patsubst %,-r %,$(EXTERN_JS))
BROWSERIFY_EXTERN_NOREQ := $(patsubst %,-x %,$(EXTERN_JS))
BROWSERIFY_EXTERN_BUNDLE := $(SCRIPTS_DIR)/vendor.js

# declarations
TARGETS := $(JS_FINAL) $(CSS_OUT) $(BROWSERIFY_EXTERN_BUNDLE)

all: $(TARGETS)

$(JS_FINAL): $(JS_OUT) $(BROWSERIFY) $(UGLIFY_JS)
	$(BROWSERIFY) $(BROWSERIFY_EXTERN_NOREQ) $(JS_OUT) | \
		$(UGLIFY_JS) $(UGLIFY_JS_OPTS) -o $@

$(BROWSERIFY_EXTERN_BUNDLE): $(BROWSERIFY) $(EXTERN_JS_PROOFS) $(UGLIFY_JS)
	$(BROWSERIFY) $(BROWSERIFY_EXTERN_REQUIRE) | \
		$(UGLIFY_JS) $(UGLIFY_JS_OPTS) -o $@

%.js: %.coffee $(COFFEE_CC)
	$(COFFEE_CC) $(COFFEE_OPTS) $<

%.js: %.cjsx $(CJSX_CC)
	$(CJSX_CC) $(COFFEE_OPTS) $<

%.css: %.less $(LESS_CC) $(CLEAN_CSS)
	$(LESS_CC) $< | $(CLEAN_CSS) -o $@

clean:
	rm -f $(TARGETS) $(JS_OUT)

$(DEPS):
	npm install

distclean: clean
	rm -rf $(NODE_DIR)
