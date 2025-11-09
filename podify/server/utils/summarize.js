import dotenv from "dotenv";
dotenv.config();
import { GoogleGenerativeAI } from "@google/generative-ai";

const genAI = new GoogleGenerativeAI(process.env.GEMINI_KEY);

export const summarizeText = async (text) => {
  const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });

  const prompt = `I want a solo very long podcast script on the topic "${text}". Do not include any stage directions, sound effects, or scene descriptions such as (Intro music fades in/out), (pause), or anything in parentheses. Start immediately with the spoken script and end only with the spoken script. Avoid bold text or any formatting. Return only the narration as if someone is talking. Make it long enough to last around 10 minutes when spoken at a natural pace (about 1300–1500 words).`;

  const result = await model.generateContent(prompt);
  const cleanText = result.response.text().replace(/\s+/g, " ").trim(); // one line
  console.log(cleanText);
  return cleanText;
};
