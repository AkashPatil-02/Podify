import path from "path";
import { v4 as uuidv4 } from "uuid";
import dotenv from "dotenv";
dotenv.config();
import { createClient } from '@deepgram/sdk';
import fs from 'fs';
import { pipeline } from 'stream/promises';

const key = process.env.deepgramApiKey;

export const generateSpeech = async (text,model) => {
  const outputFile = `podcast_${uuidv4()}.mp3`;
  const filePath = path.join("audio", outputFile);
  const deepgram = createClient(key);

  const response = await deepgram.speak.request(
    { text },
    {
      model: 'aura-2-'+model+'-en',
    }
  );

  const stream = await response.getStream();
  if (stream) {
    const file = fs.createWriteStream(filePath); 
    try {
      await pipeline(stream, file);
      console.log(`Audio file written to ${filePath}`);
      return filePath;
    } catch (e) {
      console.error('Error writing audio to file:', e);
      throw e;
    }
  } else {
    throw new Error('Error generating audio: No stream returned');
  }
};
