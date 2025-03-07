import { MongoClient, ObjectId } from 'mongodb';

const connectionString = 'mongodb://127.0.0.1:27017/?directConnection=true&serverSelectionTimeoutMS=2000'

let client = undefined

function mongoClient() {
    if (!client) {
        client = new MongoClient(connectionString)
        client.connect()
    }
    return client
}

async function runSession(callback) {
    const client = mongoClient();
    const session = client.startSession()
    try {
        const db = client.db('test')
        return await callback(db, session)
    } catch (e) {
        console.log(e.stack)
        throw e
    } finally {
        session.endSession()
    }
}

export async function blog() {
    return runSession(db => db.collection('blogs').find().toArray())
}

async function commentsForBlog(blogs, _id) {
    return blogs
      .aggregate([
        {$match: {_id}},
        {$unwind: "$comments"},
        {$replaceWith: "$comments"}
      ])
      .toArray()
}

export async function blogComment(parent) {
    return runSession(db => commentsForBlog(db.collection("blogs"), parent._id))
}

export async function comment(_, args) {
    return runSession(db => commentsForBlog(db.collection("blogs"), new ObjectId(args.blog_id)))
}

export async function createBlog(_, args) {
    return runSession(async (db, session) => {
        try {
            await session.startTransaction()
            const blogs = db.collection('blogs')
            const { text, username, tags } = args.blog
            const words = text.split(' ')
            const numberOfWords = words.length
            const user = await blogs.findOne({"user.username": username}).user ?? {username, numberOfComments: 0}
            const post = { text,  numberOfWords,  user, tags, numberOfComments: 0, comments: [] }
            const id = await blogs.insertOne(post).insertedId
            await session.commitTransaction()
            return { _id: id, ...post }
        } catch(e) {
            await session.abortTransaction()
            throw e
        }
    })
}

export async function addComment(_, args) {
    return runSession(async (db, session) => {
        try {
            await session.startTransaction()
            const blogs = db.collection('blogs')
            const {blogId, comment: { text, user }} = args
            const comment = {text, user, likes: []}
            await blogs.updateOne({_id: new ObjectId(blogId)}, {$push: {comments: comment}})
            await blogs.updateMany({"user.username": user}, {$inc: {"user.numberOfComments": 1}})
            await session.commitTransaction()
            return comment
        } catch(e) {
            await session.abortTransaction()
            throw e
        }
    })
}
