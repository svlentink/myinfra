#!/bin/sh

if [ ! -d txt2bookmarks ]; then
  apk add --no-cache git
  git clone https://github.com/svlentink/txt2bookmarks.git
fi

txt2bookmarks/script.py /input > /output/bookmarks.html
