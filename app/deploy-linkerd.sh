#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -o xtrace
# set -eox pipefail #safety for script

# https://linkerd.io/2/getting-started/
echo "============================Install Linkerd=============================================================="

curl -sL https://run.linkerd.io/install | sh

# Add the linkerd CLI to your path with:
export PATH=$PATH:$HOME/.linkerd2/bin

linkerd check --pre
linkerd install | kubectl apply -f -

linkerd dashboard &
