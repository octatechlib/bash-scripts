#!/bin/bash

export TZ="/usr/share/zoneinfo/Europe/Amsterdam"

TIMEZONE="Europe/Amsterdam"
echo $TIMEZONE > /etc/timezone
cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime

TS=$(date +%s%3N);
INIT_HR=$(date +"%T");
DUMPS_DIR="/tmp/scripts-installed";
DUMP_FILE="octa.dump.sql";
DEFAULT_DB="dump_${TS}";
DUMP_FILE_DIR="/var/lib/mysql/dumps/"
DUMP_PATH="${DUMP_FILE_DIR}${DUMP_FILE}"

echo -e ">>> \e[32m[Insert DB name to import (default: ${DEFAULT_DB}) ]\e[39m > \e[33m[Waiting...] \e[39m[${INIT_HR}]\e[39m";
echo -e "";

echo -e "Enter DB name. Enter to choose default:";
read DB_NAME

if [[ -z ${DB_NAME} ]]; then
  # set db as default name
  DB_NAME="${DEFAULT_DB}"
  echo -e ">>> Default \e[34mdatabase selected:\e[39m \e[32m[${DB_NAME}]\e[39m";
else
  # take given by hand
  echo -e ">>> Custom \e[34mdatabase selected:\e[39m  \e[32m[${DB_NAME}]\e[39m";
fi

echo -e ">>> \e[34mImporting into: \e[39m           \e[32m[${DB_NAME}]\e[39m";
echo -e "";

#if sql file mapped
if [ -f ${DUMP_PATH} ]; then

  #proceed
  echo "Enter username:"
  read USER_NAME
  echo -e ""

  if [[ -z ${USER_NAME} ]]; then
    echo -e ">>> Empty username!";
    echo -e ">>> \e[32m[Import]\e[39m > \e[31m[Aborted!!!]\e[39m";
  else
    echo -e "User:";
    echo -e ">>> \e[32m${USER_NAME}\e[39m";

    # user given, deal with database
    echo -e ">>> \e[34mCreating database:\e[39m \e[32m[${DB_NAME}]\e[39m";
    echo -e "mysql>";

    # creating (no check if exists)
    #/usr/bin/mysql -u ${USER_NAME} -p -e "SHOW DATABASES; CREATE DATABASE ${DEFAULT_DB}; SHOW DATABASES; ";
    /usr/bin/mysql -u "${USER_NAME}" -p -e "CREATE DATABASE ${DB_NAME};";
    echo -e ">>> \e[34mDatabase created: \e[39m \e[32m[${DB_NAME}]\e[39m";

    # run import
    START_HR=$(date +"%T");
    echo -e ">>> \e[34mImporting into:   \e[39m \e[32m[${DB_NAME}]\e[39m [STARTING] [${START_HR}]";
    /usr/bin/mysql -u "${USER_NAME}" -p "${DB_NAME}" < "${DUMP_PATH}";

  fi

else
	echo "${DUMP_PATH} file DOES NOT exist.";

fi

END_HR=$(date +"%T");
echo -e ">>> \e[34mImporting into:   \e[39m \e[32m[${DB_NAME}]\e[39m [DONE] [${END_HR}]";


TS_END=$(date +%s%3N);
TS_ELAPSED="$((TS_END-TS))"
SEC_ELAPSED="$((TS_ELAPSED/1000))"
TIME_ELAPSED="$SEC_ELAPSED sec."

if [ "$SEC_ELAPSED" -gt 60 ]; then
    TIME_ELAPSED="$((SEC_ELAPSED/60)) min."
fi

echo -e ">>> TIME ELAPSED \e[32m[${TIME_ELAPSED}]\e[39m";
echo "____________________________________________________________________";
