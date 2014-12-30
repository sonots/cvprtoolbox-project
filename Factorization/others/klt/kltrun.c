#include <stdlib.h>
#include <stdio.h>
#include "pnmio.h"
#include "klt.h"

void MyKLTWriteFeatureList(
  KLT_FeatureList fl,
  char *filename);

int main( int argc, const char* argv[] )
{
  unsigned char *img1, *img2;
  KLT_TrackingContext tc;
  KLT_FeatureList fl;
  //KLT_FeatureTable ft;
  int ncols, nrows;
  int i, j;
  FILE *fp;

  int nFeatures = 430;
  int sFrame = 0;
  int eFrame = 0;
  char *fmt  = "%d";
  char *base;
  char fname[1024];
  char ffmt[1024];

  if( argc == 1 ) {
    printf( "Usage: %s  <basename_of_pgm_files>"
            "  [-fmt <pgm_sequence_format = %s>]"
	    "  [-ef <index_of_end_frame = %d>]"
	    "  [-np <#_of_tracking_points = %d>]"
	    "  [-sf <index_of_start_frame = %d>]\n"
	    "Ex) %s ../hotel/hotel.seq -fmt %%d -ef 100 -np 430 -sf 0\n"
	    "Ex) %s ../castle/castle. -fmt %%03d -ef 27 -np 110 -sf 0\n"
	    "Ex) %s ../medusa/medusa -fmt %%03d -sf 110 -ef 180 -np 830\n",
	    argv[0], fmt, eFrame, nFeatures, sFrame, argv[0], argv[0], argv[0] );
    return 0;
  }
  for( i = 1; i < argc; ++i ) {
    if( !strcmp( argv[i], "-sf" ) ) {
      sFrame = atoi( argv[++i] );
    } 
    else if( !strcmp( argv[i], "-ef" ) ) {
      eFrame = atoi( argv[++i] );
    } 
    else if( !strcmp( argv[i], "-np" ) ) {
      nFeatures = atoi( argv[++i] );
    } 
    else if( !strcmp( argv[i], "-fmt" ) ) {
      fmt = (char *)argv[++i];
    } 
    else {
      base = (char *)argv[i];
    }
  }
  sprintf(ffmt, "%%s%s%%s\0", fmt);
  
  tc = KLTCreateTrackingContext();
  //tc->mindist = 20; // See klt.c for default values
  //tc->window_width  = 25; 
  //tc->window_height = 25;
  //tc->affine_window_width = 51;
  //tc->affine_window_height = 51;
  //KLTChangeTCPyramid(tc, 15);
  //KLTUpdateTCBorder(tc);
  //KLTPrintTrackingContext(tc);

  fl = KLTCreateFeatureList(nFeatures);
  //ft = KLTCreateFeatureTable(nFrames, nFeatures);
  tc->sequentialMode = TRUE;
  tc->writeInternalImages = FALSE;
  tc->affineConsistencyCheck = -1;  /* set this to 2 to turn on affine consistency check */

  i = sFrame;
  sprintf(fname, ffmt, base, i, ".pgm");
  img1 = pgmReadFile(fname, NULL, &ncols, &nrows);
  KLTSelectGoodFeatures(tc, img1, ncols, nrows, fl);
  // write
  sprintf(fname, ffmt, base, i, ".feat.ppm");   /* ppm file    */
  KLTWriteFeatureListToPPM(fl, img1, ncols, nrows, fname);
  //sprintf(fname, ffmt, base, i, ".feat.fl");  /* binary file */
  //KLTWriteFeatureList(fl, fname, NULL);
  sprintf(fname, ffmt, base, i, ".feat.txt");   /* text file   */
  //KLTWriteFeatureList(fl, fname, "%5.1f");
  MyKLTWriteFeatureList(fl, fname);
  
  for (i = sFrame+1; i <= eFrame; i++) {
    sprintf(fname, ffmt, base, i, ".pgm");
    img2 = pgmReadFile(fname, NULL, &ncols, &nrows);
    KLTTrackFeatures(tc, img1, img2, ncols, nrows, fl);
#ifdef REPLACE
    KLTReplaceLostFeatures(tc, img2, ncols, nrows, fl);
#endif

    // write
    sprintf(fname, ffmt, base, i, ".feat.ppm");   /* ppm file    */
    KLTWriteFeatureListToPPM(fl, img1, ncols, nrows, fname);
    //sprintf(fname, ffmt, base, i, ".feat.fl");  /* binary file */
    //KLTWriteFeatureList(fl, fname, NULL);
    sprintf(fname, ffmt, base, i, ".feat.txt");   /* text file   */
    //KLTWriteFeatureList(fl, fname, "%5.1f");
    MyKLTWriteFeatureList(fl, fname);

    img1 = img2;
  }
 
  sprintf(fname, ffmt, base, eFrame, ".feat.ppm");
  KLTWriteFeatureListToPPM(fl, img1, ncols, nrows, fname);

  //KLTFreeFeatureTable(ft);
  KLTFreeFeatureList(fl);
  KLTFreeTrackingContext(tc);
  free(img1);
  //free(img2);
  return 0;
}

void MyKLTWriteFeatureList(
  KLT_FeatureList fl,
  char *filename) {
  FILE *fp;
  int j;
  KLT_Feature feat;
  fp = fopen(filename, "w");
  for (j = 0; j < fl->nFeatures ; j++) {
    feat = fl->feature[j];
    fprintf(fp, "%f %f\n", (float) feat->x, (float) feat->y);
  }
  fclose(fp);
}


