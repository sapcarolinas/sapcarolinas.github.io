BASE_URL           = https://www.saintanthonys.com
STATIC_REGEX       = .*\.(html|jpg|jpeg|png|xml|txt|ico|webmanifest|svg)
SITEMAP_EXCLUDE    = $(NEWS_MARKDOWN) google*.html

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
DEFAULT_CSS         = $(SOURCE_DIR)/style.css
PANDOC_METADATA     = metadata.md
NEWS_REPLACE        = __NEWS__
NEWS_MARKDOWN       = NEWS.md
SOURCE_DIRS        := $(shell $(FIND) $(SOURCE_DIR) -mindepth 1 -type d)
SOURCE_MARKDOWN    := $(shell $(FIND) $(SOURCE_DIR) -type f -name '*.md' -and ! -name $(NEWS_MARKDOWN))
SOURCE_STATIC      := $(shell $(FIND) $(SOURCE_DIR) -type f -regextype posix-extended -iregex '$(STATIC_REGEX)')
OUTPUT_DIRS        := $(patsubst $(SOURCE_DIR)/%, $(OUTPUT_DIR)/%, $(SOURCE_DIRS))
OUTPUT_MARKDOWN    := $(patsubst $(SOURCE_DIR)/%, $(OUTPUT_DIR)/%, $(patsubst %.md, %.html, $(SOURCE_MARKDOWN)))
OUTPUT_STATIC      := $(patsubst $(SOURCE_DIR)/%, $(OUTPUT_DIR)/%, $(SOURCE_STATIC))
OUTPUT_SITEMAP      = $(OUTPUT_DIR)/sitemap.xml

CP                  = cp -p
SITEMAP             = $(SCRIPT_DIR)/sitemap.py
INTERPOLATE         = sed -e '/$(1)/{r $(2)' -e 'd;}'
RELPATH             = $(shell $(SCRIPT_DIR)/relpath.py $(OUTPUT_DIR) "$(1)")
PANDOC              = pandoc \
											  --defaults=$(PANDOC_CONFIG) \
												--include-in-header="$(DEFAULT_CSS)" \
												--template="$(TEMPLATE_DIR)/$(1)" \
												--metadata="relpath:$(call RELPATH,$(2))" \
												--metadata="baseurl:$(BASE_URL)" \
												--output="$(2)" \
												$(PANDOC_METADATA) \
												-

# Default target
build: \
	$(OUTPUT_DIRS) \
	$(OUTPUT_MARKDOWN) \
	$(OUTPUT_STATIC) \
	$(OUTPUT_SITEMAP)

$(OUTPUT_DIRS):
	mkdir -p $@

# Homepage (/)
$(OUTPUT_DIR)/index.html: $(SOURCE_DIR)/index.md $(SOURCE_DIR)/$(NEWS_MARKDOWN) $(TEMPLATE_DIR)/homepage.html $(PANDOC_CONFIG) $(PANDOC_METADATA) $(DEFAULT_CSS)
	  $(call INTERPOLATE,$(NEWS_REPLACE),$(SOURCE_DIR)/$(NEWS_MARKDOWN)) $< | $(call PANDOC,homepage.html,$@)

# News (/news/)
$(OUTPUT_DIR)/news/index.html: $(SOURCE_DIR)/news/index.md $(SOURCE_DIR)/$(NEWS_MARKDOWN) $(TEMPLATE_DIR)/default.html $(PANDOC_CONFIG) $(PANDOC_METADATA) $(DEFAULT_CSS)
	  $(call INTERPOLATE,$(NEWS_REPLACE),$(SOURCE_DIR)/$(NEWS_MARKDOWN)) $< | $(call PANDOC,default.html,$@)

# Sitemap
$(OUTPUT_SITEMAP): $(SOURCE_MARKDOWN) $(SOURCE_STATIC) $(SITEMAP)
	$(SITEMAP) $(BASE_URL) $(SOURCE_DIR) $(SITEMAP_EXCLUDE) > $@

# Convert all other .md files to .html
$(OUTPUT_DIR)/%.html: $(SOURCE_DIR)/%.md $(DEFAULT_TEMPLATE) $(PANDOC_CONFIG) $(PANDOC_METADATA) $(DEFAULT_CSS)
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
