import dotenv from "dotenv";
dotenv.config();

import fs from "fs";
import path from "path";
import express from "express";
import cors from "cors";
import podcastRoute from "./routes/podcast.js";



const app = express();

app.use(express.json());
app.use(cors());

const AUDIO_DIR = path.resolve("audio");
app.use("/audio", express.static(AUDIO_DIR));

app.use("/api/podcast", podcastRoute);

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server started on port ${PORT}`));
