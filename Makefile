SANDBOX_TARGET     = www1:/usr/local/www/vhosts/sapdev.sacredheartsc.com
STATIC_REGEX       = .*\.(css|html|jpg|jpeg|png|xml|txt|ico|webmanifest|svg)
RECENT_POSTS_LIMIT = 5

OS := $(shell uname -s)
ifeq ($(OS),FreeBSD)
	FIND = gfind
else
	FIND = find
endif

SOURCE_DIR          = src
OUTPUT_DIR          = dist
SCRIPT_DIR          = scripts
TEMPLATE_DIR        = templates
DEFAULT_TEMPLATE    = $(TEMPLATE_DIR)/default.html
PANDOC_CONFIG       = pandoc.yml
PANDOC_METADATA     = metadata.md
NEWS_REPLACE        = __NEWS__
NEWS_MARKDOWN       = NEWS.md
SOURCE_DIRS        := $(shell $(FIND) $(SOURCE_DIR) -mindepth 1 -type d)
SOURCE_MARKDOWN    := $(shell $(FIND) $(SOURCE_DIR) -type f -name '*.md' -and ! -name $(NEWS_MARKDOWN))
SOURCE_STATIC      := $(shell $(FIND) $(SOURCE_DIR) -type f -regextype posix-extended -iregex '$(STATIC_REGEX)')
OUTPUT_DIRS        := $(patsubst $(SOURCE_DIR)/%, $(OUTPUT_DIR)/%, $(SOURCE_DIRS))
OUTPUT_MARKDOWN    := $(patsubst $(SOURCE_DIR)/%, $(OUTPUT_DIR)/%, $(patsubst %.md, %.html, $(SOURCE_MARKDOWN)))
OUTPUT_STATIC      := $(patsubst $(SOURCE_DIR)/%, $(OUTPUT_DIR)/%, $(SOURCE_STATIC))

CP                  = cp -p
INTERPOLATE         = sed -e '/$(1)/{r $(2)' -e 'd;}'
RELPATH             = $(shell $(SCRIPT_DIR)/relpath.py $(OUTPUT_DIR) "$(1)")
PANDOC              = pandoc \
											  --defaults=$(PANDOC_CONFIG) \
												--template="$(TEMPLATE_DIR)/$(1)" \
												--metadata="relpath:$(call RELPATH,$(2))" \
												--output="$(2)" \
												$(PANDOC_METADATA) \
												-

# Default target
build: \
	$(OUTPUT_DIRS) \
	$(OUTPUT_MARKDOWN) \
	$(OUTPUT_STATIC)

$(OUTPUT_DIRS):
	mkdir -p $@

# Homepage (/)
$(OUTPUT_DIR)/index.html: $(SOURCE_DIR)/index.md $(SOURCE_DIR)/$(NEWS_MARKDOWN) $(TEMPLATE_DIR)/homepage.html $(PANDOC_CONFIG) $(PANDOC_METADATA)
	  $(call INTERPOLATE,$(NEWS_REPLACE),$(SOURCE_DIR)/$(NEWS_MARKDOWN)) $< | $(call PANDOC,homepage.html,$@)

# News (/news/)
$(OUTPUT_DIR)/news/index.html: $(SOURCE_DIR)/news/index.md $(SOURCE_DIR)/$(NEWS_MARKDOWN) $(TEMPLATE_DIR)/default.html $(PANDOC_CONFIG) $(PANDOC_METADATA)
	  $(call INTERPOLATE,$(NEWS_REPLACE),$(SOURCE_DIR)/$(NEWS_MARKDOWN)) $< | $(call PANDOC,default.html,$@)

# Convert all other .md files to .html
$(OUTPUT_DIR)/%.html: $(SOURCE_DIR)/%.md $(DEFAULT_TEMPLATE) $(PANDOC_CONFIG) $(PANDOC_METADATA)
		$(call PANDOC,default.html,$@) < $<

# Catch-all: copy static assets in $(SOURCE_DIR)/ to $(OUTPUT_DIR)/
$(OUTPUT_DIR)/%: $(SOURCE_DIR)/%
		$(CP) $< $@

.PHONY: serve clean sandbox
serve: build
		cd $(OUTPUT_DIR) && python3 -m http.server

sandbox: build
	rsync -av --delete $(OUTPUT_DIR)/ $(SANDBOX_TARGET)/

clean:
		rm -rf $(OUTPUT_DIR)
