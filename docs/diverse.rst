

Scener i Godot (GDScript) kan ikke tilknyttes en constructor.
I stedet er meningen at man går den gammeldags "C" vej,
og laver sin egen constructor funktion,
som man skal huske at kalde i stedet.
Det mystiske er at man alligevel godt kan lave klasser men parameteriserede constructore,
men hvis sådanne klasser indgår som (under)noder i en scene, bliver constructoren ikke kaldt.
