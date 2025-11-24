#!/usr/bin/env python3

import os
import frontmatter
import dateparser
import datetime
from pathlib import Path

BLOG_LIST_FILE = '.bloglist.md'

def get_href(path):
    path = Path(path)
    path = path.relative_to(*path.parts[:1])
    if path.name == 'index.md':
        return '/{}/'.format(path.parent)
    else:
        return '/{}/{}.html'.format(path.parent, path.stem)

def get_all_metadata(file):
    return frontmatter.load(file).metadata

def read_metadata(file):
    post = frontmatter.load(file)

    for field in ['title', 'date']:
        if post.get(field) is None:
            raise Exception("{} is missing metadata field '{}'".format(file, field))

    if type(post['date']) not in [datetime.datetime, datetime.date]:
        date = dateparser.parse(post['date'])
    else:
        date = post['date']

    return {
        'title':       post.get('title'),
        'date':        date,
        'author':      post.get('author'),
        'description': post.get('description'),
        'draft':       post.get('draft'),
        'href':        get_href(file)
    }

def get_blog_posts(blog_dir):
    blog_index = os.path.join(blog_dir, 'index.md')
    posts = []

    for root, dirs, files in os.walk(blog_dir):
        for file in files:
            path = os.path.join(root, file)
            if path.endswith('.md') and path != blog_index and file != BLOG_LIST_FILE:
                metadata = read_metadata(path)
                if not metadata['draft']:
                    posts.append(metadata)

    posts.sort(key=lambda p: (p is None, p['date']), reverse=True)
    return posts
