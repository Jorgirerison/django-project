from django.shortcuts import render


def home(request):
    # name_space para não colidir com
    # outros arquivos
    return render(request, "recipes/pages/home.html", context={"name": "Jorgirerison"})
