
2/9-2024 (Mandag Uge #1)
-------------------
Første halvdel af dagen gik på introduktionen til svendeprøven. Herefter gik tiden på at udarbejde case-beskrivlsen og problemformulering.
Jeg havde stort set allerede besluttet mig for at lave Caravan (Trods det er ret anderledes fra min oprindelige forestilling om at lave noget low-level (med CSP fra lærepladsen)).
Så det var bare et spørgsmål om at skrive problemformulering. Her så jeg det som en balancegang mellem at beskrive spillet, uden af gå i dybden med reglerne deraf.
Tilfældigvis var det kun et par dage inden svendeprøven at jeg opdagede at den online version af Caravan, som jeg plejde at spille, tilsyneladende ikke længere fungerer.
Derfor ser jeg god grund til at lave en erstatning.
Det tog mig et par forsøg at formulere både problemformulering og case-beskrivelse som både jeg og Frank fra tilfredse med,
men nu skulle den gerne være i orden. Dog kommer bekræftiglsen først i morgen, så Lars også kan få kigget på den.

Jeg kom også til at bruge aftenen på at indsamle billeder/texturer til kortene i spillet,
hvor jeg var så heldig at finde https://www.reddit.com/r/fnv/comments/6xucbj/higher_definition_scans_of_the_playing_cards/.
Her har en gut været så venlig at indskanne kortene fra den officielle fysiske version af kortspillet.


3/9-2024 (Tirsdag Uge #1)
------------------
Jeg startede dagen med at kigge på drag-and-drop funktionalitet i Godot.
Min tanke er at kernefunkionaliten hurtigt kan udarbejdes,
så jeg kan vinde tid til at få spillet til både at se og føles godt.
I løbet af dagen bør jeg også kigge på kravspecifikationen,
da jeg endnu ikke har fastlåst mig afgrænsningen af funktionaliterne til spillet.
Jeg har ikke bestemt hvor vidt jeg vil fokusere på multiplayer vs AI (machine learning er ikke planlagt) modstandere.


4/9-2024 (Onsdag Uge #1)
------------------
Fokus i dag var funktionaliterne bag at trække kort fra sit dæk til sin hånd.
Dækket's constructor metode er lige nu mest ment til test,
hvor det genererer et tilfældigt dæk fra en given størrelse og seed.
Jeg ser seeding som vigtigt størstedelen af steder hvor tilfældighed indgår,
især til senere hvor disse funktioner også skal kunne testes.


5/9-2024 (Torsdag Uge #1)
------------------
Jeg vil starte dagen med at oprette signaler til når kort spilles.
I første omgang skal de bruges til at trække nye kort fra spillerens dæk,
da CardDropSlot noden ligger fjernt fra dæk noden, hvilket gør det svært for dem at snakke direkte.
Samtidig kunne signalet også bruges til at oprette et nyt CardDropSlot nederst i karavanen.
Men dette kunne formentlig også gøres enten som en linked list af CardDropSlots.
Da hvert NumericCardDropSlot altid ligger nederst i karavanen,
vil nye NumericCardDropSlots altid skulle oprettes under dette.
FaceCardSlots er lignende, hvor nye slots skal oprettes til højre i stedet.


6/9-2024 (Fredag Uge #1)
------------------
Jeg har efterhånden ændret hvordan OpenFaceCardSlot og OpenNumericCardSlot fungerer.
Som det fungerer nu har Caravan.tscn 2 undernoder: PlayedCards (som fungerer som en liste af PlayedNumericCardSlots)
og OpenNumericCardSlot. Hermed vedligeholder karavanen altid ét OpenNumericCardSlot, og flytter det løbende til at ligge i bunden af karavanen.
Når et kort lægges på denne plads, er det karavanens ansvar at tjekke om det er gyldigt,
mht til om karavanen er stigende eller faldende, eller om kortet lægges på modstanderens side.
På samme måde har PlayedNumericCardSlot.tscn også 2 undernoder: OpenFaceCardSlot og PlayedFaceCards.
Hermed vedligeholder PlayedNumericCardSlot.tscn sit OpenFaceCardSlot, på samme måde som Caravan.tscn med NumericCardDropSlot.
Dette tillader at man bruger nodetræet selv som sandhedskilde, mht. at administrere hvilke nummerkort underhører hvilke karavaner,
og hvilke ansigtskorts underhører hvilke nummerkort.
Dog har jeg alligevel valgt at indfører felter på klasserne,
da alternativene er enten at låse sig selv til en given nodestruktur ved at bruge .get_parent(),
eller en bestemt navngivning af noder ved brug af .find_parent().
I stedet gør jeg som udgangspunkt brug af signalet child_entered_tree(),
til at sikre at disse 'parent' variable sættes korrekt
(Se sammenspillet mellem PlayedNumericCardSlot._register_facecard_to_numbercard og FaceCardSlot.number_card).

Én udfordring jeg er stødt på CardSlot arvehierarkiet. GDScript understøtter ikke multipel nedarvning,
og bruger "ducktyping" fremfor formelle interfaces. 
Derfor har jeg været specialt udfordet med OpenFaceCardSlot, som jeg både vil nedarve fra OpenCardSlot og FaceCardSlot klasser.
En OpenCardSlot ville have været nyttig til typetjek.
Men samtidig så jeg FaceCardSlot som værende en mere vigtigt klasse, til at indføre et (number_card: PlayedNumericCardSlot) felt.
