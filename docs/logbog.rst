
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

