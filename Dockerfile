# Use a slim Python image for a smaller final image size.
# This is our base image for the application.
FROM python:3.9-slim-buster

# Set environment variables to optimize Python's behavior in Docker:
# PYTHONDONTWRITEBYTECODE: Prevents Python from writing .pyc files to disk.
# PYTHONUNBUFFERED: Ensures Python output (e.g., print statements) is not buffered,
#                   making logs appear in real-time.
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Create a non-root user and set up their home directory.
# Running as a non-root user is a security best practice.
# 'appuser' will be the user running our Django application.
RUN useradd -m -d /home/appuser -s /bin/bash appuser

# Create the application directory inside the user's home and staticfiles directory.
WORKDIR /home/appuser/app
RUN mkdir -p staticfiles

# Copy the requirements file into the container.
# This step is done early to leverage Docker's layer caching.
# If requirements.txt doesn't change, this layer won't rebuild.
COPY requirements.txt .

# Install Python dependencies specified in requirements.txt.
# --no-cache-dir saves space by not caching pip downloads.
RUN pip install --no-cache-dir -r requirements.txt

# Copy all your application code into the container.
# We change ownership to 'appuser' immediately for security.
COPY --chown=appuser:appuser . .

# Run Django's collectstatic command to gather all static files.
# This command needs to run as a user with sufficient permissions (root, before switching to appuser).
# It will collect static files into /home/appuser/app/staticfiles.
RUN python manage.py collectstatic --noinput

# Ensure the entire application directory is owned by 'appuser'.
RUN chown -R appuser:appuser /home/appuser

# Switch to the non-root 'appuser'.
# All subsequent commands and the application itself will run as this user.
USER appuser

# Expose port 8000. This tells Docker that the container listens on this port
# at runtime. You'll need to map this port when running the container.
EXPOSE 8000

# Define the default command to run when the container starts.
# This uses Gunicorn to serve your Django application.
# 'django_calculator.wsgi:application' should be replaced with your actual project's WSGI path.
CMD ["gunicorn", "django_calculator.wsgi:application", "--bind", "0.0.0.0:8000"]
