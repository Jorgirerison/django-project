from django.http import HttpResponse
from django.shortcuts import render


def home(request):
    # name_space para não colidir com
    # outros arquivos
    return render(request, "recipes/home.html")


def contato(request):
    return HttpResponse("contato")


def sobre(request):
    return HttpResponse("sobre")
