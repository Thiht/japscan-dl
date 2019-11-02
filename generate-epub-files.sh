#!/usr/bin/env bash

authors='Kaiu Shirai&Posuka Demizu'
publisher='JapScan.to'
title='The Promised Neverland'

for v in Volume\ *; do
  cd "$v" || exit

  filename="$title - $v"
  find . -name '*.jpg' -type f | sort | zip "$filename.cbz" -@

  series=$(echo "$v" | cut -d' ' -f2)
  seriesindex=$series

  ebook-convert "$filename.cbz" "$filename.mobi" \
    --authors "$authors" \
    --publisher "$publisher" \
    --title "$title" \
    --series "$series" \
    --series-index "$seriesindex" \
    --mobi-ignore-margins \
    --disable-trim \
    --output-profile kindle \
    --right2left \
    --wide \

    --dont-normalize \
    --keep-aspect-ratio \
    --no-process \
    --dont-add-comic-pages-to-toc \
    --extra-css "img{width:100%}" \
    --remove-first-image
done
