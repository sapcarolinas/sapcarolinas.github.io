# saintanthonys.com

This repository contains source code for [saintanthonys.com](https://www.saintanthonys.com/),
the website of Saint Anthony of Padua Catholic Church in Mount Holly, NC.

## How it works

[Markdown](https://github.com/adam-p/markdown-here/wiki/markdown-cheatsheet) is a
human-readable plain-text file format. Markdown files are used to generate the HTML for each page of the website.

The [src/](src) directory in this repository contains all the Markdown files and static
assets used to generate the website.

Its directory structure maps exactly to website URLs.
For example, [src/about/index.md](src/about/index.md) becomes [saintanthonys.com/about](https://www.saintanthonys.com/about/).

Whenever you commit a change to a file in this repository, the website is automatically
rebuilt and deployed to saintanthonys.com using GitHub Pages.

There are two ways to make changes to the website:

1. Edit the desired file using the GitHub web interface (just click the pencil icon in the top right)
2. Or, clone the repo to your PC using `git` (for advanced users)

## The NEWS.md file

The [NEWS.md](src/NEWS.md) file is special. The contents of this file are used to generate
[saintanthonys.com/news](https://www.saintanthonys.com/news/).

Basically, this file is inserted into [src/news/index.md](src/news/index.md) whenever
the website is built. 

Because this file is updated frequently, we wanted to make it as simple as possible to edit.

## Technical Details

### Pandoc

The basic skeleton of each page is defined by the [pandoc template](templates/default.html).

The Markdown for each page is converted to HTML and replaces the `$body$` macro in the template file.

Lots of custom variables are defined in are defined in [metadata.md](metadata.md).
These are used by the pandoc templates to populate various `<meta>` tags on each page.

### YAML Frontmatter

At the top of each markdown file, you'll notice a YAML block. You can define different
pandoc variables in this block in order to influence how the HTML for the page is generated:

title
: The HTML `<title>` element.

description
: The HTML `<meta>` description, often used by search engines.

heading
: If you want the first `<h1>` element on the page to be different from the title, set it here.

noheading
: If you don't want an `<h1>` element at the top of the page, set this to `true`.

social-image
: Set this to a relative URL path for the image you'd like used for this page when it's shared to social media.

### The Makefile

The [Makefile](Makefile) contains the logic which converts the Markdown files to HTML. It's essentially
a home-grown static site generator using [pandoc](https://pandoc.org/).
(Yes, we probably should use something like Hugo, but this is good enough for now.)

It is recommended not to edit the Makefile unless you really know what you are doing.

### Python Scripts

There are two small Python scripts used:

  - [relpath.py](scripts/relpath.py): used by the Makefile to convert filesystem paths to URL paths.
    For example (`/about/index.md` -> `/about/`).

  - [sitemap.py](scripts/sitemap.py): generates [sitemap.xml](https://www.saintanthonys.com/sitemap.xml),
    which is scraped by search engines.

### Build and Deployment

A [GitHub action](.github/workflows/deploy.yml) builds and deploys the site to GitHub Pages
whenever the main branch is updated.

