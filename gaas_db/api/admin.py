from django.contrib import admin
from django.contrib.admin import ModelAdmin, TabularInline

from .models import Deck, DeckCard


class CardInline(TabularInline):
    model = DeckCard
    extra = 0


class DeckAdmin(ModelAdmin):
    inlines = [CardInline]


# Register your models here.
admin.site.register(Deck, DeckAdmin)
admin.site.register(DeckCard, )
