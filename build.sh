#!/usr/bin/env bash
set -o errexit
set -x

echo "Installing dependencies..."
pip install -r requirements.txt

echo "Applying migrations..."
python manage.py migrate

echo "Creating superuser if environment variables are set..."
python -c "
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'MyStore.settings')  # اسم پروژه خودت رو بذار
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

echo "Checking STATICFILES_DIRS directory..."
if [ ! -d "./static" ]; then
  echo "Warning: ./static directory does not exist! Consider creating it or removing from STATICFILES_DIRS."
fi

echo "Collecting static files..."
python manage.py collectstatic --noinput || echo 'collectstatic failed, but continuing'

echo "Build script finished successfully."
exit 0
