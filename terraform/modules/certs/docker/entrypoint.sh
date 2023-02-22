#!/bin/bash

set -e

#region Create CRON Job
if [ ! -f /etc/periodic/daily/certs ]; then
  echo "Creating certs renewal cron script"
  cat <<EOF > /etc/periodic/daily/certs
  #!/bin/bash
  certbot renew
  chmod 755 /etc/letsencrypt/{live,archive}
  chmod 640 "/etc/letsencrypt/live/$DOMAIN/privkey.pem"
EOF
  chmod +x /etc/periodic/daily/certs
fi
#endregion

args=(
  --dns-cloudflare
  --dns-cloudflare-credentials /cloudflare.ini
  -d "$DOMAIN"
  -d "*.$DOMAIN"
  -m "root@$DOMAIN"
  --non-interactive
  --agree-tos
)

if [ "$ENVIRONMENT" != "production" ]; then
  args+=(--test-cert)
fi

certbot certonly "${args[@]}"
chmod 755 /etc/letsencrypt/{live,archive}
chmod 640 /etc/letsencrypt/live/$DOMAIN/privkey.pem

crond -f