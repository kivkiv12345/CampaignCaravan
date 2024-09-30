from django.db import models
from django.db.models import Model, TextChoices, ManyToManyField, ForeignKey, CharField, IntegerField
from django.utils.translation import gettext_lazy as _
from django.core.exceptions import ValidationError


# class Card(Model):
#     pass


class Deck(Model):
    name = CharField(max_length=128, null=False, blank=False, unique=True)
    
    def __str__(self) -> str:
        return f"{self.name} [{self.pk}]"


class DeckCard(Model):

    class Suit(TextChoices):
        # NONE = (0, _('None'))
        CLOVER = (1, _('Clover'))
        DIAMOND = (2, _('Diamond')),
        HEARTS = (3, _('Hearts')),
        SPADES = (4, _('Spades')),
        JOKER0 = (5, _('Joker0')),
        JOKER1 = (6, _('Joker1'))

    class Rank(TextChoices):
        # NONE = (0, _('None'))
        ACE = (1, _('Ace'))
        TWO = (2, _('Two'))
        THREE = (3, _('Three'))
        FOUR = (4, _('Four'))
        FIVE = (5, _('Five'))
        SIX = (6, _('Six'))
        SEVEN = (7, _('Seven'))
        EIGHT = (8, _('Eight'))
        NINE = (9, _('Nine'))
        TEN = (10, _('Ten'))
        JACK = (11, _('Jack'))
        QUEEN = (12, _('Queen'))
        KING = (13, _('King'))
        JOKER = (14, _('Joker'))
    
    def _validate_num_cards(self, value: int) -> None:
        if value < 1:
            raise ValidationError("Card count can't be less than 1")

    deck = ForeignKey(Deck, on_delete=models.CASCADE)
    count = IntegerField(validators=(_validate_num_cards,))
    suit = CharField(max_length=15, choices=Suit.choices)
    rank = CharField(max_length=6, choices=Rank.choices)
    
    def __str__(self) -> str:
        return f"{self.get_suit_display()} {self.get_rank_display()} x {self.count}"
    
    class Meta:
        
        unique_together = ('suit', 'rank', 'deck')
