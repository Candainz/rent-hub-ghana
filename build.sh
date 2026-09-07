#!/usr/bin/env bash
set -o errexit

cd rent_hub_ghana/backend

pip install -r requirements.txt
python manage.py collectstatic --no-input
python manage.py migrate