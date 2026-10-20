#!/usr/bin/env python3
"""Scrape an Opencode session transcript from its most recent compaction point.

Read-only: opens the Opencode SQLite store with ``mode=ro`` and never writes
to it. The live session is left untouched.

Stores: OpenCode 2 keeps new transcripts in a different table than OpenCode 1
did. V1 wrote one ``message`` row per message and one ``part`` row per content
block; V2 writes both into a single ``session_message`` row whose ``data``
carries the content inline as ``data.content``. After the V2 migration the
``message`` and ``part`` tables hold the migrated V1 transcripts and are no
longer written, while ``session_message`` grows with every new session. This
scraper reads the V1 tables, so it covers the sessions that existed before the
migration -- including the frozen Muse sessions -- and returns nothing for
sessions created under V2. Reading the V2 store means parsing ``session_message``
rows and their inline content instead.

Compaction detection:
  - ``session.time_compacting`` set  -> scrape messages newer than it.
  - otherwise                         -> fall back to ``--last-n`` messages
    (default 60) with a warning, since full sessions can be huge.

Usage:
  scrape-opencode-transcript.py SES_ID [--last-n N] [--format text|json]
"""

from __future__ import annotations

import argparse
import json
import os
import sqlite3
import sys
from typing import Any


def open_readonly(path: str) -> sqlite3.Connection:
    """Open the Opencode store without any write or lock side effects."""
    return sqlite3.connect("file:{}?mode=ro".format(path), uri=True)


def compaction_floor(
    conn: sqlite3.Connection, session_id: str
) -> tuple[int | None, str]:
    """Return the (timestamp ms, source) of the most recent compaction point.

    Opencode does not set ``session.time_compacting``; compaction survives in
    the transcript itself. Preferred markers, in order:
      1. the compaction summary itself: an assistant text part starting
         with "## Objective" (sections Objective / Important Details /
         Work State), written immediately before each handoff;
      2. user handoff starting "Conversation compacted" (model switches);
      3. synthetic ``compaction_continue`` parts;
      4. ``session.time_compacting`` when set.
    """
    if (
        conn.execute("SELECT 1 FROM session WHERE id = ?", (session_id,)).fetchone()
        is None
    ):
        raise KeyError("unknown session: {}".format(session_id))
    row = conn.execute(
        "SELECT m.time_created FROM message m JOIN part p ON p.message_id = m.id"
        ' WHERE m.session_id = ? AND p.data LIKE \'%"text":"## Objective%\''
        " ORDER BY m.time_created DESC LIMIT 1",
        (session_id,),
    ).fetchone()
    if row is not None:
        return row[0], "compaction summary"
    row = conn.execute(
        "SELECT m.time_created FROM message m JOIN part p ON p.message_id = m.id"
        ' WHERE m.session_id = ? AND p.data LIKE \'{"type":"text"%\''
        " AND p.data LIKE '%Conversation compacted%'"
        " ORDER BY m.time_created DESC LIMIT 1",
        (session_id,),
    ).fetchone()
    if row is not None:
        return row[0], "compaction handoff"
    row = conn.execute(
        "SELECT m.time_created FROM message m JOIN part p ON p.message_id = m.id"
        " WHERE m.session_id = ? AND p.data LIKE '%compaction_continue%'"
        " ORDER BY m.time_created DESC LIMIT 1",
        (session_id,),
    ).fetchone()
    if row is not None:
        return row[0], "synthetic marker"
    row = conn.execute(
        "SELECT time_compacting FROM session WHERE id = ?", (session_id,)
    ).fetchone()
    if row is not None and row[0]:
        return row[0], "session.time_compacting"
    return None, "none"


def sanitize_part(data: dict[str, Any]) -> dict[str, Any]:
    """Return a copy with embedded data: URLs replaced by a size placeholder."""
    cleaned = dict(data)
    url = cleaned.get("url")
    if isinstance(url, str) and url.startswith("data:"):
        cleaned["url"] = "<elided-data-url:{}-chars>".format(len(url))
    return cleaned


def render_part(data: dict[str, Any], think_chars: int = 300) -> str | None:
    """Render one part as a short human-readable line."""
    kind = data.get("type")
    if kind == "text":
        return "TEXT: {}".format(data.get("text", ""))
    if kind == "reasoning":
        text = (data.get("text") or "").strip().replace("\n", " ")
        if not text:
            return None
        if think_chars > 0 and len(text) > think_chars:
            text = text[:think_chars] + "...[truncated]"
        return "THINK: {}".format(text)
    if kind == "tool":
        state = data.get("state", {})
        output = state.get("output", "")
        if isinstance(output, str) and len(output) > 500:
            output = output[:500] + "...[truncated]"
        return "TOOL {} -> {}".format(data.get("tool"), json.dumps(output)[:500])
    if kind in ("step-start", "step-finish", "reason"):
        return None
    if kind == "file":
        return "FILE: {} ({})".format(data.get("filename"), data.get("mime"))
    return "{}: {}".format(kind, json.dumps(data)[:300])


def main(argv: list[str]) -> int:
    """Entry point; returns a process exit code."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("session_id")
    parser.add_argument("--db", default="~/.local/share/opencode/opencode.db")
    parser.add_argument("--last-n", type=int, default=60)
    parser.add_argument("--format", choices=("text", "json"), default="text")
    parser.add_argument(
        "--no-tools",
        action="store_true",
        help="elide tool calls and their results; keep user/assistant text",
    )
    parser.add_argument(
        "--think-chars",
        type=int,
        default=300,
        help="cap on reasoning-summary characters in text output (0 = unlimited)",
    )
    args = parser.parse_args(argv)

    conn = open_readonly(os.path.expanduser(args.db))
    try:
        floor, source = compaction_floor(conn, args.session_id)
        if floor is not None:
            msgs = conn.execute(
                "SELECT id, data FROM message WHERE session_id = ?"
                " AND time_created >= ? ORDER BY time_created",
                (args.session_id, floor),
            ).fetchall()
            print("# from {} at {}".format(source, floor), file=sys.stderr)
        else:
            print(
                "# never compacted; showing last {}".format(args.last_n),
                file=sys.stderr,
            )
            msgs = conn.execute(
                "SELECT id, data FROM message WHERE session_id = ?"
                " ORDER BY time_created DESC LIMIT ?",
                (args.session_id, args.last_n),
            ).fetchall()
            msgs.reverse()

        for msg_id, raw in msgs:
            info = json.loads(raw)
            role = info.get("role", "?")
            rows = conn.execute(
                "SELECT data FROM part WHERE message_id = ? ORDER BY time_created",
                (msg_id,),
            ).fetchall()
            decoded = [sanitize_part(json.loads(praw)) for (praw,) in rows]
            if args.no_tools:
                decoded = [p for p in decoded if p.get("type") != "tool"]
            if args.format == "json":
                print(json.dumps({"role": role, "parts": decoded}))
                continue
            print("## {} {}".format(role.upper(), msg_id))
            for data in decoded:
                line = render_part(data, args.think_chars)
                if line:
                    print(line)
            print()
    except KeyError as exc:
        print("error: {}".format(exc), file=sys.stderr)
        return 1
    finally:
        conn.close()
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
