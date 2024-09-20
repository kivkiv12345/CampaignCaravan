
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
     - Kernefunktionalitet
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
   :widths: 20 50 50 15 10 15
   :header-rows: 1

   * - Krav ID - Kategori ID - Prioritet
     - Beskrivelse
     - Test kondition(er)
     - PASS
     - <->
     - FAIL

   * - **K1** - KN1 - 1
     - Produktet/spillet respekterer de basale spilleregler for numeriske spillekort i Caravan
     - 1
     - **X**
     -  
     -  

   * - **K2** - KN1 - 1
     - Produktet/spillet respekterer de basale spilleregler for ansigtskort i Caravan
     - 1
     - **X**
     -  
     -  

   * - **K3** - KN1 - 1
     - Produktet/spillet respekterer spilleregler vedr. afskaffelse af kort
     - 1
     - 
     -  
     - **X**

   * - **K4** - KN1 - 2
     - Produktet/spillet respekterer spilleregler vedr. afskaffelse af karavaner
     - 2
     - 
     -  
     - **X** 

   * - **K5** - KN1 - 1
     - Produktet/spillet respekterer når spillere vinder/taber
     - 1
     - **X**
     -  
     -  

   * - **K6** - KN3 - 2
     - Multiplayer; Mulighed for at spille imod andre menneskelige modstandere (Mindst én form for modstander skal inkluderes, før produktet/spillet kan fungere)
     - 2
     - 
     -  
     - **X**

   * - **K7** - KN3 - 2
     - Bot/CPU modstander; Mulighed for at spille imod en prædefineret algoritme el. (Mindst én form for modstander skal inkluderes, før produktet/spillet kan fungere)
     - 2
     - **X**
     -  
     -  

   * - **K8** - KN4 - 3
     - Spillet indeholder en guide/instruktioner som forklarer reglerne
     - 3
     - 
     - **X**
     -  

   * - **K9** - KN1 - 3
     - Mulighed for at tilpasse kortdæk
     - 3
     - **X**
     -  
     -  

   * - **K10** - KN5 - 3
     - Produktet/spillet understøtter udvalgte tilpasninger af spilleregler
     - 3
     - **X**
     -  
     -  

   * - **K11** - KN4 - 4
     - Produktet kan lagre tilpassede spilledæk/spilleregler
     - 4
     - **X**
     -  
     -  

   * - **K14** - KN4 - 3
     - Spillet distribueres på en let tilgængelig måde
     - 3
     - **X**
     -  
     -  



.. TODO Kevin: Do we want to include the demands we decided against? assert(none_of_these_are_relevant_for_case_or_problemformulering)
   * - **K12** - KN6 - 5
     - Produktet/spillet kan logge træk i spillet, til database og eller blot i spillet.
     - 5
     - 
     -  
     - x

   * - **K13** - KN3 - 6
     - AI modstander (med ML). Sandsynligvis vha. integration med generativ AI model. (Mindst én form for modstander skal inkluderes, før produktet/spillet kan fungere). Denne modstandertype er nedprioriteret grundet kompleksitet.
     - 6
     - 
     -  
     - x


  
