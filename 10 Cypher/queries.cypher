// All colleague relationships
MATCH (v)-[e:COLLEAGUE]-(w) RETURN *

// Family relationships
MATCH (v)-[e:SPOUSE|CHILD|SIBLING]-(w) RETURN *

// Margaret's relationships
MATCH (v {name:"Margaret"})-[e]-(w) RETURN *

// Margaret's friend network
MATCH (v {name:"Margaret"})-[e:FRIEND*]->(w) RETURN * // Slow. All paths from Margaret.

MATCH p = shortestPath((v {name:"Margaret"})-[:FRIEND*]->(w))
WHERE w <> v 
RETURN v, w, relationships(p) AS e
// Right

// Create a new node if constraints allow (always creates).
CREATE (v: Person { id: 100, name: "Hannibal"})

// Create a new node if the data doesn't already exists.
MERGE (v: Person { id: 100, name: "Hannibal"})

// Unmarried persons
MATCH (v)
WHERE NOT EXISTS ((v)-[:SPOUSE]-())
RETURN v

// Married persons and their spouses
MATCH (v)-[s:SPOUSE]-(w)
RETURN *

// All persons, also showing spousal relationships
MATCH (v)
OPTIONAL MATCH (v)-[s:SPOUSE]-(w)
RETURN *

// Number of parents
MATCH (p)-[:CHILD]->(c)
RETURN c, COUNT(p)

// Number of parents for children with more than 2 parents
MATCH (p)-[:CHILD]->(c)
WITH c, COUNT(p) as noOfParents
WHERE noOfParents > 2
RETURN c, noOfParents

// Parents for children with more than 2 parents
MATCH (p)-[:CHILD]->(c)
WITH c, COLLECT(p.name) as parents
WHERE size(parents) > 2
RETURN c, parents

// Change Hannibal's name
MATCH (h {id: 100})
SET h.name = "Han"
RETURN h

// Divorce Ashley and Donald (note the undirected relationship)
MATCH ({name:"Ashley"})-[s:SPOUSE]-({name:"Donald"})
DELETE s

