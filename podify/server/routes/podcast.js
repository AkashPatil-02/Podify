import dotenv from "dotenv";
dotenv.config();
import express from "express";
import fs from "fs";
import path from "path";
import { extractText } from "../utils/extractText.js";
import { summarizeText } from "../utils/summarize.js";
import { generateSpeech } from "../utils/tts.js";


const router = express.Router();
const AUDIO_DIR = path.resolve("audio");
router.get("/audio/:filename", (req, res) => {
  try {
    const filePath = path.join(AUDIO_DIR, req.params.filename);
    if (!fs.existsSync(filePath)) {
      return res.status(404).send("File not found");
    }

    const stat = fs.statSync(filePath);
    const fileSize = stat.size;
    const range = req.headers.range;

    if (range) {
      const parts = range.replace(/bytes=/, "").split("-");
      const start = parseInt(parts[0], 10);
      const end = parts[1] ? parseInt(parts[1], 10) : fileSize - 1;
      const chunkSize = end - start + 1;
      const file = fs.createReadStream(filePath, { start, end });

      res.writeHead(206, {
        "Content-Range": `bytes ${start}-${end}/${fileSize}`,
        "Accept-Ranges": "bytes",
        "Content-Length": chunkSize,
        "Content-Type": "audio/mpeg",
      });

      file.pipe(res);
    } else {
      res.writeHead(200, {
        "Content-Length": fileSize,
        "Content-Type": "audio/mpeg",
        "Accept-Ranges": "bytes",
      });
      fs.createReadStream(filePath).pipe(res);
    }
  } catch (err) {
    console.error("Error streaming file:", err);
    res.status(500).send("Internal Server Error");
  }
});

router.post("/", async (req, res) => {
  try {
    const { text, model, url, summarize } = req.body;
    let content = text || "";

    if (url) content = await extractText(url);

    const finalText = summarize ? await summarizeText(content) : content;

    const chunkSize = 1800;
    const sentences = finalText.match(/[^.!?]+[.!?]+/g) || [finalText];
    const chunks = [];
    let currentChunk = "";

    for (const sentence of sentences) {
      if ((currentChunk + sentence).length > chunkSize) {
        chunks.push(currentChunk.trim());
        currentChunk = sentence;
      } else {
        currentChunk += sentence;
      }
    }
    if (currentChunk) chunks.push(currentChunk.trim());


    const audioFiles = [];

    for (let i = 0; i < chunks.length; i++) {
      console.log(`Generating chunk ${i + 1}/${chunks.length}`);
      const filePath = await generateSpeech(chunks[i],model);
      audioFiles.push(filePath);
    }


    let finalAudioPath = audioFiles[0];
    if (audioFiles.length > 1) {
      const outputFilename = `merged_${Date.now()}.mp3`;
      const outputPath = path.join("audio", outputFilename);

      const { mergeAudioFiles } = await import("../utils/mergeAudio.js");
      finalAudioPath = await mergeAudioFiles(audioFiles, outputPath);
    }

    const filename = path.basename(finalAudioPath);
    const audioUrl = `http://process.env.ip:8000/audio/${filename}`;

    res.json({
      status: "success",
      audio_url: audioUrl,
      chunks: audioFiles.length,
      transcript:finalText
    });
  } catch (error) {
    console.error("Podcast generation failed:", error);
    res.status(500).json({ error: "Podcast generation failed" });
  }
});


export default router;
