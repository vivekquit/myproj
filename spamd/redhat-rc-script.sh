#!/bin/sh
#
# spamassassin This script starts and stops the spamd daemon
#
# chkconfig: - 80 30
# processname: spamd
# description: spamd is a daemon process which uses SpamAssassin to check \
#              email messages for SPAM.  It is normally called by spamc \
#	       from a MDA.

# Source function library.
. /etc/rc.d/init.d/functions

# Source networking configuration.
. /etc/sysconfig/network

# Check that networking is up.
[ ${NETWORKING} = "no" ] && exit 0

# Set default spamd configuration.
SPAMDOPTIONS="-d -c -m5 -H"
SPAMD_PID=/var/run/spamassassin/spamd.pid

# Source spamd configuration.
if [ -f /etc/sysconfig/spamassassin ] ; then
	. /etc/sysconfig/spamassassin
fi

[ -f /usr/bin/spamd -o -f /usr/local/bin/spamd ] || exit 0
PATH=$PATH:/usr/bin:/usr/local/bin

# By default it's all good
RETVAL=0

# See how we were called.
case "$1" in
  start)
	# Start daemon.
	echo -n "Starting spamd: "
	daemon $NICELEVEL spamd $SPAMDOPTIONS -r $SPAMD_PID
	RETVAL=$?
        echo
	if [ $RETVAL = 0 ]; then
		[ -n "$SPAMD_PID" ] && ln -s $SPAMD_PID /var/run/spamd.pid
		touch /var/lock/subsys/spamassassin
	fi
        ;;
  stop)
        # Stop daemons.
        echo -n "Shutting down spamd: "
        killproc spamd
        RETVAL=$?
        echo
	if [ $RETVAL = 0 ]; then
		rm -f /var/lock/subsys/spamassassin
		rm -f /var/run/spamd.pid
	fi
        ;;
  restart)
        $0 stop
        $0 start
        ;;
  condrestart)
       [ -e /var/lock/subsys/spamassassin ] && $0 restart
       ;;
  status)
	status spamd
	RETVAL=$?
	;;
  *)
	echo "Usage: $0 {start|stop|restart|status|condrestart}"
	RETVAL=1
	;;
esac

exit $RETVAL
