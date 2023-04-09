#!/bin/sh
clef --chainid 50155 --suppress-bootwarn \
    --rules /root/rules.js \
    --http \
    --http.addr $(hostname -i) \
    < /root/PASSWORD
