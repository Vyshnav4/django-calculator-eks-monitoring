
FROM python:3.9-slim-buster
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Create a non-root user and set up their home directory.
RUN useradd -m -d /home/appuser -s /bin/bash appuser

# Create the application directory inside the user's home and staticfiles directory.
WORKDIR /home/appuser/app
RUN mkdir -p staticfiles
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY --chown=appuser:appuser . .
RUN python manage.py collectstatic --noinput
RUN chown -R appuser:appuser /home/appuser
USER appuser
EXPOSE 8000
CMD ["gunicorn", "django_calculator.wsgi:application", "--bind", "0.0.0.0:8000"]
