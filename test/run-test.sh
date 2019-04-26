#!/bin/bash
set -e

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

cd "${DIR}/.."

echo "Run Rubocop"
bundle exec rubocop libraries spec ./doc/*.rb

echo "Run rspec"
bundle exec rspec --require spec_helper --format d
