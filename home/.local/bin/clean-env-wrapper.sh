#! /bin/bash

set -o errexit
set -o nounset
set -o pipefail

/usr/bin/env -u JAVA_HOME -u PATH -u MANPATH \
  /bin/bash -c "source /etc/profile && source /etc/bashrc && $*"
