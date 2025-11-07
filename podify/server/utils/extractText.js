import fetch from "node-fetch";
import * as cheerio from "cheerio";

export const extractText = async (url) => {
  const response = await fetch(url);
  const html = await response.text();
  const $ = cheerio.load(html);
  return $("body").text().replace(/\s+/g, " ").trim();
};
