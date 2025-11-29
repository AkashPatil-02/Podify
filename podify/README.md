# Podify

A small app and API that converts long-form text or web articles into spoken podcast audio files.

Podify contains a Flutter client (mobile) and a Node.js server that:

- extracts text from a URL or accepts raw text
- (optionally) summarizes the text using a generative model
- converts the text to speech in chunks (Deepgram TTS by default)
- merges the generated audio into a single downloadable MP3

**Contents**

- What it does
- Why it’s useful
- Environment variables
- API usage examples

---

**What the project does**

Podify turns text or web pages into spoken podcast audio. The server can extract text from an article URL, summarize it with a generative model if requested, synthesize speech in chunks to respect TTS limits, and return a URL to the produced MP3.

**Why Podify is useful**

- Easily produce spoken versions of long-form content for listening on the go.
- Demonstrates a full-stack flow: web scraping, optional summarization, TTS, audio post-processing (FFmpeg), and a Flutter front-end.
- Useful as a base for accessibility, podcast generation, or content repurposing tools.

---

**Repository layout (important parts)**

- `server/` — Node.js API and TTS pipeline
  - `app.js` — Express server entrypoint
  - `routes/podcast.js` — endpoint to create podcasts (`POST /api/podcast`)
  - `utils/` — helpers: `extractText.js`, `summarize.js`, `tts.js`, `mergeAudio.js`
- `lib/` — Flutter app source (mobile client)

---


**Environment variables**

Create a `server/.env` file with the following keys (examples):

```env
# Deepgram API key used for TTS
deepgramApiKey=sk_xxx

# Google Gemini / Generative AI key used for summarization (optional)
GEMINI_KEY=ya29.xxxx

# Optional: PORT for server (default 5000)
PORT=5000
```

Notes:

- `deepgramApiKey` is required for the default TTS implementation in `server/utils/tts.js`.
- Summarization is optional; the server will use the full extracted text if summarization is disabled or returns less text than the original input.

---

**API — Podcast generation**

POST /api/podcast

Request JSON body:

```json
{
  "text": "<raw text to convert>",
  "url": "https://example.com/article", // optional, server will extract text
  "summarize": true, // optional, run summarization first
  "model": "<optional TTS voice model identifier>"
}
```

Response (success):

```json
{
  "status": "success",
  "audio_url": "http://<server>/audio/merged_12345.mp3",
  "chunks": 3,
  "transcript": "..."
}
```

Example curl (use your server address/port):

```bash
curl -X POST http://localhost:5000/api/podcast \
	-H "Content-Type: application/json" \
	-d '{"url":"https://example.com/article","summarize":false}'
```

