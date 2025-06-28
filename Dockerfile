# --- Stage 1: Build Stage (This stage is fine, no changes needed) ---
FROM python:3.9-slim AS builder

# Set environment variables using the recommended key=value format
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

COPY requirements.txt .
RUN pip install --upgrade pip
# Create wheel files for our dependencies
RUN pip wheel --no-cache-dir --wheel-dir /app/wheels -r requirements.txt


# --- Stage 2: Final, Production Stage (This is where we make the changes) ---
FROM python:3.9-slim

# Set environment variables again for this stage
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install dependencies AS ROOT so they are available system-wide
# This is the key change to fix the error
COPY --from=builder /app/wheels /wheels
RUN pip install --no-cache-dir /wheels/*

# Now, create the non-root user and the app directory
RUN useradd -m -d /home/appuser -s /bin/bash appuser
RUN mkdir -p /home/appuser/app/staticfiles

# Set the working directory
WORKDIR /home/appuser/app

# Copy the application code from the current directory to the container
COPY --chown=appuser:appuser . .

# Run collectstatic. The 'root' user is still active and can find the
# system-wide packages. It will collect files into /home/appuser/app/staticfiles
RUN python manage.py collectstatic --noinput

# Change ownership of the entire app directory to the non-root user
RUN chown -R appuser:appuser /home/appuser

# Finally, switch to the non-root user for security before running the app
USER appuser

# Expose the port the app runs on
EXPOSE 8000

# Define the command to run the application
CMD ["gunicorn", "django_calculator.wsgi:application", "--bind", "0.0.0.0:8000"]
