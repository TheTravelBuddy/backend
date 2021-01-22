#!/bin/sh

# --batch to prevent interactive command
# --yes to assume "yes" for questions
gpg --quiet --batch --yes --decrypt --passphrase="$ENCRYPTION_KEY" \
    --output ./.env ./.env.gpg
gpg --quiet --batch --yes --decrypt --passphrase="$ENCRYPTION_KEY" \
    --output ./deploy/db-secret.yml ./deploy/db-secret.yml.gpg