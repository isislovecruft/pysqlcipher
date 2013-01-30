#!/bin/bash
##############################################################################
#
# build_script.sh
# -------------------
# Build sqlcipher for Python 2.7.3. This doesn't really do anything useful
# yet.
#
# @author Isis Agora Lovecruft, 0x2cdb8b35
# @date 29 January 2013
# @version 0.0.1
##############################################################################

function usage () {
    echo ""
    echo "$0 [options] "
    echo ""
    echo "Building SQLCipher is almost the same as compiling a regular version of 
SQLite with two small exceptions: 

 1. You must define SQLITE_HAS_CODEC and SQLITE_TEMP_STORE=2 when building sqlcipher
 2. You need to link against a OpenSSL's libcrypto "
    echo ""
    echo "Options:"
    echo "--------"
    echo "--static,  -s <path>  Compile statically linked to OpenSSL's libcrypto.a"
    echo "--dynamic, -d         Compile dynamically linked to OpenSSL's libcrypto.a"
    echo "--arch,    -a <arch>  Architecture to compile for"
}

function permission_check () {
    if [[ $(id -u) != 0 ]] ; then
        echo "Gotta be root, son..."
        exit 1
    else
        echo "Permissions good...diving in..."
    fi
}

if test $# -gt 0 ; then
    permission_check
    while [[ "$1" != "" ]] ; do
        case "$1" in
            --arch | -a )
                shift
                BUILD_ARCH=$1
                export BUILD_ARCH
                echo "Setting build architecture to: ${BUILD_ARCH}"
                ;;
            --static | -s )
                LINK_STATIC=yes
                export LINK_STATIC
                echo "Compiling with static linking..."
                shift
                LINK_TO=$1
                export LINK_TO
                echo "Linking to OpenSSL libcrypto.a at: ${LINK_TO}..."
                ;;
            --dynamic | -d )
                LINK_DYN=yes
                export LINK_DYN
                echo "Compiling with dynamic linking..."
                ;;
            * )
                usage
                ;;
        esac
        shift
    done

    if test -z $SQLITE_HAS_CODEC ; then
        echo "Setting \$SQLITE_HAS_CODEC..."
        SQLITE_HAS_CODEC=true
        export SQLITE_HAS_CODEC
    fi

    if test -z $SQLITE_TEMP_STORE ; then
        echo "Setting \$SQLITE_TEMP_STORE=2..."
        SQLITE_TEMP_STORE=2
        export SQLITE_TEMP_STORE
    fi    

    if [[ "$LINK_STATIC" == "yes" ]]; then
        echo "We're here: $(pwd) "
        cd $(pwd)/..
        ./configure --enable-tempstore=yes CFLAGS="-DSQLITE_HAS_CODEC" \
            LDFLAGS=${LINK_TO}
        make
    fi

    if [[ "$LINK_DYN" == "yes" ]]; then
        cd $(pwd)/..
        ./configure --enable-tempstore=yes CFLAGS="-DSQLITE_HAS_CODEC" \
            LDFLAGS="-lcrypto"
    fi

    unset LINK_DYN LINK_STATIC LINK_TO BUILD_ARCH CFLAGS LDFLAGS 
    unset SQLITE_TEMP_STORE SQLITE_HAS_CODEC

else
    usage
    exit 0
fi

