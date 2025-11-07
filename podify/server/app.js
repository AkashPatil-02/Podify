import dotenv from "dotenv";
dotenv.config();

import express from "express";
import cors from "cors";
import podcastRoute from "./routes/podcast.js";


const app = express();

app.use(express.json());
app.use(cors());

app.use("/api/podcast", podcastRoute);

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server started on port ${PORT}`));
