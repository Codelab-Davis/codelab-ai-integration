import express, { Express, Request, Response } from "express";
import dotenv from "dotenv";
import bodyParser from "body-parser";
// Imports the Google Cloud client library
import * as language from "@google-cloud/language";

dotenv.config();

const app: Express = express();
const port = process.env.PORT || 5001; // default port is 5001

app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());

// Instantiates a client
const client = new language.LanguageServiceClient();

async function analyzeSentiment(text: string) {
    
  
    const document: {content: string, type: any} = {
      content: text,
      type: 'PLAIN_TEXT',
    };
  
    // Detects the sentiment of the text
    const [result] = await client.analyzeSentiment({document: document});
    // const [result2] = await client.analyzeSyntax({document: document});
    //console.log(result2);
    const sentiment = result.documentSentiment;

    return {text: text, sent_score: sentiment?.score, sent_mag: sentiment?.magnitude};
}

app.get("/", async (_req: Request, res: Response) => {
    res.send("Express + TypeScript Server");
});

app.post("/analyzeSentiment", async (req: Request, res: Response) => {
    try{
        const text: string = req?.body?.text || "";
        //console.log(text);
        const sentiment_analysis = await analyzeSentiment(text);
        return res.status(200).json(sentiment_analysis);
    } catch(err) {
        return res.status(500).json({error: err});
    }
});

app.listen(port, () => {
    console.log(`⚡[server]: Server is running at http://localhost:${port}`);
});
