#!/usr/bin/python3

import glob
import io
import json
import os
import re
import sys
import urllib.request, urllib.error

GITHUB_REPOSITORY = os.getenv('GITHUB_REPOSITORY', default='')
GITHUB_TOKEN = os.getenv('GITHUB_TOKEN', default='')

gh_releases_url = f'https://api.github.com/repos/{GITHUB_REPOSITORY}/releases'


# Get information of GitHub release
# see: https://docs.github.com/en/rest/reference/repos#releases
def get_rel_info(url, auth):
    if auth:
        # Unauthenticated requests are limited up to 60 requests per hour.
        # Authenticated requests are allowed up to 5,000 requests per hour.
        # See: https://docs.github.com/en/rest#rate-limiting
        request = urllib.request.Request(url)
        request.add_header('Authorization', f'token {auth}')
    else:
        request = url
    try:
        response = urllib.request.urlopen(request)
    except urllib.error.HTTPError as err:
        print(f'GitHub release not found. ({err.reason})', file=sys.stderr)
        exit(1)
    return json.load(io.StringIO(str(response.read(), 'utf-8')))


def get_latest_rel():
    files = sorted(glob.glob('Releases-in-*.md'))
    if not files:
        print('Releases-in-*.md not found.', file=sys.stderr)
        exit(1)
    rel = ''
    with open(files[-1]) as f:
        for l in f:
            m = re.match(r'^\* \[(v\d+\.\d+\.\d+)\]', l)
            if m:
                rel = m.group(1)
    if rel == '':
        print('The latest release is not found in the files', file=sys.error)
        exit(1)
    return rel


def get_new_rels(rels_info, latest_rel):
    rels = []
    for rel in rels_info:
        if rel['name'] > latest_rel:
            rels.insert(0, rel)
    return rels


def write_new_rels(new_rels, latest_rel):
    latest_file = sorted(glob.glob('Releases-in-*.md'))[-1]

    lines = []
    last_y = ''
    last_m = ''
    with open(latest_file) as f:
        for l in f:
            m1 = re.match(r'^## (\d{4})-(\d{2})', l)
            if m1:
                last_y = m1.group(1)
                last_m = m1.group(2)
            else:
                m2 = re.match(r'^\* \[(v\d+\.\d+\.\d+)\]', l)
                if m2.group(1) == latest_rel:
                    lines += [l]
                    break
            lines += [l]

    print('New releases: ', end='')
    f = open(latest_file, 'w')
    for i, rel in enumerate(new_rels):
        y = rel['published_at'][:4]
        m = rel['published_at'][5:7]
        if y != last_y:
            f.writelines(lines)
            f.close()
            lines = []
            last_y = y
            f = open(f'Releases-in-{y}.md', 'w')
        if m != last_m:
            lines += [f"## {y}-{m}\n"]
            last_m = m
        lines += [f"* [{rel['name']}]({rel['html_url']})\n"]

        if i != 0:
            print(', ', end='')
        print(rel['name'], end='')

    f.writelines(lines)
    f.close()
    print()


def main():
    if GITHUB_REPOSITORY == '':
        print('$GITHUB_REPOSITORY is not set.', file=sys.stderr)
        exit(1)
    if GITHUB_TOKEN == '':
        print('$GITHUB_TOKEN is not set.', file=sys.stderr)
        exit(1)

    rels_info = get_rel_info(gh_releases_url, GITHUB_TOKEN)
    latest_rel = get_latest_rel()
    print('The latest release in the list: ' + latest_rel)
    new_rels = get_new_rels(rels_info, latest_rel)
    if not new_rels:
        print('No new releases found.')
        exit(0)
    write_new_rels(new_rels, latest_rel)


if __name__ == '__main__':
    main()
