import { ApolloServer } from '@apollo/server'
import { expressMiddleware } from '@apollo/server/express4';
import { ApolloServerPluginDrainHttpServer } from '@apollo/server/plugin/drainHttpServer';
import express from 'express';
import bodyParser from 'body-parser'
import http from 'http';
import {promises as fs} from 'fs'
import * as Resolver from './resolvers.js'

async function startServer() {
    try {
        const content = await fs.readFile('./src/blogs.sdl', 'utf8')
        const typeDefs = `#graphql
          ${content}`
        const resolvers = {
          Query: {
            blogs: Resolver.blog,
            comments: Resolver.comment
          },
          Blog: {
            comments: Resolver.blogComment
          },
          Mutation: {
            createBlog: Resolver.createBlog,
            addComment: Resolver.addComment
          }
        }

        const app = express()
        app.use('/graphql', bodyParser.json())
        app.use('/graphql', (_, res, next) => {
          res.header("Access-Control-Allow-Origin", "*");
          res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
          res.header("Access-Control-Allow-Methods", "GET, POST, PATCH");
          next();
        })
        
        const httpServer = http.createServer(app)

        const server = new ApolloServer({
          typeDefs,
          resolvers,
          plugins: [ApolloServerPluginDrainHttpServer({ httpServer })],
        })
        await server.start()
        app.use('/graphql', expressMiddleware(server))
        app.use('/frontend', express.static('../static'))

        //startStandaloneServer starts a server with good defaults for test/development
        httpServer.listen({ port: 4000 }, () => console.log(`GraphQL server ready on http://localhost:4000/`))
    } catch (err) {
        console.error(`Error: ${err}`)
    }
}

startServer()
