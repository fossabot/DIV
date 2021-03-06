#include "internal.h"
#include "gfx.h"
#include <i86.h>
#include <dos.h>
#include <malloc.h>

#include "..\source\inter.h"

// For debug purposes
int num_blocks;
void *mem_blocks[8192];

void *MemAlloc(long int size)
{
  void *p;

  p=malloc(size);
  if (p==NULL)
    FatalError(ER_MEMORY,NULL);
  else {
    mem_blocks[num_blocks]=p;
  }

  num_blocks++;
  return(p);
}

void *MemRealloc(int *pointer, int *old_size, int size)
{
  int i;

  if (pointer==NULL)
    pointer=MemAlloc(size);
  else if (size<*old_size)
    return(pointer);
  else {
    for (i=0;i<num_blocks;i++) {
      if (mem_blocks[i]==pointer) {
        free(pointer);
        pointer=MemAlloc(size);
        mem_blocks[i]=pointer;
        *old_size=size;
        return(pointer);
      }
    }
  }

  return(pointer);
}

void *MemZAlloc(long int size)
{
	void *p;
	p=MemAlloc(size);
	if (p) memset(p,0,size);
	return(p);
}

void MemFreeAll()
{
  int i;

  for (i=0;i<num_blocks;i++) {
    if (mem_blocks[i]!=NULL)
      free(mem_blocks[i]);
  }

  num_blocks=0;
}

void rvmode(void);
void kbdReset(void);

void FatalError(int type, char *msg)
{
  e(100);

	VPE_Stop();
	VPE_Shut();
	ShutGraph();

  rvmode();
  kbdReset();

	exit(26);
}

