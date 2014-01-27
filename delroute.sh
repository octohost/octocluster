#!/bin/bash
# Route HTTP requests for containers on multiple octohosts.
# Ex: "serf event delroute ssh://git.repo.goes.here/repo-name.git,repo-name"
PAYLOAD=$(cat)
GIT_REPO=$(echo $PAYLOAD | cut -f1 -d,)
REPO_NAME=$(echo $PAYLOAD | cut -f2 -d,)
BUILD_DIR=`mktemp -d`
DOMAIN_SUFFIX="octodev.io"
BASE="$REPO_NAME.$DOMAIN_SUFFIX"


delete_domain_name ()
{
  DOMAIN=$1
  /usr/bin/redis-cli ltrim frontend:$DOMAIN 200 200 > /dev/null
}

delete_cnames ()
{
  BUILD_DIR=$1
  CNAME="$BUILD_DIR/CNAME"
  if [ -f "$CNAME" ]
  then
    sed -i -e '$a\' $CNAME
    while read DOMAIN
    do
      delete_domain_name $DOMAIN
    done < $CNAME
  fi
}

echo "Del Route: $GIT_REPO in $BUILD_DIR"

if [ $SERF_SELF_ROLE == 'router' ]
then
  # Pull the $REPO into the $BUILD_DIR - maybe just grab CNAME file?
  git clone $GIT_REPO $BUILD_DIR
  # Register the canonical domain name and point to $TARGET
  delete_domain_name $BASE
  # Reigster the CNAMEs and point them to $TARGET
  delete_cnames $BUILD_DIR
  # Delete the $BUILD_DIR
  rm -rf $BUILD_DIR
else
  echo "$SERF_SELF_NAME is not in a router role."
fi