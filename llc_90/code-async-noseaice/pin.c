/*
** Pin the calling process to a cpu
*/

#include <stdio.h>
#include <ctype.h>
#include <unistd.h>
#include <stdlib.h>

#define __USE_GNU  1
#include <sched.h>


#define DIE_IF(expr) { if (expr) {perror( # expr ) ; exit(1);} }


/* Pin to the cpu */
int
pin_absolute(int cpu)
{
  cpu_set_t new_affinity;
  if ((cpu < 0) || (cpu >= CPU_SETSIZE)) return -1;

  /* Set a new affinity mask with just the one cpu */
  CPU_ZERO(&new_affinity);
  CPU_SET(cpu, &new_affinity);
  DIE_IF(sched_setaffinity(0, sizeof(cpu_set_t), &new_affinity) < 0);
  return 0;
}


/* Pin to the cpu, relative to the current affinity mask */
int
pin_relative(int relative_cpu)
{
  int count, i;
  cpu_set_t current_affinity, new_affinity;
  if ((relative_cpu < 0) || (relative_cpu >= CPU_SETSIZE)) return -1;

  /* Get the current cpu affinity */
  CPU_ZERO(&current_affinity);
  DIE_IF(sched_getaffinity(0, sizeof(cpu_set_t), &current_affinity) < 0);

  /* Find the cpu'th set bit */
  for(count = -1, i = 0; i < CPU_SETSIZE; i++) {
    if (CPU_ISSET(i, &current_affinity)) {
      if (++count == relative_cpu) break;
    }
  }

  /* Check the current affinity mask had enough bits to satisfy the request */
  if (count < relative_cpu) return -1;


  /* Set a new affinity mask with just the one cpu */
  CPU_ZERO(&new_affinity);
  CPU_SET(i, &new_affinity);
  DIE_IF(sched_setaffinity(0, sizeof(cpu_set_t), &new_affinity) < 0);
  return 0;
}



/* Fortran interface */
int pin_absolute_(int *cpu) { return pin_absolute(*cpu); }
int pin_relative_(int *relative_cpu) { return pin_relative(*relative_cpu); }

