DIST_REVISION=$1

DIST_NAME=buildware_dist_${DIST_REVISION}
$DIST_ROOT=`pwd`/${DIST_NAME}
mkdir -p $DIST_ROOT

source src/jpeg-turbo/dist.sh $DIST_ROOT
source src/openssl/dist.sh $DIST_ROOT

# create dist package
DIST_PACKAGE=${DIST_NAME}.zip
zip -q -r ${DIST_PACKAGE} ${DIST_ROOT}

ls -R ${DIST_ROOT}

# Export DIST_NAME & DIST_PACKAGE for uploading
echo "DIST_NAME=$DIST_NAME" >> $GITHUB_ENV
echo "DIST_PACKAGE=${DIST_PACKAGE}" >> $GITHUB_ENV
