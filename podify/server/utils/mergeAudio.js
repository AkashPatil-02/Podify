import ffmpeg from "fluent-ffmpeg";
import path from "path";
import ffmpegInstaller from "@ffmpeg-installer/ffmpeg";
import ffprobeInstaller from "@ffprobe-installer/ffprobe";

ffmpeg.setFfmpegPath(ffmpegInstaller.path);
ffmpeg.setFfprobePath(ffprobeInstaller.path);


export const mergeAudioFiles = async (inputFiles, outputFile) => {
  return new Promise((resolve, reject) => {
    const command = ffmpeg();

    inputFiles.forEach(file => command.input(file));

    command
      .on("error", err => {
        console.error("Error merging files:", err);
        reject(err);
      })
      .on("end", () => {
        console.log("Merged file created:", outputFile);
        resolve(outputFile);
      })
      .mergeToFile(outputFile, path.dirname(outputFile));
  });
};
