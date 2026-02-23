CREATE Table Usinas (id_usina INTEGER PRIMARY KEY AUTOINCREMENT,
                     nome_usina VARCHAR (50),
                     potencia_kwp DECIMAL (10,2),
                     cidade VARCHAR (50),
                     estado VARCHAR (2));
					
CREATE TABLE Inversores (id_inversor INTEGER PRIMARY KEY AUTOINCREMENT,
                         usina_id INTEGER,
                         num_serial VARCHAR(50) Unique,
                         modelo VARCHAR (50),
                         potencia_nominal_kw DECIMAL (10,2),
                         foreign key (usina_id) references Usinas (id_usina));
                         
CREATE TABLE Geracao (id_registro INTEGER PRIMARY KEY AUTOINCREMENT,
                      num_serial_inversor VARCHAR (50),
                      data_geracao DATE,
                      energia_kwh DECIMAL (10,2),
                      FOREIGN KEY (num_serial_inversor) references Inversores (num_serial));
