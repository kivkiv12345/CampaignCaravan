
**2/9-2024 (Mandag Uge #1)**

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


**3/9-2024 (Tirsdag Uge #1)**

    Jeg startede dagen med at kigge på drag-and-drop funktionalitet i Godot.
    Min tanke er at kernefunkionaliten hurtigt kan udarbejdes,
    så jeg kan vinde tid til at få spillet til både at se og føles godt.
    I løbet af dagen bør jeg også kigge på kravspecifikationen,
    da jeg endnu ikke har fastlåst mig afgrænsningen af funktionaliterne til spillet.
    Jeg har ikke bestemt hvor vidt jeg vil fokusere på multiplayer vs AI (machine learning er ikke planlagt) modstandere.


**4/9-2024 (Onsdag Uge #1)**

    Fokus i dag var funktionaliterne bag at trække kort fra sit dæk til sin hånd.
    Dækket's constructor metode er lige nu mest ment til test,
    hvor det genererer et tilfældigt dæk fra en given størrelse og seed.
    Jeg ser seeding som vigtigt størstedelen af steder hvor tilfældighed indgår,
    især til senere hvor disse funktioner også skal kunne testes.


**5/9-2024 (Torsdag Uge #1)**

    Jeg vil starte dagen med at oprette signaler til når kort spilles.
    I første omgang skal de bruges til at trække nye kort fra spillerens dæk,
    da CardDropSlot noden ligger fjernt fra dæk noden, hvilket gør det svært for dem at snakke direkte.
    Samtidig kunne signalet også bruges til at oprette et nyt CardDropSlot nederst i karavanen.
    Men dette kunne formentlig også gøres enten som en linked list af CardDropSlots.
    Da hvert NumericCardDropSlot altid ligger nederst i karavanen,
    vil nye NumericCardDropSlots altid skulle oprettes under dette.
    FaceCardSlots er lignende, hvor nye slots skal oprettes til højre i stedet.


**6/9-2024 (Fredag Uge #1)**

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


**7/9-2024 - 8/9-2024 (Weekend Uge #1)**

    Weekend logbogen koster ekstra, men den kan tilgås gratis på:
    https://github.com/kivkiv12345/CampaignCaravan/commits/master/


**9/9-2024 (Mandag Uge #2)**

    I dag var planen at endelig færdiggøre tidsplanen, men først skulle kravspecifikationen færddiggøres.
    Mange af de manglende punkter dertil var åbenlåse, men alligevel havde jeg svært ved at nå de 12-15 krav jeg gerne ville op på.
    Efter at have skrevet, og tænkt, mig til en håndfuld punkter, besluttede jeg mig at overveje de sidste over et par linje kode (koden skulle nemlig også plejes).
    Vedrørende koden lå mit fokus helt naturligt på Quality of Life of bugfixes. Derfor fik jeg denne dag implementeret en grafisk præsentation af solgte karavane.
    Denne tilføjelse gav hjemmel til refleksioner Vedrørende Caravan klassen. Caravan klassen er nemlig kun meget løst koblet til det større spilstadie,
    men hvor vidt den er solgt afhænger meget af værdien på den overstående modstanderkaravane.


**10/9-2024 (Tirsdag Uge #2)**

    Det er efterhånden flere dage jeg har frustreret mig over hvor bøvligt det kunne være at spille ansigtskort på store karavaner.
    Det skyldes den store mænge tætliggende nummerkort, som gjorde det svært at se hvor man faktisk var ved at lægge sit kort.
    Situationen var heller ikke afhjulpet af det faktum at de var svært at se den grønne markering på de åbne felter.

    Gud ske lov kom løsningen som en åbenbaring i går aftes.
    Jeg skal bare vise en forhåndsvisning (forgrønnet endda) af det løftede kort,
    i det åbne felt, når man holder musen derover.
    Dette giver også en følelse af at kortet er magnetisk tiltrukket de åbne felter.
    Og specialt med ansigtskort klargører det hvor kortet vil komme til at ligge.

    Desværre fremmer denne fantastiske funktionalitet ikke tidsplanen,
    hvilket jeg i stedet gjorde ved faktisk at lave tidsplanen.

    Derudover tror jeg også jeg er ved at blive syg. Jeg føler mig dog heldigvis ikke dårlig (endnu?).
    Men min næse har gennemgået størstedelen af en køkkenrulle, og dette faktum brister mine skraldespande.


**11/9-2024 (Onsdag Uge #2)**

    Fokus i dag har eksklusivt været på procesrapporten.
    Generelt er jeg ret langsom til at skrive rapporter, og i dag har ikke været en undtagelse.
    Alligevel er jeg ret tilfreds med fremskridtet i dag.
    Indtil videre har jeg gjort mig massere af tanker under udviklingen af spillet.
    Desværre føler jeg at disse tanker er flygtige, hvor jeg enten kan nå at implementere dem i spillet,
    eller dokumentere dem i rapporterne.
    Her lyder svaret nok åbenlyst (til dig min kære læser),
    men selv har jeg svært ved at vælge hvad der skal komme først.
    Jeg kan skrive koden først, og senere komme tilbage udvride tankerne bag den i procesrapporten.
    Men denne process indebærer en vis tab af præcesion og detaljer.
    Ligevidt kan procesrapporten skrives med førsteprioritet,
    men det er meget svært for mig at, både præcist og fuldendt, dokumentere mine tanker.
    Derfor er det heller ikke ideelt at skrive koden på bagkant af dokumentationen
    (især fordi den da beskrevede implementation kan være inkompatibel med virkeligheden).

    Ureleteret er jeg heller ikke snottet længere.
    Næsen skulle lige pustes igennem i morges, men efter det har den ikke været noget problem.


**12/9-2024 (Torsdag Uge #2)**

    I dag har fortsat handlet om procesrapporten,
    men derudover har jeg også eksperimenteret lidt med mine hostingmuligheder herhjemme.
    Jeg har en Raspberry PI 4, som jeg nu har koblet op i mit teknikrum.
    For én gangs skyld fungerede port-forwarding også bare uden problemer,
    selv endda uden statisk IP adresse.
    Uanset hvad er planen at jeg skal have skaffet mig et domæne,
    men muligvis at DynDNS ville kunne erstatte en statisk IP adresse derefter.

    I løbet af dagen har jeg haft stor success med brugen af GitHub Pages til hosting af spillet.


**13/9-2024 (Fredag Uge #2)**

    I går fik jeg skrevet det meste af hvad jeg kunne, inden jeg fortsætter på koden.
    Så i dag er fokus på få indført en menu i spillet.

    For ikke at gentage skaléringsfejlene med resten af spillet,
    har jeg valgt at tage udgangspunkt i et turtorial til menuen:
    https://www.youtube.com/watch?v=vsKxB66_ngw
    https://www.youtube.com/watch?v=8boLA6Hdvn8

    Det er mit håb at dette kan sikre at menuen laves med de rigtige ankre,
    og andre endnu ukendte gode skikker i Godot.

    Derudover er jeg også begyndt at planlægge persistent lagring af spilledæk.
    Denne Godot udvidelse (https://github.com/2shady4u/godot-sqlite)
    skulle kunne tillade mig at bruge en SQLite database til spillet (endda også HTML5 eksporterede versioner).

    Eftermiddagen bruge jeg på at stjæ- låne lydeffekter, fonts og farvetema fra selveste Fallout New Vegas,
    indtil videre giver det en rigtig fed effect på hovedmenuen.
    Dog mangler jeg stadig af integrere dem med resten af spillet.

    Aftenen gik på at indføre nogle "tween" animationer,
    Godot 4.0+ har gjort dem rigtigt nemme.
    Så de ser allerede rigtigt gode ud med de numeriske kort,
    men det bliver alligevel lidt udfordrene med knægte og jokere.
    Men det er et problem til i morgen.


**16/9-2024 (Mandag Uge #3)**

    Fokus i dag har været at implementere menuen hvor spilleindstillingerne kan tilpasses,
    da jeg ser den som en forudsætning for menuen hvor kortdækket kan tilpasses, og dermed databasen.


**17/9-2024 (Tirsdag Uge #3)**

    Planen var at i dag skulle bruges på at oprette projektets database.
    Dog aftenen her har involveret undersøgelse hertil.
    Men støstedelen af dagen er gået på en række forbedringer,
    som egentlig ikke stod direkte skrevet i kravspecifikation,
    men som jeg alligevel ser som væsentlige for at spillet skal være præsentabelt.
    Primært understået:
    - Fikset GitHub CI Action
    - Mini tutorial på main menu, i form at 2 bots som spiller mod hinanden
    - Flere indstillinger til tilpassede spilleregler


**18/9-2024 (Onsdag Uge #3)**

    Fokus i dag har fortsat været forberedelse på databasen,
    hermed har jeg oprettet brugerfladen til at redigere kortdæk.
    Dog nåede jeg at bruge aftenen på at tjekke at SQLite udvidelsen af Godot faktisk fungerer,
    og at jeg derfor kan undgå at skulle oprette et WebAPI.


**19/9-2024 (Torsdag Uge #3)**

    Hensigten var at dagen skulle deles mellem at udrulle HTML5 versionen af spillet med godot-sqlite,
    og derefter fokusere på rapportskrivning.
    Desværre viste det sig at godot-sqlite er inkompatibel med Godot 4.3's HTML5 exports.
    Derefter backportede jeg også spillet til Godot 4.2.1,
    hvor godot-sqlite+HTML5 havde større sandsynlighed for at virke.
    Men desværre (igen) viste denne version sig for at være for ustabil,
    så det lykkedes mig ikke at få det til at virke.

    Herefter sluttede jeg dagen med at lave en version af spillet uden tilpasselige kortdæk,
    og dermed SQL databasen. Denne udgave bruges derfor til HTML5 udgaven af spillet.


**20/9-2024 (Fredag Uge #3)**

    I dag har haft fuld fokus på rapporterne,
    hvor størstedelen af det skriftelige materiale har omhandlet min nydelige erfaring med WASM SQLite databasen.


**23/9-2024 (Mandag Uge #4)**

    Mere rapportskrivning, primært brugervejledning i produktrapporten.


**24/9-2024 (Tirsdag Uge #4)**

    Mere rapportskrivning, UML diagram over CardSlot arvehierarkiet.
    Jeg er ved at være ret træt af at skrive rapporter.
    Så det er begrænset hvor meget arbejde der bliver lagt i de sidste mangler.

**25/9-2024 (Onsdag Uge #4)**

    Mere rapportskrivning: Titelblad, uddybet konklusion.
