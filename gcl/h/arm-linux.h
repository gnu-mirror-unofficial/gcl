#include "linux.h"

/*  #ifdef IN_GBC */
/*  #define GET_FAULT_ADDR(sig,code,sv,a) \ */
/*      ((void *)(((struct sigcontext_struct *)(&code))->cr2))      */
/*  #endif */

/*#define NULL_OR_ON_C_STACK(x) ((x)==0 || ((unsigned int)x) > (unsigned int)(pagetochar(MAXPAGE+1)))*/

/*  #define ADDITIONAL_FEATURES \ */
/*  		     ADD_FEATURE("BSD386"); \ */
/*        	             ADD_FEATURE("MC68020") */


/*  #define	I386 */
/*  #define SGC */


/*  #define CLEAR_CACHE do {\ */
/*    void *v=memory->cfd.cfd_start,*ve=v+memory->cfd.cfd_size; \ */
/*    register unsigned long _beg __asm ("a1") = (unsigned long)(v);	\ */
/*    register unsigned long _end __asm ("a2") = (unsigned long)(ve);\ */
/*    register unsigned long _flg __asm ("a3") = 0;			\ */
/*    __asm __volatile ("swi 0x9f0002		@ sys_cacheflush"	\ */
/*	    :  no outputs 					\ */
/*		    : no inputs					\ */
/*		    : "a1");						\*/
/*  } while (0) */

#define CLEAR_CACHE do {\
  void *v=memory->cfd.cfd_start,*ve=v+memory->cfd.cfd_size; \
  register unsigned long _beg __asm ("a1") = (unsigned long)(v);	\
  register unsigned long _end __asm ("a2") = (unsigned long)(ve);\
  register unsigned long _flg __asm ("a3") = 0;			\
  __asm __volatile ("swi 0x9f0002		@ sys_cacheflush"	\
		    : "=r" (_beg)				\
		    : "0" (_beg), "r" (_end), "r"(_flg));	\
} while (0)
