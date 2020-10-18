#!/bin/bash

tar -czf - /input | \
  openssl pkeyutl -encrypt \
    -pubin -inkey /key.pub \
    -out /output/backup.tgz.enc

