#!/usr/bin/env bash
set -e

ASWT_HOST="a0d7b954-ssh"
ASWT_URL=https://github.com/zamolxe/homeassistant-aswt/raw/refs/heads/main/awst.sh
ASWT_PATH=/config/aswt
SSH_ARGS=(
  -i ${ASWT_PATH}/aswt.key
  -o StrictHostKeyChecking=no
  -o UserKnownHostsFile=/dev/null
  -tt
  -q
)
RUN_HOST=$(hostname -s)
ASWT_CMD=$(basename $0)

if [ "${RUN_HOST}" == "${ASWT_HOST}" ]; then
    [ ! -d ${ASWT_PATH} ] && \
        mkdir -p ${ASWT_PATH}
    [ ! -f ${ASWT_PATH}/aswt.key ] && \
        ssh-keygen -q -t ed25519 -N "" -f ${ASWT_PATH}/aswt && \
        mv ${ASWT_PATH}/aswt ${ASWT_PATH}/aswt.key && \
        cat ${ASWT_PATH}/aswt.pub
    if [[ ! -f ${ASWT_PATH}/aswt.sh  || "${ASWT_CMD}" == "update" || "${1}" == "update" ]]; then
        curl -sS --output ${ASWT_PATH}/aswt.sh.$$ -L "${ASWT_URL}" && \
        head -1 ${ASWT_PATH}/aswt.sh.$$ | grep '#!/usr/bin/env bash' >/dev/null && \
        mv -f ${ASWT_PATH}/aswt.sh.$$ ${ASWT_PATH}/aswt.sh && \
        chmod +x ${ASWT_PATH}/aswt.sh && \
        ln -sf aswt.sh ${ASWT_PATH}/run && \
        ln -sf aswt.sh ${ASWT_PATH}/update && \
        rm -f ${ASWT_PATH}/aswt.sh.[0-9]* && \
        echo "done"
    else
        ${@}
    fi
elif [[ "$(hostname -s)" == "homeassistant" && "${ASWT_CMD}" == "run" ]]; then
    ssh ${SSH_ARGS[@]} ${ASWT_HOST} ${@}
else
    echo "This script can be run only from the homeassistant or aswt containers"
fi
