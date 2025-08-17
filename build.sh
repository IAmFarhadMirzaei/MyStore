#!/usr/bin/env bash
set -o errexit
set -x

pip install -r requirements.txt

python manage.py migrate

python -c "
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'MyStore.settings')  # <-- اسم پروژه‌ات رو اینجا بزار
django.setup()

from django.contrib.auth import get_user_model

User = get_user_model()
username = os.environ.get('SUPERUSER_USERNAME')
email = os.environ.get('SUPERUSER_EMAIL')
password = os.environ.get('SUPERUSER_PASSWORD')

if username and email and password:
    if not User.objects.filter(username=username).exists():
        User.objects.create_superuser(username, email, password)
        print('Superuser created.')
    else:
        print('Superuser already exists.')
else:
    print('Superuser environment variables are not fully set. Skipping superuser creation.')
"

python manage.py collectstatic --noinput || echo 'collectstatic failed, but continuing'
