CREATE (concert: Type {name: "Concert" }),
       (lecture: Type {name: "Lecture" }),
	   
       (classical: Genre {name: "Classical" }),
	   
	   (assn: Performer {name: "Anne Sofie Sloth Nilausen"}),
	   (ms: Performer {name: "Morten Spielhauger"}),
	   
	   (lilleSal: Room {name: "Lille sal"}),
	   
       (assnEvent: Event { time: datetime({year: 2020, month: 3, day: 3, hour: 19, minute: 30})}),
	   (assn) -[:PERFORMS {role: "Pianist"}]->(assnEvent),
	   (assnEvent) -[:GENRE]->(classical),
	   (assnEvent) -[:TYPE]->(concert),
	   (assnEvent) -[:VENUE]->(lilleSal),

       (msEvent: Event { time: datetime({year: 2020, month: 3, day: 4, hour: 19, minute: 0})}),
	   (ms) -[:PERFORMS {role: "Speaker"}]->(msEvent),
	   (msEvent) -[:TYPE]->(lecture),
	   (msEvent) -[:VENUE]->(lilleSal),
	   
	   (seat1118: Seat{row: 11, number: 18}),
	   (seat1118) -[:IN_ROOM]->(lilleSal),
	   (seat0108: Seat{row: 3, number: 8}),
	   (seat0108) -[:IN_ROOM]->(lilleSal),
	   (seat0618: Seat{row: 6, number: 18}),
	   (seat0618) -[:IN_ROOM]->(lilleSal),
	   
       (ticket1: Ticket {price: 55}),
	   (ticket1)-[:FOR]->(assnEvent),
       (ticket2: Ticket {price: 55}),
	   (ticket2)-[:FOR]->(assnEvent),
       (ticket3: Ticket {price: 150}),
	   (ticket3)-[:SEAT]->(seat1118),
	   (ticket3)-[:FOR]->(msEvent),
       (ticket4: Ticket {price: 230}),
	   (ticket4)-[:SEAT]->(seat0108),
	   (ticket4)-[:FOR]->(msEvent),
       (ticket5: Ticket {price: 190}),
	   (ticket5)-[:SEAT]->(seat0618),
	   (ticket5)-[:FOR]->(msEvent),
	   
	   (aarhus: City {name: "Aarhus C", zip: 8000}),
	   (horsens: City {name: "Horsens", zip: 8700}),
	   
	   (frederiksgade: Address {street: "Frederiksgade", number: 44}),
	   (frederiksgade)-[:CITY]->(aarhus),
       (kaylee: User {name: "Kaylee Roderick"}),
	   (kaylee)-[:LIVES]->(frederiksgade),
	   (kaylee)-[:BOUGHT]->(ticket1),
	   
	   (kattesund: Address {street: "Kattesund", number: 12}),
	   (kattesund)-[:CITY]->(horsens),
       (trevor: User {name: "Trevor Jeffrey"}),
	   (trevor)-[:LIVES]->(kattesund),
	   (trevor)-[:BOUGHT]->(ticket2),
	   
	   (lovenorn: Address {street: "Løvenørnsgade", number: 18}),
	   (lovenorn)-[:CITY]->(horsens),
       (edna: User {name: "Edna Durant"}),
	   (edna)-[:LIVES]->(lovenorn),
	   (edna)-[:BOUGHT]->(ticket3),

       (damian: User {name: "Damian Beringer"}),
	   (damian)-[:LIVES]->(lovenorn),
	   (damian)-[:BOUGHT]->(ticket4),

	   (gronne: Address {street: "Grønnegade", number: 10, zip: 8000, city: "Aarhus C"}),
       (starr: User {name: "Starr Sergeant"}),
	   (starr)-[:LIVES]->(gronne),
	   (starr)-[:BOUGHT]->(ticket5)
