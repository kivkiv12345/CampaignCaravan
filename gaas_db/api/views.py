# With inspiration from https://chat.openai.com


from __future__ import annotations

from typing import NamedTuple, Any

from django.contrib.auth import logout, authenticate, login
from django.core.exceptions import ObjectDoesNotExist
from django.http import JsonResponse
from django.shortcuts import render
from rest_framework import status
from rest_framework.authentication import SessionAuthentication, BasicAuthentication, TokenAuthentication
from rest_framework.authtoken.models import Token
from rest_framework.decorators import api_view, authentication_classes, permission_classes, action
from rest_framework.permissions import IsAuthenticated
from rest_framework.request import Request
from rest_framework.response import Response
from django.contrib.auth.models import User, AnonymousUser
from django_filters.rest_framework import DjangoFilterBackend


from rest_framework import viewsets
from .models import Deck, DeckCard
from .serializers import DeckSerializer, DeckCardSerializer



# Source: https://chat.openai.com
class DeckViewSet(viewsets.ModelViewSet):
    queryset = Deck.objects.all()
    serializer_class = DeckSerializer
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]  # Only authenticated users can access
    
     # Custom action to delete a deck by name
    @action(detail=False, methods=['DELETE'], url_path='delete-by-name/(?P<name>[^/.]+)')
    def delete_by_name(self, request, name=None):
        try:
            # Find the deck by name
            deck = Deck.objects.get(name=name)
        except Deck.DoesNotExist:
            return Response({"detail": f"Deck with name '{name}' does not exist."}, status=status.HTTP_204_NO_CONTENT)
        else:  # Successfully found deck
            deck.delete()  # Delete the deck
            return Response({"detail": f"Deck '{name}' deleted successfully."}, status=status.HTTP_200_OK)


    # Custom action to handle saving deck and its cards
    @action(detail=False, methods=['POST'], url_path='save')
    def save_deck(self, request):
        # Get the deck data from the request
        deck_data = request.data.get('name')
        cards_data = request.data.get('cards')

        if not deck_data or not cards_data:
            return Response({"detail": "Deck name and cards are required."}, status=status.HTTP_400_BAD_REQUEST)

        # Handle deck creation or update
        try:
            deck, created = Deck.objects.get_or_create(name=deck_data)
            # Clear any existing deck cards before updating (optional)
            deck.deckcard_set.all().delete()

            # Add the new deck cards
            for card in cards_data:
                DeckCard.objects.create(
                    deck=deck,
                    suit=card['suit'],
                    rank=card['rank'],
                    count=card['count']
                )

            return Response({"detail": "Deck saved successfully."}, status=(status.HTTP_201_CREATED if created else status.HTTP_200_OK))
        
        except Exception as e:
            return Response({"detail": str(e)}, status=status.HTTP_400_BAD_REQUEST)


class DeckCardViewSet(viewsets.ModelViewSet):
    queryset = DeckCard.objects.all()
    serializer_class = DeckCardSerializer
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]  # Only authenticated users can access
    filter_backends = [DjangoFilterBackend]  # Enable filtering
    filterset_fields = ['deck__name']  # Allow filtering by deck name, which we will then do in GDScript


@api_view(['POST'])
def user_login(request: Request) -> Response:
    """
    Expected JSON:
    {
        "username": str,
        "password": str
    }
    """

    data: dict = request.data

    username: str = data.get('username')
    password: str = data.get('password')

    if None in (username, password):
        return Response('Request must include both "username" and "password"', status=status.HTTP_400_BAD_REQUEST)

    user: User | None = authenticate(request, username=username, password=password)

    if user is None:
        return Response('Invalid username or password', status=status.HTTP_400_BAD_REQUEST)

    if not user.is_active:
        return Response('User is disabled', status=status.HTTP_400_BAD_REQUEST)

    login(request, user)
    token, created = Token.objects.get_or_create(user=user)
    return Response({'token': token.key}, status=status.HTTP_200_OK)


@api_view(['POST'])
@authentication_classes([SessionAuthentication, TokenAuthentication])
def user_logout(request: Request) -> Response:
    """
    Expected JSON:
    {
        "token": str,
    }
    """

    request.user.auth_token.delete()
    logout(request)
    return Response({'detail': 'Logged out successfully.'}, status=status.HTTP_200_OK)
