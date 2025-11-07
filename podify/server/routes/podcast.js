import express from "express";
import { extractText } from "../utils/extractText.js";
import { summarizeText } from "../utils/summarize.js";
import { generateSpeech } from "../utils/tts.js";

const router = express.Router();

router.post("/", async (req, res) => {
    try {
        const { text, url, summarize } = req.body;

        let content = text || "";
        if (url) {
            content = await extractText(url);
        }
        const finalText = summarize ? await summarizeText(content) : content;

        const name = (content ? content.slice(0, 10) : 'podcast').replace(/[^a-zA-Z0-9-_]/g, '');

        const filePath = await generateSpeech(finalText);
        


        return res.json({
            status: "success",
            audio_url: `http:// 10.217.38.192:8000/${filePath}`,
            drive_file_id: uploadedFile.data.id 
        });
    } catch (error) {
        console.log(error);
        res.status(500).json({ error: "podcast generation failed" });
    }
});

export default router;
