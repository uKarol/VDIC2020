#!/bin/bash
# to start simvision add "-gui" option at the command line


source /cad/env/cadence_path.XCELIUM1809

# xrun replaces irun
xrun \
  -F tb.f \
  +access+r \
  "$@"

# +UVM_VERBOSITY=UVM_DEBUG \
