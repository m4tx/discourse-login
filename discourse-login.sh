#!/bin/bash

set -e

function error() {
	echo $1 1>&2
	exit 1
}

conf_path="$HOME/.config/discourse-login.conf"
if [ ! -f ${conf_path} ]; then
	error "Configuration file not found: $conf_path"
fi
source ${conf_path}

for v in DISCOURSE_USERNAME DISCOURSE_PASSWORD DISCOURSE_URL \
	DISCOURSE_TO_VISIT; do
	if [ -z ${!v} ]; then
		error "Config variable not set: $v"
	fi
done

set -u

cookies=$(mktemp)
trap "rm -f ${cookies}" 0

csrf=$(curl -j -b ${cookies} -c ${cookies} "${DISCOURSE_URL}/session/csrf" \
	-H 'X-Requested-With: XMLHttpRequest' \
	--compressed -sfS \
	| sed -ne 's/{"csrf":"\(.\+\)"}/\1/p')
if [ -z ${csrf} ]; then
	error 'Could not get CSRF token!'
fi

curl -X POST -b ${cookies} -c ${cookies} "${DISCOURSE_URL}/session" \
	-H 'X-Requested-With: XMLHttpRequest' \
	-H "X-CSRF-Token: $csrf" \
	--data-urlencode "login=${DISCOURSE_USERNAME}" \
	--data-urlencode "password=${DISCOURSE_PASSWORD}" \
	--data-urlencode "second_factor_method=1" \
	--compressed -sfS >/dev/null \
	|| error 'Could not create session!'
curl -X POST -b ${cookies} -c ${cookies} "${DISCOURSE_URL}/login" \
	--data-urlencode "login=${DISCOURSE_USERNAME}" \
	--data-urlencode "password=${DISCOURSE_PASSWORD}" \
	--compressed -sfS >/dev/null \
	|| error 'Could not sign in the user!'
curl -b ${cookies} -c ${cookies} "${DISCOURSE_URL}/${DISCOURSE_TO_VISIT}" \
	--compressed -sfS >/dev/null \
	|| error 'Could not visit TOPIC-TO-VISIT!'

echo "Visited the website successfully at $(date)"
