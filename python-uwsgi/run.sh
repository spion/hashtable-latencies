#!/bin/sh
export PYTHONUSERBASE=$PWD/pyenv
exec $PYTHONUSERBASE/bin/uwsgi --master --die-on-term --disable-logging \
    --wsgi-file main.py \
    --http-socket :8080
    # --plugin gevent --gevent 1000
    # --workers 4
    # --plugin python
