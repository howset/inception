#!/bin/sh
set -e

RED='\033[0;31m'
GRE='\033[0;32m'
MAG='\033[0;35m'
CYA='\033[0;36m'
RES='\033[0m'

echo -e "${CYA}Running redis_init.sh${RES}"
echo -e "${GRE}Redis setup complete!${RES}"

# Start redis
exec redis-server --bind 0.0.0.0 --protected-mode no --dir /data
#protected mode is no bcause redis is isolated on inception_net,
# not exposed to host, so authentication is not required

# exec "$@"