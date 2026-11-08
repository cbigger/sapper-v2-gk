#!/usr/bin/env bash
# tmux-lib.sh — shared tmux transport primitives for the commander units.
#
# These three functions were previously duplicated byte-for-byte in worker.sh
# and watchdog.sh (both marked "verbatim from tmux-drive.sh"). They are the
# single seam the comms refactor retires: once workers run headless and the
# control plane moves to the durable store, send_literal / accept_dialogs and
# the capture-pane scraping get deleted here and nowhere else.
#
# Depends on $SESSION being set by the sourcing script (functions read it at
# call time). Source after SESSION is defined, e.g.:
#   source "$(dirname "${BASH_SOURCE[0]}")/tmux-lib.sh"

pane_text() { tmux capture-pane -pt "$SESSION:$1" 2>/dev/null; }

send_literal() {  # send_literal <window> <text> [enter] — NEVER bracketed paste
  tmux send-keys -t "$SESSION:$1" -l -- "$2"
  sleep 0.5
  [[ "${3:-enter}" == "enter" ]] && tmux send-keys -t "$SESSION:$1" Enter
}

accept_dialogs() {  # accept_dialogs <window> <pane-text> -> 0 if a dialog was dismissed
  local win="$1" pane="$2"
  if printf '%s' "$pane" | grep -qE 'Enter to confirm|Yes, I accept|I accept'; then
    # Aim by the ❯ focus marker: security dialogs default-focus "No, exit",
    # so a bare Enter CHOOSES NO. Only move+confirm when focus is off Yes.
    if printf '%s' "$pane" | grep -qE '❯[^\n]*No, exit'; then
      tmux send-keys -t "$SESSION:$win" Down; sleep 0.4
    fi
    tmux send-keys -t "$SESSION:$win" Enter; sleep 1.5
    return 0
  fi
  return 1
}
