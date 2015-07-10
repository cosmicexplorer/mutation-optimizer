.PHONY: all clean distclean
.DELETE_ON_ERROR:

NODE_DIR := node_modules

# node binaries
NPM_BIN = $(shell npm bin)
CJSX_CC = $(NPM_BIN)/cjsx
LESS_CC = $(NPM_BIN)/lessc
UGLIFY_JS = $(NPM_BIN)/uglifyjs
BROWSERIFY = $(NPM_BIN)/browserify

UGLIFY_JS_OPTS := -mc --screw-ie8

# external js
REACT_JS := react
EXTERN_JS := $(REACT_JS)

EXTERN_JS_PROOFS := $(patsubst %,$(NODE_DIR)/%,$(EXTERN_JS))

# make deps
DEPS := $(CJSX_CC) $(LESS_CC) $(UGLIFY_JS) $(BROWSERIFY) $(EXTERN_JS_PROOFS)

# input/output files
SRC_DIR := src
SCRIPTS_DIR := $(SRC_DIR)/scripts
STYLES_DIR := $(SRC_DIR)/styles

CJSX_IN := $(wildcard $(SCRIPTS_DIR)/*.cjsx)
JS_OUT := $(patsubst %.cjsx,%.js,$(CJSX_IN))
.INTERMEDIATE: $(JS_OUT) # this shouldn't be necessary, but whatever
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

$(JS_FINAL): $(JS_OUT) $(DEPS)
	$(BROWSERIFY) $(BROWSERIFY_EXTERN_NOREQ) $(JS_OUT) | \
		$(UGLIFY_JS) $(UGLIFY_JS_OPTS) -o $@

$(BROWSERIFY_EXTERN_BUNDLE): $(DEPS)
	$(BROWSERIFY) $(BROWSERIFY_EXTERN_REQUIRE) | \
		$(UGLIFY_JS) $(UGLIFY_JS_OPTS) -o $@

%.js: %.cjsx $(CJSX_CC) $(DEPS)
	$(CJSX_CC) -bc --no-header $<

%.css: %.less $(LESS_CC) $(DEPS)
	$(LESS_CC) -x --clean-css $< > $@

clean:
	rm -f $(TARGETS)

$(DEPS):
	npm install

distclean: clean
	rm -rf $(NODE_DIR)
