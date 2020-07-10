#!/bin/bash

export RUNMODE=${RUNMODE}
export LISTEN=${LISTEN}

cd /web/

rackup --host "$LISTEN" -p 3000 -E $RUNMODE