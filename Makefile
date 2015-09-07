.PHONY: all clean distclean
.DELETE_ON_ERROR:

NODE_DIR := node_modules

# node binaries
NPM_BIN := $(NODE_DIR)/.bin
CJSX_CC := $(NPM_BIN)/cjsx
COFFEE_CC := $(NPM_BIN)/coffee
LESS_CC := $(NPM_BIN)/lessc
UGLIFY_JS := $(NPM_BIN)/uglifyjs
BROWSERIFY := $(NPM_BIN)/browserify
CLEAN_CSS := $(NPM_BIN)/cleancss
MAKE_PIPE := $(NPM_BIN)/make-pipe

COFFEE_OPTS := -bc --no-header
UGLIFY_JS_OPTS := -mc --screw-ie8 2>/dev/null

# external js
REACT_JS := react
EXTERN_JS := $(REACT_JS)

# external css
BOOTSTRAP := bootstrap
FONT_AWESOME := font-awesome
EXTERN_CSS := $(BOOTSTRAP) $(FONT_AWESOME)

# deps that make can consume
EXTERN_JS_PROOFS := $(patsubst %,$(NODE_DIR)/%,$(EXTERN_JS))
EXTERN_CSS_PROOFS := $(patsubst %,$(NODE_DIR)/%,$(EXTERN_CSS))

DEPS := $(CJSX_CC) $(LESS_CC) $(UGLIFY_JS) $(BROWSERIFY) $(CLEAN_CSS) \
	$(COFFEE_CC) $(EXTERN_JS_PROOFS)

# input/output files
# github pages sucks
SRC_DIR := .
SCRIPTS_DIR := $(SRC_DIR)/scripts
STYLES_DIR := $(SRC_DIR)/styles
LIB_DIR := $(SRC_DIR)/lib
BIOBRICK_DIR := $(SRC_DIR)/biobrick

CJSX_IN := $(wildcard $(SCRIPTS_DIR)/*.cjsx)
COFFEE_IN := $(wildcard $(SCRIPTS_DIR)/*.coffee) $(wildcard $(LIB_DIR)/*.coffee)
JS_OUT := $(patsubst %.cjsx,%.js,$(CJSX_IN)) \
	$(patsubst %.coffee,%.js,$(COFFEE_IN))
JS_FINAL := $(SCRIPTS_DIR)/bundle.js

BIOBRICK_IN := $(wildcard $(BIOBRICK_DIR)/*.coffee)
BIOBRICK_OUT := $(patsubst %.coffee,%.js,$(BIOBRICK_IN))

LESS_IN := $(wildcard $(STYLES_DIR)/*.less)
CSS_OUT := $(patsubst %.less,%.css,$(LESS_IN))

# browserify
BROWSERIFY_EXTERN_REQUIRE := $(patsubst %,-r %,$(EXTERN_JS))
BROWSERIFY_EXTERN_NOREQ := $(patsubst %,-x %,$(EXTERN_JS))
BROWSERIFY_EXTERN_BUNDLE := $(SCRIPTS_DIR)/vendor.js

# declarations
TARGETS := $(JS_FINAL) $(CSS_OUT) $(BROWSERIFY_EXTERN_BUNDLE) $(BIOBRICK_OUT)

all: $(TARGETS)

$(JS_FINAL): $(JS_OUT) $(DEPS)
	$(MAKE_PIPE) $(BROWSERIFY) $(BROWSERIFY_EXTERN_NOREQ) $(JS_OUT) '|' \
		$(UGLIFY_JS) $(UGLIFY_JS_OPTS) -o $@

$(BROWSERIFY_EXTERN_BUNDLE): $(DEPS)
	$(MAKE_PIPE) $(BROWSERIFY) $(BROWSERIFY_EXTERN_REQUIRE) '|' \
		$(UGLIFY_JS) $(UGLIFY_JS_OPTS) -o $@

%.js: %.coffee $(DEPS)
	$(COFFEE_CC) $(COFFEE_OPTS) $<

%.js: %.cjsx $(DEPS)
	$(CJSX_CC) $(COFFEE_OPTS) $<

%.css: %.less $(DEPS)
	$(MAKE_PIPE) $(LESS_CC) $< '|' $(CLEAN_CSS) -o $@

clean:
	rm -f $(JS_FINAL) $(CSS_OUT) $(JS_OUT)

$(DEPS):
	npm install

distclean: clean
	rm -f $(BROWSERIFY_EXTERN_BUNDLE)
	rm -rf $(NODE_DIR)
