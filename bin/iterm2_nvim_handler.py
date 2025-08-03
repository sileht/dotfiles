#!/usr/bin/env -S uv run --script
#
# /// script
# dependencies = ["iterm2"]
# ///

import asyncio
import sys

import iterm2


async def open_nvim_window(connection: iterm2.Connection):
    cmd = f"zsh -is eval '/opt/homebrew/bin/nvim \"{sys.argv[1]}\"'"
    await iterm2.Window.async_create(connection, command=cmd)
    await asyncio.create_subprocess_shell(
        "osascript -e 'tell application \"iTerm\" to activate'",
    )


iterm2.run_until_complete(open_nvim_window)
