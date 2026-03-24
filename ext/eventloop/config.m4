PHP_ARG_ENABLE([eventloop],
  [whether to enable EventLoop support],
  [AS_HELP_STRING([--enable-eventloop],
    [Enable EventLoop support])])

if test "$PHP_EVENTLOOP" != "no"; then
  AC_CHECK_HEADERS([sys/epoll.h], [
    AC_DEFINE([HAVE_EPOLL], [1], [Have epoll support])
  ])

  AC_CHECK_HEADERS([sys/event.h], [
    AC_DEFINE([HAVE_KQUEUE], [1], [Have kqueue support])
  ])

  AC_CHECK_HEADERS([poll.h], [
    AC_DEFINE([HAVE_POLL], [1], [Have poll support])
  ])

  AC_CHECK_HEADERS([port.h], [
    AC_DEFINE([HAVE_PORT], [1], [Have Solaris port support])
  ])

  AC_CHECK_FUNCS([clock_gettime])

  dnl Check for Fiber support (may be removed in future PHP versions)
  if test -f "$abs_srcdir/Zend/zend_fibers.h"; then
    AC_DEFINE([HAVE_FIBERS], [1], [Have Fiber support])
  fi

  EVENTLOOP_SOURCES="eventloop.c eventloop_cb.c eventloop_timer.c eventloop_suspension.c drivers/select.c"

  if test "$ac_cv_header_poll_h" = "yes"; then
    EVENTLOOP_SOURCES="$EVENTLOOP_SOURCES drivers/poll.c"
  fi

  if test "$ac_cv_header_sys_epoll_h" = "yes"; then
    EVENTLOOP_SOURCES="$EVENTLOOP_SOURCES drivers/epoll.c"
  fi

  if test "$ac_cv_header_sys_event_h" = "yes"; then
    EVENTLOOP_SOURCES="$EVENTLOOP_SOURCES drivers/kqueue.c"
  fi

  if test "$ac_cv_header_port_h" = "yes"; then
    EVENTLOOP_SOURCES="$EVENTLOOP_SOURCES drivers/port.c"
  fi

  PHP_NEW_EXTENSION([eventloop], [$EVENTLOOP_SOURCES], [$ext_shared])
fi
