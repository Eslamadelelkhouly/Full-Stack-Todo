from django.shortcuts import render
from rest_framework import generics
from .models import Todo
from .serializers import TodoSerializer
# Create your views here.

# GET UPDATE DELETE

class TodoGet(generics.ListCreateAPIView):
    queryset = Todo.objects.all()
    serializer_class = TodoSerializer

class TodoUpdateDelete(generics.RetrieveUpdateDestroyAPIView):
    queryset = Todo.objects.all()
    serializer_class = TodoSerializer
