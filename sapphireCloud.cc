
#include "sapphireCloud.h"
#include <syscall.h>
#include <unistd.h>
#include <pthread.h>
//#include <vector>
//#include <initializer_list>
#include <cassert>
#include <sys/types.h>
#include <sys/wait.h>
#include <map>

using namespace std;

//#define DEBUG
#define NUM_NEW_THREADS 4


map<int, string> processes_info;


//use 'void *' as the only parameter for consistent reason with pthread_create.
//later it can be changed to e.g. using 'string' or 'vector'.
static void *call_ffmpeg(void *args)
{
  char paras[MAX_ALL_OPTIONS_NUM][MAX_EACH_OPTION_LENGTH];
  char *ffmpeg_argv[MAX_ALL_OPTIONS_NUM];
  int i,j=0,k=0;
  int iCmdLen=0;
  Argc_v argc_v;
  const char *cmdOptions = static_cast<const char*>(args);

  pthread_detach(pthread_self());

  iCmdLen = strlen(cmdOptions);
  printf("cmd length is %d\n", iCmdLen);

  //parse standard command and options
  memset(paras, 0, sizeof(paras));
  for (i=0; i<iCmdLen; i++)
    {
      if (cmdOptions[i] != ' ')
	{
	  paras[j][k] = cmdOptions[i];
	  k++;
	}
      else
	{
	  j++;
	  k=0;
	}
    }

  //set argc and argv to call ffmpeg
  argc_v.argc = ++j;
  for (i=0; i<argc_v.argc; ++i)
    {
      ffmpeg_argv[i] = paras[i];
    }

  argc_v.argv = (char **)&ffmpeg_argv;

#ifdef DEBUG
  printf("argc is %d\n", argc_v.argc);
  for (i=0; i<argc_v.argc; ++i)
    {
      printf("argv %d is %s\n", i, argc_v.argv[i]);
    }
#endif

  //have to wait several seconds to let other threads run
  sleep(5);
  cout << "thread " << syscall(SYS_gettid) << " is running ..." << endl;

  ffmpeg(argc_v.argc, argc_v.argv);
  
  printf("thread exit, id is %lu\n", syscall(SYS_gettid));
  return ((void *)0);
}



static void create_new_process(const string &cmdOptions)
{
  assert(cmdOptions.size() > 0);

  cout << __func__ << ": line " << __LINE__ << ": creating new process" << endl;

  pid_t pid = fork();

  switch(pid)
    {
    case -1:
      perror("fork failed");
      exit(1);
      break;

    case 0:
      //in new or child process
      //the following two lines cannot be put into one line, why?
      int tid;
      tid = syscall(SYS_gettid);
      printf("thread start, id is %d\n", tid);
      call_ffmpeg((void *)cmdOptions.c_str());
      exit(1);
      break;

    default:
      //in original or father process
      processes_info[pid] = cmdOptions;
      break;
    }

  /*
    if(0 != pthread_create(&newThread, NULL, call_ffmpeg, (void *)cmdOptions.c_str()))
    {
    cout << __func__ << ": line " << __LINE__ << ": pthread create error" << endl;
    }
  */
  //use pthread_detach() in new thread instead of pthread_join() here to avoid blocked
  //pthread_join(newThread, NULL);
  
  return;
}


int main(int argc, char **argv)
{
  const string standardCmd = "ffmpeg -i rtp://52.25.184.17:8888 -loglevel error -c:v libvpx -c:a libvorbis -c:s copy -r 15 -force_key_frames expr:gte(t,n_forced*5) -f segment -segment_list /usr/local/nginx/html/mnt/live/camera1/camera1.m3u8 -segment_list_flags +live -segment_list_type hls -segment_list_size 0 -segment_list_entry_prefix http://52.25.184.17/bath/ -segment_time 5 -segment_wrap 100 -segment_start_number 0 /usr/local/nginx/html/mnt/live/camera1/out%03d.webm";
  int inport = 5014;

  cout << __func__ << ": line " << __LINE__ << ": start to process ..." << endl;

  for(int i=0; i < NUM_NEW_THREADS; ++i)
    {
      string tempCmd = standardCmd;
      //replace '8888' by specified port
      tempCmd.replace(tempCmd.find("8888"), 4, to_string(inport + i*10));

      if(i > 0)
	{
	  auto pos = tempCmd.find("camera1");
	  while (pos != string::npos)
	    {
	      //replace 'camera1' to the name of wanted camera
	      tempCmd.replace(pos, 7, "camera" + to_string(i+1));
	      pos = tempCmd.find("camera1", pos);
	    }
	}

      cout << __func__ << ": line " << __LINE__ << ": the cmd is : " << tempCmd << endl;

      //create new process to call ffmpeg to wait and cut the video from specified port
      create_new_process(tempCmd);

      sleep(1);
    }

  sleep(1);

  while(1)
    {
      pid_t pid;
      int status=0;

      pid = waitpid(-1,&status,0);

      if(pid>0)
	{
	  cout << "child " << pid << "has returned, status is " << status << endl;
	  
	  //re-create the process with returned pid to wait for new stream coming
	  try {
	    create_new_process(processes_info.at(pid));
	  } catch (out_of_range) {
	    cerr << "Cannot find pid info with the value " << pid << endl;
	  }
	  processes_info.erase(pid);
	}
      else{
	cerr << "return value of waitpid is " << pid << endl;
      }
    }

  cout << __func__ << ": line " << __LINE__ << ": sapphireCloud return!" << endl;

  //use pthread_exit() here instead of return to avoid killing other threads.
  //pthread_exit(0);
  return 0;
}


