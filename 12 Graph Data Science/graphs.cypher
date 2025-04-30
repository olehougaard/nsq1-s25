// On the friend network.
MATCH (v)-[c:COLLEAGUE]-(w) RETURN *;

// CALL gds.graph.drop('colleagues');
// CALL gds.graph.drop('colleaguesUndirected');
CALL gds.graph.project('colleagues', '*', 'COLLEAGUE');
CALL gds.graph.project(
  'colleaguesUndirected', 
  '*', 
  {colleague: {
    type: 'COLLEAGUE', 
    orientation: 'UNDIRECTED'
    }
  }
);

CALL gds.scc.stream('colleagues')
YIELD nodeId, componentId
RETURN gds.util.asNode(nodeId) AS person, componentId
ORDER BY componentId;

CALL gds.wcc.stream('colleagues')
YIELD nodeId, componentId
RETURN gds.util.asNode(nodeId) AS person, componentId
ORDER BY componentId;

CALL gds.wcc.stream('colleagues')
YIELD nodeId, componentId
RETURN collect(gds.util.asNode(nodeId)) AS persons, componentId as companyId
ORDER BY companyId;

// Recording the results
CALL gds.wcc.stream('colleagues')
YIELD nodeId, componentId
WITH collect(gds.util.asNode(nodeId)) AS persons, componentId as companyId
WHERE size(persons) > 1
UNWIND persons AS person
MERGE (c: Company {id: companyId})
MERGE (person)-[:WORKS]->(c);

// Other clustering algorithms - writing to the graph
CALL gds.triangleCount.write('colleaguesUndirected', {writeProperty: 'triangleCount'});
CALL gds.localClusteringCoefficient.write('colleaguesUndirected', {writeProperty: 'localClusteringCoefficient'});

// CALL gds.graph.drop('comments');
CALL gds.graph.project.cypher(
  'comments',
  'MATCH (u:User) RETURN id(u) AS id',
  'MATCH (liker:User)-[:WROTE]->(:Comment)-[:COMMENTS]->(:Post)<-[:WROTE]-(writer:User) RETURN id(liker) AS source, id(writer) AS target'
);

CALL gds.pageRank.stream(
  'comments'
)
YIELD
  nodeId,
  score
RETURN gds.util.asNode(nodeId), score
ORDER BY score DESC;

MATCH (the:User{username: "the"})-[w:WROTE]->(p:Post)
OPTIONAL MATCH (commenter:User)-[wc:WROTE]->(c:Comment)-[cs:COMMENTS]->(p)
RETURN *;

CALL gds.pageRank.write(
  'comments',
  {writeProperty: 'pageRank'}
);

// Friends
CALL gds.graph.drop('full');
CALL gds.graph.drop('weighted');
CALL gds.graph.project('full', '*', '*');
CALL gds.graph.project.cypher(
  'weighted',
  'MATCH (p) RETURN id(p) AS id',
  'MATCH (s)-[r]->(t) ' +
  'RETURN id(s) AS source, ' +
  '       id(t) AS target, ' +
  '       CASE type(r) ' +
              'WHEN "COLLEAGUE" THEN 1 ' +
              'WHEN "ACQUAINTANCE" THEN 2 ' +
              'WHEN "FRIEND" THEN 4 ' +
              'ELSE 8 ' +
          'END AS weight'
);

CALL gds.pageRank.stream(
  'full'
)
YIELD
  nodeId,
  score
RETURN gds.util.asNode(nodeId), score
ORDER BY score DESC;

CALL gds.pageRank.stream(
  'weighted',
  {relationshipWeightProperty: 'weight'}
)
YIELD
  nodeId,
  score
RETURN gds.util.asNode(nodeId), score
ORDER BY score DESC;

CALL gds.alpha.influenceMaximization.celf.stream(
  'full',
  {seedSetSize:4}
)
YIELD
  nodeId,
  spread
RETURN gds.util.asNode(nodeId), spread
ORDER BY spread DESC;
