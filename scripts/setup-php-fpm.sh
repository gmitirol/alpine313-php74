#!/bin/sh

# set php-fpm parameters and restart service
#
# setup-php-fpm.sh <conf> <mode> <max_children> [<start_servers> <min_spare_servers> <max_spare_servers>]

set -e;

CONFIGDIR='/etc/php7/php-fpm.d'
SERVICECMD="/usr/bin/supervisorctl"
SERVICESOCKET="/tmp/supervisor.sock"

CONFFILE="$1"
MODE="$2"

if [ $# -lt 3 ]; then
	(>&2 echo 'missing parameters');
	exit 65;
fi

if [ ! -f "$CONFIGDIR/$CONFFILE" ]; then
	(>&2 echo 'config file not found');
	exit 66;
fi

case "$MODE" in
	'dynamic')
		if [ $# -lt 6 ]; then
			(>&2 echo 'missing parameters');
			exit 65;
		fi
		MAX_CHILDREN="$3"
		START_SERVER="$4" # min_spare_servers + (max_spare_servers - min_spare_servers) / 2
		MIN_SPARE="$5"
		MAX_SPARE="$6"
		sed -i "s/^pm = .*/pm = $MODE/" "$CONFIGDIR/$CONFFILE"
		sed -i "s/^pm.max_children = .*/pm.max_children = $MAX_CHILDREN/" "$CONFIGDIR/$CONFFILE"
		sed -i "s/^pm.start_servers = .*/pm.start_servers = $START_SERVER/" "$CONFIGDIR/$CONFFILE"
		sed -i "s/^pm.min_spare_servers = .*/pm.min_spare_servers = $MIN_SPARE/" "$CONFIGDIR/$CONFFILE"
		sed -i "s/^pm.max_spare_servers = .*/pm.max_spare_servers = $MAX_SPARE/" "$CONFIGDIR/$CONFFILE"
		;;

	'static'|'ondemand')
		MAX_CHILDREN="$3"
		sed -i "s/^pm = .*/pm = $MODE/" "$CONFIGDIR/$CONFFILE"
		sed -i "s/^pm.max_children = .*/pm.max_children = $MAX_CHILDREN/" "$CONFIGDIR/$CONFFILE"
		;;

	*)
		(>&2 echo 'invalid mode');
		exit 65;
		;;
esac

if [ -S "$SERVICESOCKET" ]; then
	$SERVICECMD restart php-fpm
	exit $?
fi

exit 0;
