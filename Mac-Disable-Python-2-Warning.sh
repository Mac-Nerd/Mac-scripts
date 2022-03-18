#!/bin/sh
# ----- Legal: ----
# Sample scripts are not supported under any N-able support program or service.
# The sample scripts are provided AS IS without warranty of any kind.
# N-able expressly disclaims all implied warranties including, warranties
# of merchantability or of fitness for a particular purpose.
# In no event shall N-able or any other party be liable for damages arising
# out of the use of or inability to use the sample scripts.
# ----- /Legal ----


# This prevents a warning popup in MacOS Big Sur and Monterey intended to let the user
# know that outdated python scripts will stop working in a future version of MacOS.
# The trouble is, many applications use python behind the scenes, and there's nothing
# the user can do about it, except keep seeing the warning whenever they open that app.

defaults write com.apple.python DisablePythonAlert true
