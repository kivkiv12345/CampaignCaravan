Godot-SQLite er et lille GDExtension (skrevet i C++) bibliotek,
som udvider Godot med et API mellem GDScript og SQLite.

For at oprette og eller forbinde til en database, behøver brugeren blot at specificere databasens sti (her: "res://data_v1.db"),
og derefter kalde SQLite.open_db(). Den specificerede database oprettes, hvis ikke findes på dette tidspunkt.

.. code-block:: GDScript

    self._db = SQLite.new()

    # NOTE: Update the version number in the database name when changing the structure of tables.
    #	That way players can still go back to old versions of the game and keep their data.
    self._db.path = "res://data_v1.db"

    self._db.foreign_keys = true  # Must be set for godot-SQLite to handle foreign keys
    self._db.open_db()  # .db file will be created here, if it doesn't exist.


Databasetabeller kan let operettes ved brug af metoden "**bool SQLite.create_table(table_name: String, table_data: Dictionary)**".
Parameteret **table_data** er et dictionary, som sammensætter kolonnenavne med deres tilsvarende struktur.
I kodeeksemplet nedenunder, ses det at kolenenstrukturen også angives som et dictionary,
som sammensætter strengnavne på kolonneattributter med deres tilsvarende værdi, f.eks {"primary_key": true}

Kodeeksemplet nedenunder viser også funktionen "**bool SQLite.query_with_bindings(query_string: String, param_bindings: Array)**".
Denne funktionen sikrer imod SQL "injection" angreb. Af denne grund kræver funktionen, at SQL forespørgselsstrengen adskilles fra argumenter dertil.
forespørgselsargumenter angives i stedet med spørgsmåltegn i strengen, herefter udfyldes de fra indholdet i arrayet som også medgives til funktionen.

.. code-block:: GDScript

    var tables: Dictionary = {
        ...
        "Decks": {
            "id": {"data_type":"int", "primary_key": true, "not_null": true, "auto_increment": true},
            "name": {"data_type":"text", "not_null": true, "unique": true},
        },
        ...
    }
    
    for table_name in tables:
        
        var table_data: Dictionary = tables[table_name]

        # Check if the table already exists or not.
        self._db.query_with_bindings("SELECT name FROM sqlite_master WHERE type='table' AND name=?;", [table_name])
        if self._db.query_result.is_empty():
            # Table doesn't exist, let's create it.
            self._db.create_table(table_name, table_data)


Der findes et par biblioteker som giver et inteface mellem SQLite og GDScript,
men efter min undersøgelse er **Godot-SQLite** det mest vedligeholdte.