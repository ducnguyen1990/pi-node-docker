#!/usr/bin/env bash

SOURCE=$1
TARGET=$2

if [[ "$TARGET" == *.well-known/stellar-history.json ]]; then
  # History manifest: we need to prevent this file from being cached.

  echo "upload-s3cmd: stellar-history.json -> upload with no cache"

  # -c option, because for some weird reason, s3cmd looks for the config file in /root although it's running as the stellar user
  # Cache-Control:no-cache doesn't work with the DigitalOcean CDN. But max-age=0 does.
  /s3cmd/s3cmd -c /home/stellar/.s3cfg put --acl-public --add-header="Cache-Control":"max-age=0" $SOURCE s3://history.testnet.minepi.com/$TARGET
else
  # Any other class of history file: we can cache for the bucket's default cache TTL.

  echo "upload-s3cmd: upload with default cache"

  # -c option, because for some weird reason, s3cmd looks for the config file in /root although it's running as the stellar user
  /s3cmd/s3cmd -c /home/stellar/.s3cfg put --acl-public $SOURCE s3://history.testnet.minepi.com/$TARGET
fi
