#!/bin/bash

FILENAME='AllPrintings.sqlite.gz'
SQLITE_URL="https://mtgjson.com/api/v5/$FILENAME"

target_dir="$(dirname "${BASHSOURCE[0]}")/data"
cd "$target_dir"
wget -N "$SQLITE_URL"
gunzip -k "$FILENAME"
