// neo4j test data
MATCH (v) DETACH DELETE v;
WITH "https://gist.githubusercontent.com/olehougaard/81610b3be1215d1e6ff63525b712f519/raw/d8f57e3a812e461193b3e1c7e4ae997a46d4c224/blogs.json" AS url
CALL apoc.load.json(url) YIELD value
UNWIND value AS blog
CREATE (post:Post{text: blog.text, numberOfWords: blog.numberOfWords}) 
MERGE (user:User {username: blog.user.username}) 
MERGE (user) -[:WROTE]-> (post)
FOREACH (tagName IN blog.tags |
    MERGE (tag:Tag {name:tagName})
    MERGE (post) -[:TAGGED]-> (tag)
)
FOREACH (jsonComment IN blog.comments |
    CREATE (comment: Comment {text: jsonComment.text}) -[:COMMENTS]-> (post)
    MERGE (commenter: User {username: jsonComment.user})
    MERGE (commenter) -[:WROTE]-> (comment)
    FOREACH (like IN jsonComment.likes | 
        MERGE (user: User {username: like}) 
        MERGE (user) -[:LIKES]-> (comment)
    )
);

// Visualising test data
MATCH (that:User{username: "that"})-[w:WROTE]->(p)
OPTIONAL MATCH (u)-[l:LIKES]->(p)
OPTIONAL MATCH (p) -[g:TAGGED]->(t)
RETURN *
