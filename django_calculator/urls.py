"""
URL configuration for django_calculator project.
"""
from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    # Include the URLs from our calculator app for the root path
    path('', include('calculator.urls')),
]
