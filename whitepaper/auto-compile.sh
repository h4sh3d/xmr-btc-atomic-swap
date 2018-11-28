#!/bin/sh

while inotifywait -e modify ./xmr-btc.tex; do
    make
done

