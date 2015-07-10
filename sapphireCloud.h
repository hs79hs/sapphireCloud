
#ifndef SAPPHIRECLOUD_H
#define SAPPHIRECLOUD_H

extern "C"
{
#include "ffmpeg.h"
}
#include <string>
#include <iostream>


#define MAX_ALL_OPTIONS_NUM     50
#define MAX_EACH_OPTION_LENGTH  80
#define MAX_ALL_OPTIONS_LENGTH  500


typedef struct {
  int argc;
  char ** argv;
} Argc_v;


#endif
