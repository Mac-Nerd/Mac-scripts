#!/bin/sh
# This script is provided AS IS without warranty of any kind.
# https://github.com/Mac-Nerd/Mac-scripts
# -----------------------------------------------------------


# This prevents a warning popup in MacOS Big Sur and Monterey intended to let the user
# know that outdated python scripts will stop working in a future version of MacOS.
# The trouble is, many applications use python behind the scenes, and there's nothing
# the user can do about it, except keep seeing the warning whenever they open that app.

defaults write com.apple.python DisablePythonAlert true
