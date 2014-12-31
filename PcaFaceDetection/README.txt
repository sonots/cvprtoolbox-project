<name>.ts is a video file such as 05436v2_w2b.ts. 
$ denotes a command line, >> denotes a matlab command line.

1. Extract frames from a video file
   $ mkdir <name>
   $ ffmpeg -i <name>.ts <name>/%04d.png
   # $ identify -format '%wx%h' <name>/0001.png # => 1440x1080
   # $ mogrify -resize 1440x810! <name>/*.png #1440 x 1080 16:9
2. Crop faces in the first (say) 10 frames with imageclipper.exe
   $ imageclipper <name>/
   imageclipper should create png files under <name>/imageclipper/. 
3. Train PCA subspace
   >> runPca(<name>)
   This will collect files under <name>/imageclipper/ and train PCA.
4. Run PCA-based Face Detector
   >> runPcaFaceDetect(<name>)
   This creates cropped png files under <name>/pcafacedetect/.
   >> runPcaFaceDetect(<name>, frame) to restart from the frame number
