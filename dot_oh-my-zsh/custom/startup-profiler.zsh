# Startup profiling - Enable with: PROFILE_STARTUP=true zsh

if [[ "$PROFILE_STARTUP" == "true" ]]; then
  zmodload zsh/zprof
  setopt SOURCE_TRACE

  print_startup_profile() {
    echo "\n=== ZSH Startup Profile ==="
    zprof
  }
fi
