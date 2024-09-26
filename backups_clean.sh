#!/usr/bin/env bash

DRY_RUN=0
KEEP_FULL=14
KEEP_CORE=5
KEEP_ADDON=5

# DO NOT EDIT BELOW
SCRIPT_PATH=$(dirname $0)
SCRIPT_NAME=$(basename $0)
SCRIPT_LOG=${SCRIPT_PATH}/${SCRIPT_NAME%.sh}.log

(
KEEP_FULL=$((KEEP_FULL+1))
KEEP_CORE=$((KEEP_CORE+1))
KEEP_ADDON=$((KEEP_ADDON+1))

REMOVE_LIST=()

HA_BACKUPS=$(ha --raw-json backups)
COUNT_ALL=$(echo ${HA_BACKUPS} | jq -r '.data.backups | .[] | .slug'  | wc -l)
COUNT_FULL=$(echo ${HA_BACKUPS} | jq -r '.data.backups | sort_by(.date) | reverse | .[] | select(.type == "full") | .slug '  | wc -l)
COUNT_CORE=$(echo ${HA_BACKUPS} | jq -r '.data.backups | sort_by(.date) | reverse | .[] | select(.type == "partial" and .content.homeassistant == true) | .slug' | wc -l)
COUNT_ADDON=$(echo ${HA_BACKUPS} | jq -r '.data.backups | sort_by(.date) | reverse | .[] | select(.type == "partial" and .content.homeassistant == false ) | .slug' | wc -l)


echo "Count: all:${COUNT_ALL} full:${COUNT_FULL} core:${COUNT_CORE} addon:${COUNT_ADDON}"
echo "Remove: ${#REMOVE_LIST[@]}"
REMOVE_LIST+=( $(echo ${HA_BACKUPS} | jq -r '.data.backups | sort_by(.date) | reverse | .[] | select(.type == "full") | .slug' | tail +${KEEP_FULL}) )
echo "Remove full: ${#REMOVE_LIST[@]}"
REMOVE_LIST+=( $(echo ${HA_BACKUPS} | jq -r '.data.backups | sort_by(.date) | reverse | .[] | select(.type == "partial" and .content.homeassistant == true) | .slug' | tail +${KEEP_CORE}) )
echo "Remove core: ${#REMOVE_LIST[@]}"

for ADDON in $(echo ${HA_BACKUPS} | jq -r '.data.backups | sort_by(.date) | reverse | map(select(.type == "partial" and .content.homeassistant == false)) |{ addons: .[].content.addons[] } ' | jq  -r -s '. | unique |.[] | .addons'); do
    REMOVE_LIST+=( $(echo ${HA_BACKUPS} | jq -r '.data.backups | sort_by(.date) | reverse | .[] | select(.type == "partial" and .content.homeassistant == false and (.name |startswith("addon_'${ADDON}'")) ) | .slug' | tail +${KEEP_ADDON}) )
    echo "Remove ${ADDON}: ${#REMOVE_LIST[@]}"
done
for ITEM in ${REMOVE_LIST[@]}; do
    echo -n "Removing: ${ITEM} ... "
    [ ${DRY_RUN:-0} -eq 0 ] && _result=$(ha --raw-json backups remove ${ITEM} | jq -r '.result')
    echo ${_result:-dry_run}
done
) > "${SCRIPT_LOG}"
