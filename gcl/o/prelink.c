#define NO_PRELINK_UNEXEC_DIVERSION

#include "include.h"

#if !defined(__MINGW32__) && !defined(__CYGWIN__)
extern FILE *stdin __attribute__((weak));
extern FILE *stderr __attribute__((weak));
extern FILE *stdout __attribute__((weak));

#ifdef USE_READLINE
#ifdef READLINE_IS_EDITLINE
#define MY_RL_VERSION 0x0600
#else
#define MY_RL_VERSION RL_READLINE_VERSION
#endif
#if MY_RL_VERSION < 0x0600
extern Function		*rl_completion_entry_function __attribute__((weak));
extern char		*rl_readline_name __attribute__((weak));
#else
extern rl_compentry_func_t *rl_completion_entry_function __attribute__((weak));
extern const char *rl_readline_name __attribute__((weak));
#endif
#endif
#endif

void
prelink_init(void) {
  
  my_stdin=stdin;
  my_stdout=stdout;
  my_stderr=stderr;
#ifdef USE_READLINE
  my_rl_completion_entry_function_ptr=(void *)&rl_completion_entry_function;
  my_rl_readline_name_ptr=(void *)&rl_readline_name;
#endif

}

