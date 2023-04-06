#!/bin/sh
# From: https://github.com/go-gitea/gitea/blob/main/docker/root/usr/bin/entrypoint

if [ ! -x /bin/sh ]; then
  echo "Executable test for /bin/sh failed. Your Docker version is too old to run Alpine 3.14+ and Gitea. You must upgrade Docker.";
  exit 1;
fi

if [ "${USER}" != "git" ]; then
    sed -i -e "s/^git\:/${USER}\:/g" /etc/passwd
fi

if [ -z "${USER_GID}" ]; then
  USER_GID="`id -g ${USER}`"
fi

if [ -z "${USER_UID}" ]; then
  USER_UID="`id -u ${USER}`"
fi

## Change GID for USER?
if [ -n "${USER_GID}" ] && [ "${USER_GID}" != "`id -g ${USER}`" ]; then
    sed -i -e "s/^${USER}:\([^:]*\):[0-9]*/${USER}:\1:${USER_GID}/" /etc/group
    sed -i -e "s/^${USER}:\([^:]*\):\([0-9]*\):[0-9]*/${USER}:\1:\2:${USER_GID}/" /etc/passwd
fi

## Change UID for USER?
if [ -n "${USER_UID}" ] && [ "${USER_UID}" != "`id -u ${USER}`" ]; then
    sed -i -e "s/^${USER}:\([^:]*\):[0-9]*:\([0-9]*\)/${USER}:\1:${USER_UID}:\2/" /etc/passwd
fi

for FOLDER in /data/gitea/conf /data/gitea/log /data/git /data/ssh; do
    mkdir -p ${FOLDER}
done

initialize_install() {
    inotifywait -e create /data/gitea/conf
    sleep 10
    su -c "gitea admin user create --admin --username $GITEA_ADMIN_NAME --password $GITEA_ADMIN_PASSWORD --email $GITEA_ADMIN_EMAIL" git
    su -c "gitea admin auth add-ldap \
        --name $LDAP_NAME \
        --host $LDAP_HOST \
        --port $LDAP_PORT \
        --bind-dn $LDAP_BIND_DN \
        --bind-password $LDAP_BIND_PASSWORD \
        --user-search-base '$LDAP_USER_BASE' \
        --user-filter '$LDAP_USER_FILTER' \
        --admin-filter '$LDAP_ADMIN_FILTER' \
        --username-attribute $LDAP_ATTRIBUTE_USERNAME \
        --email-attribute $LDAP_ATTRIBUTE_EMAIL \
        --firstname-attribute $LDAP_ATTRIBUTE_FIRST_NAME \
        --surname-attribute $LDAP_ATTRIBUTE_LAST_NAME \
        --security-protocol unencrypted \
        --synchronize-users\
    " git
}

if [ ! -f /data/.first_run ]; then
    touch /data/.first_run
    initialize_install &
fi

if [ $# -gt 0 ]; then
    exec "$@"
else
    exec /bin/s6-svscan /etc/s6
fi