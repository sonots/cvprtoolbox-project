%
%  Copyright (c) 2005. Matthew Brown, University of British Columbia.
%  This software is being made available for evaluation purposes
%  only (see file LICENSE.TXT for conditions).  
%

-------------------------
Autostitch - Demo Version
-------------------------

Matthew Brown and David Lowe
(mbrown[at]cs.ubc.ca)

Autostitch(TM) is world's first fully automatic 2D image stitcher. This demo 
has been created to demonstrate the basic functionality of Autostitch. The 
user simply selects a set of images using the windows interface, and the 
software automatically stitches them into a panorama. This program has 
been tested under Windows XP/2000/98. 


How to use this demo:

1. Run the program autostitch.exe.
2. Select File->Open and select a set of images to be stitched. 
Currently, the input images must be in JPEG format.
3. The program will align the images, taking a few seconds per image.
4. The program outputs the file pano.jpg in the input directory. It also
attempts to open the output panorama using the default image viewer.

NOTE 1: if the image viewer command fails, an error message will appear. Navigate to the directory of input images and open the file pano.jpg to view the result.

Options:

Using Edit->Options you can set the following options:

1. Output Size
You may specify the output size based on the desired output width, height or relative size compared to the input images. Be sure to check the radio button beside width, height or relative size appropriately.
2. Blending Method
Select linear or multi-band blending. Multi-band blending is slower but gives better results. 
3. Gain Compensation
Selecting gain compensation causes Autostitch to modify the brightness of the images so that they are consistent with each other. This causes dark images to become brighter and bright images to become darker. To amplify the effect, increase the value of gain sigma. Note that this can cause saturation. If this occurs try decreasing the gain sigma or gain mean.
4. Crop Settings
You can specify the rendering range in terms of angles theta (longitude) and phi (latitude). AutoCrop selects these ranges automatically. Make sure AutoCrop is not selected if you wish to set the ranges manually.
5. Matching Options
You can specify the size of the images for SIFT feature extraction and some parameters for the RANSAC algorithm here. If images fail to match, try decreasing alpha and beta, and increasing the SIFT image size. If incorrect matches are found, try increasing alpha and beta.
6. Orientation Settings
AutoStraighten uses a heuristic method to straighten out wavy panoramas.
The manual orientation settings allow you to specify extra rotations for the panorama e.g. to centre it.
7. Image Rotation
If the input images are rotated, select the rotation of the input images here.
8. Other Options
Choose a JPEG quality setting in the range 75-100.
Setting the System Memory allows the program to allocate resources more efficiently. If you get an "Out of Memory" message, try decreasing the System Memory.

To view the output image at actual size in Windows Picture and Fax Viewer, 
select the "Acutal Size" option (CTRL-A).
