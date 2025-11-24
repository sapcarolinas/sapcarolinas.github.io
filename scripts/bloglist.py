#!/usr/bin/env python3

import argparse
from common import get_blog_posts

DATE_FORMAT = '%Y-%m-%d'

parser = argparse.ArgumentParser('bloglist')
parser.add_argument('BLOG_DIR', type=str, help='Directory containing markdown blog posts')
parser.add_argument('LIMIT', nargs='?', default=None, type=int, help='Maximum number of posts to show')
args = parser.parse_args()

posts = get_blog_posts(args.BLOG_DIR)

if args.LIMIT is not None:
    posts = posts[0:args.LIMIT]

if len(posts) == 0:
    print('Nothing has been posted yet!')
else:
    for post in posts:
        post_date = post['date'].strftime(DATE_FORMAT)

        print(f'- [{post["title"]}]({post["href"]}) ({post_date})\n')
        if post['description']:
            print(f'  {post["description"]}\n')
