
from api.views import user_logout, user_login
from rest_framework.authtoken import views as authviews
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import DeckViewSet, DeckCardViewSet

# Create a router and register our viewsets with it
router = DefaultRouter()
router.register(r'decks', DeckViewSet)
router.register(r'deck-cards', DeckCardViewSet)

# print(router.urls)

urlpatterns = [

    path(f"token-auth/", authviews.obtain_auth_token),
    path(f"user-login/", user_login, name="user-login"),
    path(f"user-logout/", user_logout, name="user-logout"),
    
    path('', include(router.urls)),
]
