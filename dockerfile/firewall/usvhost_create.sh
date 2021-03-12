#!/bin/bash -ex
mkdir -p /run/usvhost 
python -c "import socket as s; sock = s.socket(s.AF_UNIX); sock.bind('/run/usvhost/usvhost0')"
python -c "import socket as s; sock = s.socket(s.AF_UNIX); sock.bind('/run/usvhost/usvhost1')"
exec tail -f /dev/null
