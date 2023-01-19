#!/bin/sh

# Install the version of Bundler.
if [ -f Gemfile.lock ] && grep "BUNDLED WITH" Gemfile.lock >/dev/null; then
    cat Gemfile.lock | tail -n 2 | grep -C2 "BUNDLED WITH" | tail -n 1 | xargs gem install bundler -v
fi

# If there's a Gemfile, then run `bundle install`
# It's assumed that the Gemfile will install Jekyll too
if [ -f Gemfile ]; then
    bundle install
fi

# Check if .cacher directory exists in home. if not, create it.
CACHER_DIR="$HOME/.cacher/"
if ! [ -d "$CACHER_DIR" ]; then
    mkdir -p $CACHER_DIR
fi

# Create or Update credentials.json in .cacher directory
echo "{\"key\":\"$CACHER_API_KEY\",\"token\":\"$CACHER_API_TOKEN\"}" > $CACHER_DIR/credentials.json
