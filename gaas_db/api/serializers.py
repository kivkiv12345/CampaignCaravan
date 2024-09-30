from rest_framework import serializers
from .models import Deck, DeckCard

class DeckSerializer(serializers.ModelSerializer):
    class Meta:
        model = Deck
        fields = '__all__'  # You can specify individual fields if needed

class DeckCardSerializer(serializers.ModelSerializer):
    class Meta:
        model = DeckCard
        fields = '__all__'
