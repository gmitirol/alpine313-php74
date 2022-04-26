#!/bin/sh

set -e;

curl -sS https://getcomposer.org/installer | /usr/bin/php -- --install-dir=/usr/local/bin --filename=composer --quiet --version=2.2.12
