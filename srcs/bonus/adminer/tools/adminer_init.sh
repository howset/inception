#!/bin/sh
set -e

RED='\033[0;31m'
GRE='\033[0;32m'
MAG='\033[0;35m'
CYA='\033[0;36m'
RES='\033[0m'

echo -e "${CYA}Running adminer_init.sh${RES}"
echo -e "${GRE}Adminer setup complete!${RES}"

# Start adminer
exec php -S 0.0.0.0:8080 -t /usr/share adminer.php
# -S specify addr:port, -t specify document root

# exec "$@"