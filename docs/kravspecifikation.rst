
Krav kategorier
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Tabellen herunder fortæller hvilke kategorier de forskellige krav kan tilhøre, og dermed også hvilken funktion de tjener projektet.

.. list-table::
   :widths: 15 25 50 
   :header-rows: 1

   * - Kategori ID
     - Navn
     - Beskrivelse

   * - KN1
     - Acceptkrav
     - Funktionaliteter som ikke kan undværes, da de er kritiske for projektets helhed


   * - KN3
     - Spilmodstandere
     - Forskellige typer af modstandere i spillet, hvoraf mindst én anses som en nødvendig før spillet kan fungere.


   * - KN4
     - Brugervenlighed
     - Funktionaliteter rettet mod slutbrugere som gør det nemmere for dem at anvende software-pakken


   * - KN5
     - Udvidet funktionalitet
     - Funktionaliteter som er mindre vigtige for projektets helhed. Dermed kan de også nedprioriteres og undværes under tidspres.


.. TODO Kevin: Not used if we're not including out skipped demands
   * - KN6
     - Telemetri/Logning
     - Mulighed for at tilgå historisk data for handlinger og statistikker



Kravspecifikation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. list-table::
   :widths: 20 35 50 15 15
   :header-rows: 1

   * - Krav ID - Kategori ID - Prioritet
     - Beskrivelse
     - Test kondition(er)
     - Opfyldt
     - Ikke Opfyldt

   * - **K1** - KN1 - 1
     - Produktet/spillet respekterer de basale spilleregler for numeriske spillekort i Caravan
     - Det pågældende API(er) testes ved sammensætning af 2 CPU modstandere i en væsentlig forøget hastighed
       (tidsrum mellem hver tur på 0.02-0.04 sekunder).
       Testens spilinstans er tilpasset til automatisk at genstarte spillet.
       Herefter lades denne test køre i minimum 10 minutter.
       Efter testen noteres det hvor vidt modstanderne har gjort brug af API(erne).
       Brugerfladen gør brug af samme API,
       derfor er manuelle test kun nødvendige for at bekræfte at grafiske elementer opfører sig korrekt.
     - **X**
     -  

   * - **K2** - KN1 - 1
     - Produktet/spillet respekterer de basale spilleregler for ansigtskort i Caravan
     - Det pågældende API(er) testes ved sammensætning af 2 CPU modstandere i en væsentlig forøget hastighed
       (tidsrum mellem hver tur på 0.02-0.04 sekunder).
       Testens spilinstans er tilpasset til automatisk at genstarte spillet.
       Herefter lades denne test køre i minimum 10 minutter.
       Efter testen noteres det hvor vidt modstanderne har gjort brug af API(erne).
       Brugerfladen gør brug af samme API,
       derfor er manuelle test kun nødvendige for at bekræfte at grafiske elementer opfører sig korrekt.
     - **X**
     -  

   * - **K3** - KN1 - 1
     - Produktet/spillet respekterer spilleregler vedr. afskaffelse af kort
     - Det pågældende API(er) testes ved sammensætning af 2 CPU modstandere i en væsentlig forøget hastighed
       (tidsrum mellem hver tur på 0.02-0.04 sekunder).
       Testens spilinstans er tilpasset til automatisk at genstarte spillet.
       Herefter lades denne test køre i minimum 10 minutter.
       Efter testen noteres det hvor vidt modstanderne har gjort brug af API(erne).
       Brugerfladen gør brug af samme API,
       derfor er manuelle test kun nødvendige for at bekræfte at grafiske elementer opfører sig korrekt.
     - **X**
     - 

   * - **K4** - KN1 - 2
     - Produktet/spillet respekterer spilleregler vedr. afskaffelse af karavaner
     - Det pågældende API(er) testes ved sammensætning af 2 CPU modstandere i en væsentlig forøget hastighed
       (tidsrum mellem hver tur på 0.02-0.04 sekunder).
       Testens spilinstans er tilpasset til automatisk at genstarte spillet.
       Herefter lades denne test køre i minimum 10 minutter.
       Efter testen noteres det hvor vidt modstanderne har gjort brug af API(erne).
       Brugerfladen gør brug af samme API,
       derfor er manuelle test kun nødvendige for at bekræfte at grafiske elementer opfører sig korrekt.
     - **X**
     -  

   * - **K5** - KN1 - 1
     - Produktet/spillet respekterer når spillere vinder/taber
     - Det pågældende API(er) testes ved sammensætning af 2 CPU modstandere i en væsentlig forøget hastighed
       (tidsrum mellem hver tur på 0.02-0.04 sekunder).
       Testens spilinstans er tilpasset til automatisk at genstarte spillet.
       Herefter lades denne test køre i minimum 10 minutter.
       Efter testen noteres det hvor vidt modstanderne har gjort brug af API(erne).
       Brugerfladen gør brug af samme API,
       derfor er manuelle test kun nødvendige for at bekræfte at grafiske elementer opfører sig korrekt.
     - **X**
     -  

   * - **K6** - KN3 - 2
     - Multiplayer; Mulighed for at spille imod andre menneskelige modstandere (Mindst én form for modstander skal inkluderes, før produktet/spillet kan fungere)
     - 2 menneskelige kan, via en menu, starte synkroniséring af deres spil. Herefter vil de spiller A's træk være synlige for spiller B, og ligeledes omvendt.
       Når én spiller vinder, vil denne spiller se at de har vundet, hvorimod den modsatte spiller vil se at de har tabt.
     -  
     - **X**

   * - **K7** - KN3 - 2
     - Bot/CPU modstander; Mulighed for at spille imod en prædefineret algoritme el. (Mindst én form for modstander skal inkluderes, før produktet/spillet kan fungere)
     - Spilleren kan, via en menu, starte et spil hvor modstanderen automatisk udfører spilletræk modsvarende til spillerens.
       Disse træk viser at CPU spilleren kan spille både defensivt og offensivt i forsøget om at fremme sine egne interesser.
     - **X**
     -  

   * - **K8** - KN4 - 3
     - Spillet indeholder en guide/instruktioner som forklarer reglerne
     - Spilleren kan, via en menu, få vist en forklaring af Karavanes' spilleregler.
     - **X**
     -  

   * - **K9** - KN1 - 3
     - Mulighed for at tilpasse kortdæk
     - Spilleren kan, via en menu, tilpasse deres kortdæk med forskellige kombinationer og antal af de 54 forskellige spillekort.
       Herefter kan spilleren medbringe dette spillekortdæk til det reelle spil.
     - **X**
     -  

   * - **K10** - KN5 - 3
     - Produktet/spillet understøtter udvalgte tilpasninger af spilleregler
     - Spilleren kan, via en menu, ændre det oftest diskuterede/misforståede spilleregler ved karavane.
       Disse tilpassede kan medbringes til det reelle spil.
     - **X**
     -  

   * - **K11** - KN4 - 4
     - Produktet kan lagre tilpassede spilledæk og eller spilleregler
     - De(t) tilpassede kortdæk fra K9, og eller spilleregler fra K10, kan, via en menu, navngives og gemmes på en måde som tillader at de indlæses efter en genstart af spillet.
     - **X**
     -  

   * - **K14** - KN4 - 3
     - Spillet distribueres på en let tilgængelig måde
     - Spilleren kan tilgå spillet på en måde som ikke kræver større software-teknisk viden (link, download, osv).
     - **X**
     -  



.. TODO Kevin: Do we want to include the demands we decided against? assert(none_of_these_are_relevant_for_case_or_problemformulering)
   * - **K12** - KN6 - 5
     - Produktet/spillet kan logge træk i spillet, til database og eller blot i spillet.
     - Spillet kan logge træknummer og trækhandling, som effektivt set ville kunne tillade en genafspilning af spil.
     - 
     - **x**

   * - **K13** - KN3 - 6
     - AI modstander (med ML). Sandsynligvis vha. integration med generativ AI model. (Mindst én form for modstander skal inkluderes, før produktet/spillet kan fungere). Denne modstandertype er nedprioriteret grundet kompleksitet.
     - 6
     - 
     - **x**


  
