#!/bin/sh
set -eu

eval "$(/runner.pl .github/actions.yml "$@" || echo exit "$?")"

