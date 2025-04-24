import { ApolloServer } from '@apollo/server'
import { startStandaloneServer } from '@apollo/server/standalone'
import { Neo4jGraphQL } from "@neo4j/graphql"
import neo4j from "neo4j-driver"
import {promises as fs} from "fs"

async function startServer(driver) {
    try {
        await driver.verifyConnectivity()
        console.log('Verified')
        const content = await fs.readFile('./friends.sdl', 'utf8')
        const typeDefs = `#graphql
          ${content}`
        const graphQL = new Neo4jGraphQL({typeDefs, driver})
        const schema = await graphQL.getSchema()
        const server = new ApolloServer({schema})
        //startStandaloneServer starts a server with good defaults for test/development
        const {url} = await startStandaloneServer(server, {listen: { port: 4000}})
        console.log(`GraphQL server ready on ${url}`)
    } catch (err) {
        console.error(`Error: ${err}`)
    }
}

const driver = neo4j.driver(
    "bolt://127.0.0.1:7687",
    neo4j.auth.basic("neo4j", "password"), 
    {encrypted: "ENCRYPTION_OFF"}
)

startServer(driver)
