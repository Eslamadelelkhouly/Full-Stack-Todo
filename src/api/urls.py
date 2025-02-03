from django.urls import path
from django.urls import include
from .views import TodoGet , TodoUpdateDelete
urlpatterns = [
    path('',TodoGet.as_view()),
    path('<int:pk>',TodoUpdateDelete.as_view()),
]
