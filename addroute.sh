#!/bin/bash
# Route HTTP requests for containers on multiple octohosts.
# Ex: "serf event addroute ssh://git.repo.goes.here/repo-name.git,repo-name,http://domain.name.target/"
PAYLOAD=$(cat)
GIT_REPO=$(echo $PAYLOAD | cut -f1 -d,)
REPO_NAME=$(echo $PAYLOAD | cut -f2 -d,)
TARGET=$(echo $PAYLOAD | cut -f3 -d,)
BUILD_DIR=`mktemp -d`
DOMAIN_SUFFIX="octodev.io"
BASE="$REPO_NAME.$DOMAIN_SUFFIX"

delete_domain_name ()
{
  DOMAIN=$1
  /usr/bin/redis-cli ltrim frontend:$DOMAIN 200 200 > /dev/null
}

register_domain_name ()
{
  DOMAIN=$1
  TARGET=$2
  delete_domain_name $DOMAIN
  /usr/bin/redis-cli rpush frontend:$DOMAIN $DOMAIN > /dev/null
  /usr/bin/redis-cli rpush frontend:$DOMAIN $TARGET:80 > /dev/null
}

register_cnames ()
{
  BUILD_DIR=$1
  TARGET=$2
  CNAME="$BUILD_DIR/CNAME"
  if [ -f "$CNAME" ]
  then
    sed -i -e '$a\' $CNAME
    while read DOMAIN
    do
      register_domain_name $DOMAIN $TARGET
    done < $CNAME
  fi
}

echo "Add Route: $GIT_REPO as $TARGET in $BUILD_DIR"

if [ $SERF_SELF_ROLE == 'router' ]
then
  # Pull the $REPO into the $BUILD_DIR - maybe just grab CNAME file?
  git clone $GIT_REPO $BUILD_DIR
  # Register the canonical domain name and point to $TARGET
  register_domain_name $BASE $TARGET
  # Reigster the CNAMEs and point them to $TARGET
  register_cnames $BUILD_DIR $TARGET
  # Delete the $BUILD_DIR
  rm -rf $BUILD_DIR
else
  echo "$SERF_SELF_NAME is not in a router role."
fi