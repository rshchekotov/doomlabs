# syntax=docker/dockerfile:1.3
FROM osixia/openldap:1.5.0
ARG LDIF_DIR=/container/service/slapd/assets/config/bootstrap/ldif/custom
# TODO: Improve this as soon as Terraform introduces secrets on build time
# * https://pythonspeed.com/articles/docker-build-secrets/
# * https://mattkubilus.medium.com/keeping-quiet-with-your-docker-build-time-secrets-7893ae438490
COPY --chown=911:911 ./secret/base.ldif ${LDIF_DIR}/base.ldif
COPY --chown=911:911 ./secret/users.ldif ${LDIF_DIR}/users.ldif