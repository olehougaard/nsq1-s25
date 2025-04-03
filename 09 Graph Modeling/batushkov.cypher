MATCH (n) DETACH DELETE n;
LOAD CSV WITH HEADERS FROM 'https://vbatushkov.bitbucket.io/log_of_calls.csv' AS line
MERGE (c1:City { name: line.from_city })
MERGE (p1:Person { name: line.from_name, number: line.from_number, gender: line.from_gender })
MERGE (p1)-[:FROM]->(c1)
MERGE (c2:City { name: line.to_city })
MERGE (p2:Person { name: line.to_name, number: line.to_number, gender: line.to_gender })
MERGE (p2)-[:FROM]->(c2)
CREATE (c:Call { from: datetime(line.from_dt),
		 to: datetime(line.to_dt),
                 duration: duration.between(datetime(line.from_dt), datetime(line.to_dt)).minutes })
CREATE (p1)-[:OUT]->(c)<-[:IN]-(p2);

// 1
// Any May:
MATCH (c:Call{duration: 0}) 
WHERE c.from.month = 5 
RETURN COUNT(c) AS missed

// May 2019 specifically:
MATCH (c:Call{duration: 0}) 
WHERE datetime.truncate('month', c.from) = datetime({year: 2019, month: 5}) 
RETURN COUNT(c) AS missed

// 2
MATCH (:Person{name:"Tiffany"})-[:OUT]->(c:Call)<-[:IN]-(m:Person{gender:"Man"}) 
WHERE c.from.month = 5 
RETURN DISTINCT m

// 3
MATCH (city:City)<-[:FROM]-(:Person)-[:OUT]->(c:Call)<-[:IN]-(:Person)-[:FROM]->(city) 
RETURN city, COUNT(c) as internalCalls 
ORDER BY internalCalls ASC
LIMIT 1

// 4
MATCH (:City{name:"Bangkok"})<-[:FROM]-(:Person{gender:"Man"})-[:OUT]->(c:Call)<-[:IN]-(w:Person{gender:"Woman"})-[:FROM]->(:City{name: "Pattaya"}) 
RETURN COUNT(DISTINCT w)

// 5
// If women who had no calls count
MATCH (x:Person{gender:"Woman"})-[:IN|OUT]->(call:Call)
WHERE datetime.truncate('day', call.from) = datetime({year: 2019, month: 4, day: 25})
RETURN x, SUM(call.duration) AS duration
ORDER BY duration
LIMIT 1

// If only women who had calls count
MATCH (call: Call)
WHERE datetime.truncate('day', call.from) = datetime({year: 2019, month: 4, day: 25})
MATCH (x:Person{gender:"Woman"})-[:IN|OUT]->(call)
RETURN x, SUM(call.duration) AS duration
ORDER BY duration
LIMIT 1

// If only women who had no missed calls count
MATCH (call: Call)
WHERE datetime.truncate('day', call.from) = datetime({year: 2019, month: 4, day: 25})
  AND call.duration > 0
MATCH (x:Person{gender:"Woman"})-[:IN|OUT]->(call)
RETURN x, SUM(call.duration) AS duration
ORDER BY duration
LIMIT 1

// 6
MATCH (x:Person)-[:OUT]->(:Call)<-[:IN]-(y:Person)
MATCH (y)-[:OUT]->(:Call)<-[:IN]-(x)
WHERE x.number < y.number
RETURN COUNT(DISTINCT [x, y]) AS callers
