from typing import Any

from kitty.boss import Boss
from kitty.session import default_save_as_session_opts, save_as_session_part2
from kitty.window import Window

SESSION = "~/.config/kitty/saved-session.kitty"


def _save_as_session(boss: Boss, window: Window, data: dict[str, Any]) -> None:
    opts = default_save_as_session_opts()
    opts.save_only = True
    opts.use_foreground_process = True
    save_as_session_part2(boss, opts, SESSION)


def on_focus_change(boss: Boss, window: Window, data: dict[str, Any]) -> None:
    _save_as_session(boss, window, data)


def on_title_change(boss: Boss, window: Window, data: dict[str, Any]) -> None:
    _save_as_session(boss, window, data)
