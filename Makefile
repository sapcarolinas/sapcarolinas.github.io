STATIC_REGEX       = .*\.(html|css|jpg|jpeg|png|xml|txt|ico|webmanifest|svg)
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
BLOG_DIR            = $(SOURCE_DIR)/blog
TEMPLATE_DIR        = templates
DEFAULT_TEMPLATE    = $(TEMPLATE_DIR)/default.html
PANDOC_CONFIG       = pandoc.yml
PANDOC_METADATA     = metadata.md
RSS_FEED            = rss.xml
BLOG_RSS_SCRIPT     = $(SCRIPT_DIR)/rss.py
BLOG_LIST_SCRIPT    = $(SCRIPT_DIR)/bloglist.py
BLOG_LIST_REPLACE   = __BLOG_LIST__
BLOG_LIST_MARKDOWN  = .bloglist.md
SOURCE_DIRS        := $(shell $(FIND) $(SOURCE_DIR) -mindepth 1 -type d)
SOURCE_BLOG_LIST    = $(BLOG_DIR)/index.md
SOURCE_MARKDOWN    := $(shell $(FIND) $(SOURCE_DIR) -type f -name '*.md' -and ! -name $(BLOG_LIST_MARKDOWN))
SOURCE_STATIC      := $(shell $(FIND) $(SOURCE_DIR) -type f -regextype posix-extended -iregex '$(STATIC_REGEX)')
BLOG_POSTS         := $(shell $(FIND) $(BLOG_DIR) -type f	-name '*.md' -and ! -name $(BLOG_LIST_MARKDOWN) -and ! -path $(SOURCE_BLOG_LIST))
OUTPUT_DIRS        := $(patsubst $(SOURCE_DIR)/%, $(OUTPUT_DIR)/%, $(SOURCE_DIRS))
OUTPUT_MARKDOWN    := $(patsubst $(SOURCE_DIR)/%, $(OUTPUT_DIR)/%, $(patsubst %.md, %.html, $(SOURCE_MARKDOWN)))
OUTPUT_STATIC      := $(patsubst $(SOURCE_DIR)/%, $(OUTPUT_DIR)/%, $(SOURCE_STATIC))

CP                  = cp -p
INSERT_BLOG_LIST    = sed -e '/$(BLOG_LIST_REPLACE)/{r $(1)' -e 'd;}'
PANDOC              = pandoc --defaults=$(PANDOC_CONFIG) --template=$(TEMPLATE_DIR)/$(1) --output=$(2) --metadata=rss-feed:$(RSS_FEED) $(PANDOC_METADATA) -

# Default target: convert .md to .html, copy static assets, and generate RSS
build: \
	$(OUTPUT_DIRS) \
	$(OUTPUT_MARKDOWN) \
	$(OUTPUT_STATIC) \
	$(OUTPUT_DIR)/$(RSS_FEED)

$(OUTPUT_DIRS):
	mkdir -p $@

# Homepage (/)
$(OUTPUT_DIR)/index.html: $(SOURCE_DIR)/index.md $(SOURCE_DIR)/$(BLOG_LIST_MARKDOWN) $(TEMPLATE_DIR)/homepage.html $(PANDOC_CONFIG) $(PANDOC_METADATA)
	  $(call INSERT_BLOG_LIST,$(SOURCE_DIR)/$(BLOG_LIST_MARKDOWN)) $< | $(call PANDOC,homepage.html,$@)

# Markdown list of 5 most recent blog posts
$(SOURCE_DIR)/.bloglist.md: $(BLOG_POSTS) $(BLOG_LIST_SCRIPT)
		$(BLOG_LIST_SCRIPT) $(BLOG_DIR) $(BLOG_LIST_LIMIT) > $@

# The main blog listing (/blog/)
$(OUTPUT_DIR)/blog/index.html: $(BLOG_DIR)/index.md $(BLOG_DIR)/$(BLOG_LIST_MARKDOWN) $(DEFAULT_TEMPLATE) $(PANDOC_CONFIG) $(PANDOC_METADATA)
	  $(call INSERT_BLOG_LIST,$(BLOG_DIR)/$(BLOG_LIST_MARKDOWN)) $< | $(call PANDOC,default.html,$@)

# Markdown list of _all_ blog posts
$(SOURCE_DIR)/blog/.bloglist.md: $(BLOG_POSTS) $(BLOG_LIST_SCRIPT)
		$(BLOG_LIST_SCRIPT) $(BLOG_DIR) > $@

# Convert all other .md files to .html
$(OUTPUT_DIR)/%.html: $(SOURCE_DIR)/%.md $(DEFAULT_TEMPLATE) $(PANDOC_CONFIG) $(PANDOC_METADATA)
		$(call PANDOC,default.html,$@) $<

# Catch-all: copy static assets in $(SOURCE_DIR)/ to $(OUTPUT_DIR)/
$(OUTPUT_DIR)/%: $(SOURCE_DIR)/%
		$(CP) $< $@

# RSS feed
$(OUTPUT_DIR)/$(RSS_FEED): $(BLOG_POSTS) $(BLOG_RSS_SCRIPT)
	$(BLOG_RSS_SCRIPT) --metadata-file=$(PANDOC_METADATA) --rss-feed=$(RSS_FEED) $(BLOG_DIR) > $@

.PHONY: serve clean
serve: $(OUTPUT_DIR)
		cd $(OUTPUT_DIR) && python3 -m http.server

clean:
		rm -rf $(OUTPUT_DIR)
		rm -f $(SOURCE_DIR)/$(BLOG_LIST_MARKDOWN)
		rm -f $(BLOG_DIR)/$(BLOG_LIST_MARKDOWN)
