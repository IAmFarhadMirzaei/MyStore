#!/usr/bin/env bash
set -o errexit

pip install -r requirements.txt

python manage.py migrate

# بررسی وجود سوپریوزر و ساخت فقط در صورت نبودن
python manage.py shell << END
from django.contrib.auth import get_user_model
import os

User = get_user_model()
username = os.environ.get("SUPERUSER_USERNAME")
email = os.environ.get("SUPERUSER_EMAIL")
password = os.environ.get("SUPERUSER_PASSWORD")

if username and email and password:
    if not User.objects.filter(username=username).exists():
        User.objects.create_superuser(username, email, password)
        print("Superuser created.")
    else:
        print("Superuser already exists.")
else:
    print("Superuser env variables are not fully set.")
END

python manage.py collectstatic --noinput
