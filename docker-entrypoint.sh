#!/bin/bash -x

set -e

whoami

env | sort

echo "Inputs: $*"

#### ------------------------------------------------------------------------
#### ---- Extra line added in the script to run all command line arguments
#### ---- To keep the docker process staying alive if needed.
#### ------------------------------------------------------------------------
set -v
if [ $# -gt 0 ]; then

    #### 1.) Setup needed stuffs, e.g., init db etc. ....
    #### (do something here for preparation)
    exec "$@"

else
    /bin/bash
fi

#tail -f /dev/null
