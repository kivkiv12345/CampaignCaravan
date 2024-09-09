
Krav kategorier
----------------------------------

Tabellen herunder fortæller hvilke kategorier de forskellige krav kan tilhøre, og dermed også hvilken funktion de tjener projektet.

.. list-table::
   :widths: 32 68 
   :header-rows: 1

   * - Kategori ID
     - Navn
     - Beskrivelse

   * - KN1
     - Kernefunktionalitet
     - Funktionaliteter som ikke kan undværes, da de er kritiske for projektets helhed


   * - KN3
     - Spilmodstandere
     - Forskellige typer af modstandere i spillet, hvoraf mindst én anses som en nødvendig før spillet kan fungere.


   * - KN4
     - Brugervenlighed
     - Funktionaliteter rettet mod slutbrugere som gør det nemmere for dem at anvende software-pakken


   * - KN5
     - Telemetri/Logning
     - Mulighed for at tilgå historisk data for handlinger og statistikker


   * - KN6
     - Udvidet funktionalitet
     - Funktionaliteter som er mindre vigtige for projektets helhed. Dermed kan de også nedprioriteres og undværes under tidspres.


Kravspecifikation
----------------------------------

.. list-table::
   :widths: 32 68 
   :header-rows: 1

   * - Krav ID
     - Kategori ID
     - Beskrivelse
     - Prioritering

   * - K1
     - KN1
     - Produktet/spillet respekterer de basale spilleregler for numeriske spillekort i Caravan
     - 1

   * - K2
     - KN1
     - Produktet/spillet respekterer de basale spilleregler for ansigtskort i Caravan
     - 1

   * - K3
     - KN1
     - Produktet/spillet genkender når spillere vinder/taber
     - 1

   * - K4
     - KN3
     - Multiplayer; Mulighed for at spille imod andre menneskelige modstandere (Mindst én form for modstander skal inkluderes, før produktet/spillet kan fungere)
     - 2

   * - K5
     - KN3
     - Bot/CPU modstander; Mulighed for at spille imod en prædefineret algoritme el. (Mindst én form for modstander skal inkluderes, før produktet/spillet kan fungere)
     - 2

   * - K6
     - KN1
     - Mulighed for at tilpasse kortdæk (bredt udvalg af implementationsmuligheder)
     - 3

   * - K7
     - KN6
     - Produktet/spillet understøtter udvalgte tilpasninger af spilleregler
     - 3

   * - K8
     - KN4
     - Produktet kan lagre tilpassede spilledæk/spilleregler
     - 4

   * - K9
     - KN
     - 
     - 

   * - K10
     - KN
     - 
     - 

   * - K11
     - KN3
     - AI modstander (med ML). Sandsynligvis vha. integration med generativ AI model. (Mindst én form for modstander skal inkluderes, før produktet/spillet kan fungere). Denne modstandertype er nedprioriteret grundet kompleksitet.
     - 

   * - K12
     - KN
     - 
     - 