#!/usr/bin/env python3

import argparse
import email.utils
from datetime import datetime
from common import get_blog_posts, get_all_metadata

parser = argparse.ArgumentParser('rss')
parser.add_argument('BLOG_DIR', type=str, help='Directory containing markdown blog posts')
parser.add_argument('--metadata-file', type=str, required=True, help='Metadata file path')
parser.add_argument('--rss-feed', type=str, required=True, help='Relative path to RSS feed')
parser.add_argument('--limit', default=15, type=int, help='Maximum number of posts to show')
args = parser.parse_args()

metadata = get_all_metadata(args.metadata_file)

posts = get_blog_posts(args.BLOG_DIR)
posts = posts[0:args.limit]

build_date = email.utils.format_datetime(datetime.now().astimezone())

print(f'''<?xml version="1.0"?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
<channel>
  <title>{metadata["site-title"]}</title>
  <link>{metadata["baseurl"]}/</link>
  <language>en-US</language>
  <description>{metadata["tagline"]}</description>
  <lastBuildDate>{build_date}</lastBuildDate>
  <atom:link href="{metadata["baseurl"]}/{args.rss_feed}" rel="self" type="application/rss+xml"/>''')

for post in posts:
    pub_date = email.utils.format_datetime(post['date'].astimezone())

    print(f'''  <item>
    <title>{post["title"]}</title>
    <link>{args.url}{post["href"]}</link>
    <guid>{args.url}{post["href"]}</guid>
    <pubDate>{pub_date}</pubDate>''')

    if 'description' in post:
        print(f'    <description>{post["description"]}</description>')

    print('  </item>')

print('</channel>')
print('</rss>')
