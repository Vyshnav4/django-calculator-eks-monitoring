from django.urls import path
from . import views

# Defines the URL patterns for the calculator app.
urlpatterns = [
    # Maps the root URL of the app to the 'index' view
    path('', views.index, name='index'),
]
