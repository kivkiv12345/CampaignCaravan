

.. |module_image| image:: ../campaigncaravangame/CardTextures/k_spades_king.jpeg
    :width: 8cm


Læsevejledning
----------------------------------------
I visse tilfælde vil denne rapport gøre brug af supplementerende internetlinks.
I tilfælde hvor læseren ønske følge disse links, bedes de venligst benytte en aktiv internetforbindelse.
Denne produktrapport er forsøgt vidt mulig uafhængig af dens tilsvarende `procesrapport <https://github.com/kivkiv12345/CampaignCaravan/blob/master/docs/procesrapport.rst>`_ (link til .rst format).


Kravspecifikation og Accepttest
----------------------------------------

.. include:: kravspecifikation.rst


Kernen bag accepttesten er at spillet opfylder kravene stillet af kortspillets Karavanes spilleregler.
Disse spilleregler ses nedenunder:


Karavane Spilleregler
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    Kortspillet Karavane spilles normalt mellem 2 modstandere,
    hvor hver medbringer et dæk af 30-108 normale spillekort.
    (Typisk kræves det at disse dæk sammensættes af kortene fundet i 2 normale sæt af spillekort.
    Hvilket forhindrer at spillere medbringer ene 10'ere, for eksempel).

    **Vinde/Tabe**

        Den eftertragtede måde at vinde spillet er ved at lægge værdien af hver af sine 3 karavaner mellem 21-26 (inklusiv) (og hermed "sælge" dem).
        Samtidigt skal ens karavane også overbyde (have en højere værdi end) modstanderens overstående karavane.

        .. image:: Pictures/HowToWinOverburdened.png

        I tilfælde hvor 2 overstående karavaner står lige (har samme værdi), vil dette forhindre spillet i at slutte.

        .. image:: Pictures/HowToWinTied.png

        Dog er spillet lavet således at det er tilstrækkeligt at én af hver af de modstående karavaner sælges.
        Hermed vinder spilleren som har solgt flest (2/3) karavaner.

        .. image:: Pictures/HowToWin2Caravans.png

        Spiller man sit sidste kort uden at vinde, taber man automatisk spillet.


    **Numeriske Kort**

        Numeriske kort er de typisk spillede kort,
        som bygger den numeriske værdi af karavanen hvorpå de spilles.
        Numeriske kort adderer deres skrevne værdi til karavanen
        (spillet man en 10'er, øges karavanens værdi med 10).

        Esset tildeles en numerisk værdi af 1, og tjener kun et specialt formål i sammenspil med en joker.

        Under ingen omstændigheder kan 2 kort af samme numeriske værdi spilles på hinanden.
        Derfor vil karavaner med mindst 2 kort spillet tildeles en retning (stigende/faldende).
        Herefter er det, som udgangspunkt, ikke muligt at spille numeriske kort som bryder denne retning.
        Retningen kan dog vendes ved enten at spille en dame (på det nederste numeriske kort),
        eller ved at spille et numerisk kort af samme (effektive) kulør (som det nederste numeriske kort).

        Karavanens retning følger derfor retningen sat af de 2 nederste numeriske kort.

    **Ansigtskort**

        Ansigtskort kan spilles på et hvert numerisk kort (sine egne, såvel som modstanderens),
        hvorefter de yder specialle formål.
        Det er muligt at spille flere ansigtskort på samme numeriske kort.

        * Knægt
            Når knægten spilles på et numerisk kort, fjernes dette kort fra spillet (og dermed alle ansigtkort spillet derpå).

        * Dame
            Damen ændrer den effektive kulør af kortet hvorpå hun er spillet,
            samtidig med at hun også ændrer retningen af karavanen (hvis spillet på det nederste kort).

        * Konge
            Kongen fordobler værdien af kortet hvorpå han er spillet.
            Hvis flere konger spilles på samme numeriske kort, ændres værdien multiplikativt (9, 18, 36, 72, ...).

        * Joker
            I en vis forstand fungerer jokeren som en modsætningen af knægten.
            Når en joker spilles på et numerisk kort,
            fjernes alle andre kort, af samme numeriske rank, fra alle karavanerne i spillet.

            Spiller man en joker på et es, fjernes alle andre kort med samme kulør (som esset) i stedet.




        Projektet her pastræber sig at kunne tilpasses spillerens ønskede spilleregler.
        Til dette formål findes klassen GameRules, som besidder en række variable som påvirker spillereglerne.
        Denne klasse kan instantieres forskelligt for de 2 spillere,
        og kan dermed udjævne færdighedsniveauforskelle mellem spillerne (tillade én spille 6 kort på hånden, for eksempel).

        .. image:: Pictures/GameRules.png




Database
--------------
https://2shady4u.github.io/godot-sqlite/



Sikkerhed
-----------------------------------

Spillet's brug af en SQlite database, sikre at ingen personfølsom data lagres udenfor spillerens kontrol.
Herudover lagrer spillet ingen personfølsom data.
Havde der været gjort brug af en Database server,
ville det være nødvendigt at oprette og vedligeholde forbindelsen hertil gennem en sikker krypteret protokol.
(typisk HTTPS hvis databasen tilgås via et web-API)
Herudover ville det også være nødvendigt at afgrænse synligheden af databasen mellem brugere,
således forskellige brugere ikke kan tilgå uhensigtmæssige/personfølsomme dele af hinandens data.

En HTTPS sikret forbindelse benyttes til at tilgå/downloade de forskellige udgaver af spillet.
Dette sikrer at en mellemmand ikke kan servere en ondsindet modificering af spillet.
Derudover er kildekoden tilgængelig,
således at en tilpas teknisk kyndig spiller kan undersøge kildekoden for ondsindede hensigter og sikkerhedsbrud.


Brugervejledning
-----------------------------------

Overordnet set distribueres spillet i 2 udgaver:

- Den webbaserede udgave. Her er ingen installation nødvendig, og spillet kan enkeltvis tilgås her: https://kivkiv12345.github.io/CampaignCaravan/

- De downloadede udgaver (Linux, Windows), hvoraf de nyeste versioner kan findes her: https://nightly.link/kivkiv12345/CampaignCaravan/workflows/godot-ci/master?preview

    Installation heraf forekommer enkeltvis i form af udpakningen af .zip filen. I tilfælde a Linux udgaven bør binærfilen laves eksekverbar med kommandoen: **chmod u+x caravan.x86_64**,
    herefter kan spillet startes med **./caravan.x86_64**


Bemærk at de downloadede udgaver nyder udvidet funktionalitet (i form af persistent lagring af tilpassede kortdæk).



.. _hovedmenuen:

Hovedmenuen
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Spillet starter på hovedmenuen, hvor brugeren mødes af de følgende valgmuligheder:

- **"Play"**: Som hurtigt starter et spil med normale spilleregler, og fører derefter direkte videre til `selveste spillet`_

- **"Custom Game"**: Som viderefører brugen til `spilopsætningsmenuen`_, hvor de mødes af et bredt udvalg af tilpasninger til spillet.

- **"How to Play"**: Som åbner en `tilsvarende modal`_ med en forklaring af spillereglerne.

- **"Exit"**: Denne knap lukker spillet. Bemærk dog at den er fjernet i browserudgaven, hvor det forventes at brugeren lukker browservinduet i stedet.


.. _spilopsætningsmenuen:

Spilopsætningsmenuen
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

På denne menu kan spilleren tilpasse et bredt udvalg af regler og spilleindstillinger.
Menuen tillader at spilleren tilpasser sine egne og modstanderens indstillinger uafhængigt af hinanden.
Dette giver dermed et bredt udvalg til tilpasninger af sværhedsgraden på spillet.

I den downloadede version forekommer knappen: Deck -> Customize.
Trykker spilleren på denne, vil deres tilpasninger til autogenerede dæk
i stedet udskiftes med muligheden for at vælge et tilpasset dæk.
For at tilpasse et dæk, og dermed skabe valgmuligheder for denne menu,
kan brugeren her trykke på: Deck -> Manage Decks,
Dette viderefører dem til `dæktilpasningsmenuen`_

.. image:: Pictures/CustomGame.jpeg



.. _dæktilpasningsmenuen:

Dæktilpasningsmenuen
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Denne menu tillader brugen at: skabe, ændre og slette tilpassede spillekortdæk.

Bemærk dog at dette, på nuværende tidspunkt, ikke er muligt i den browserbaserede udgave af spillet.

Til venstre, nær bunden, af vinduet ses et billede af hver af de 54 forskellige spillekort.
Trykker spilleren på et af disse billeder,
tilføjes ét af disse kort til deres igangværende ændring af det valgte eller nye spillekortdæk.
Holder spilleren CTRL knappen nede mens de trykker, fjernes ét af disse kort i stedet.
Og holder SHIFT tilføjes 5 kort i stedet.
Holder brugeren både CTRL og SHIFT, fjernes 5 kort.

Når brugeren har valgt de ønskede spillekort, skal dækket tildeles et navn i feltet "Deck Name".
Herefter kan de trykke på knappen "Save Deck", som gemmer dækket i databasen.
Dæk gemt i databasen vises i vinduet under "Save Deck" knappen.
Her kan brugeren enten trykke på dækket navn, og vælge det for visning og tilpasning.
Eller trykke på navnets tilsvarende "Delete" knap, og slette dækket fra databasen.

Slettes det valgte dæk, vil kortene deri ikke fjernes fra vinduet med tilføjede kort.
Hvilket gør det nemt at gemme et nyt dæk, lignende det gamle.

Når brugeren trykker på knappen "Back", føres de tilbage til `spilopsætningsmenuen`_,
hvorefter deres ændringer til være synlige i det udfoldelige felt: Deck -> Customize -> Custom Deck.

.. image:: Pictures/DeckCustomizer.jpeg



.. _tilsvarende modal:

"How To Play" modalen
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Spillet indeholder en simpel indbygget forklaring af spillereglerne.
Denne forklaring er løftet fra det officielle Caravans' tilsvarende `Wiki <https://fallout.fandom.com/wiki/How_to_play_Caravan>`_

Som nævnt i modalen, er der mange måder, hvor spillet forsøger sig nemt at lære gennem eksperimentation.
Derfor skal forklaring i denne modal ikke tolkes som en nødvendighed for at spille spillet.


F.eks farvelægger spillet en karavanes værdi, for at indikere hvor vidt den er: solgt, underbyrdet (stadard gul), overbyrdet (rød), ligestillet med modstander karavane (blå).
Dette afviger fra de officielle spil, hvor værdien kun underlægges en special farve når dens tilsvarende karavane er overbyrdet.

Herudover synliggører denne udgave heller ikke kortpladser hvor et løftet kort ikke kan spilles.


.. image:: Pictures/HowToPlay.jpeg



.. _`selveste spillet`:

Selveste spillet
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Spillet spilles mod en CPU/bot modstander, som følger en prædefineret algoritme,
som forhindrer at den spiller direkte mod sine egne interesser.

Når spillet starter vil de 6 forskellige "karavaner" være tomme,
og spilleren vil have mulighed for at trække (med musen) ét af deres numeriske kort til en af deres karavaner.
Herefter vil modstanderen gøre det samme.

.. image:: Pictures/MainGame.jpeg

Igangværende spil kan pauses ved at trykke på ESCAPE, hvilket frembringer pause modalen.

Her har spilleren mulighed for at trykke:

- **"Continue"**: Som enkeltvis lukker modalen, og fortsætter spillet. Denne knap er ikke tilgængelig efter spillet er vundet/tabt.

- **"Restart"**: Som starter spillet forfra. Hvis dette spil er startet gennem `spilopsætningsmenuen`_, følger reglerne valgt heri med i det nye spil.

- **"Main Menu"**: Som enkeltvis fører spilleren tilbage til `hovedmenuen`_.

- **"Quit"**: Denne knap lukker spillet. Bemærk dog at den er fjernet i browserudgaven, hvor det forventes at brugeren lukker browservinduet i stedet.

.. image:: Pictures/GameInProgress.jpeg

