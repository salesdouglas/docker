#!/bin/bash
#
# This script is used to configure the workspace when buildbot master container
# is started.
# Usage: Follow the steps in ../README.md.

# This file's name
SELF_NAME=$(basename $0)

# Functions
usage() {
printf "Usage: ./$SELF_NAME [OPTIONS]

  OPTIONS:
    -c Configure workspace for buildbot master & slaves.
    -r Run buildbot master pro
    -h This help message. \n"
}

configure_workspace() {
# Workspace for master
printf "\n\n----Starting configuring workspace for master----"
cp -u master.cfg /var/workspace/master/
buildbot create-master -r /var/workspace/master/
printf "\n\n----Finished configuring workspace for master----"

# Workspace for slaves.
## Just add to this section on adding new slaves in master.cfg.
printf "\n\n----Starting configuring workspace for buildslaves----"

## cogutil
printf "\n\n----Starting configuring workspace for cogutil buildslave\n"
buildslave create-slave -r /var/workspace/cogutil \
        buildmaster cogutil XXXXXX
printf "\n\n----Finished configuring workspace for cogutil buildslave"

## atomspace
printf "\n\n----Starting configuring workspace for atomspace buildslave\n"
buildslave create-slave -r /var/workspace/atomspace \
        buildmaster atomspace XXXXXX
printf "\n\n----Finished configuring workspace for atomspace buildslaves"

## opencog
printf "\n\n----Starting configuring workspace for opencog buildslave\n"
buildslave create-slave -r /var/workspace/opencog \
        buildmaster opencog XXXXXX
printf "\n\n----Finished configuring workspace for opencog buildslaves"

## moses
printf "\n\n----Starting configuring workspace for moses buildslave\n"
buildslave create-slave -r /var/workspace/moses \
        buildmaster moses XXXXXX
printf "\n\n----Finished configuring workspace for moses buildslaves"

}

# Main Execution
WORKSPACE_CONFIGURED=false
if [ $# -eq 0 ] ; then NO_ARGS=true ; fi

while getopts "hrc" flag ; do
    case $flag in
        c) CONFIGURE_WORKSPACE=true ;;
        r) RUN_MASTER=true ;;
        h) usage ;;
        \?) usage ;;
        *) UNKNOWN_FLAGS=true ;;
    esac
done

if [ $CONFIGURE_WORKSPACE == true ] ; then
    configure_workspace
    # TODO: this should check for errors and try again.
fi

if [ $RUN_MASTER ] ; then
    # the remove is required so as to enable restart when container fails, as
    # twisted.pid is a lock against multiple instances of master.
    if [ -a /var/workspace/master/twistd.pid ]; then
        rm /var/workspace/master/twistd.pid
        echo "----Removed stale twisted.pid file from buildmaster workspace."
    fi
    printf "\n\n----Starting buildbot master daemon"
    buildbot start  --nodaemon /var/workspace/master
fi

if [ $UNKNOWN_FLAGS ] ; then usage ; fi
if [ $NO_ARGS ] ; then usage ; fi
