#! /bin/sh

usage() 
{
    echo -e "$0 <Common Name> <eMail Address>";
    echo -e "$0 -e <Common Name> <eMail Address>";
    _exit 1;
}

_exit()
{
    if [ $1 -ne 0 ];
    then
        exit $1;
    fi
}

if [ $# -lt 2 ];
then
    usage;
elif [ $# -eq 2 ];
then
    CN=$1;
    emailAddress=$2;
elif [ $# -eq 3 ];
then
    ENCRYPT=$1
    CN=$2;
    emailAddress=$3;
else
    usage;
fi

if [ "${ENCRYPT}" = '-e' ];
then
    openssl genrsa -des3 -out ${CN}.encrypt.key 4096
    _exit $?;
else
    openssl genrsa -out ${CN}.key 4096
    _exit $?;
fi

openssl req -new -sha256 -subj \
    "/CN=${CN}/emailAddress=${emailAddress}/O=Hochschule fuer Technik und Wirtschaft Dresden (FH)/L=Dresden/ST=Sachsen/C=DE/" \
    -key ${CN}.key -out ${CN}.csr


echo -e "
===============================================================================
Apache 2 Configuration:
LoadModule headers_module modules/mod_headers.so

<IfModule mod_headers.c>
    Header always set Strict-Transport-Security \"max-age=15768000; includeSubdomains; preload;\"
</IfModule>
"
_exit $?;
exit 0;
