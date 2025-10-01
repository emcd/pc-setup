#!/usr/bin/env python3
''' Custom statusline for Claude Code showing token usage. '''

from json import JSONDecodeError as _JSONDecodeError
from json import loads as _json_loads
from pathlib import Path
from sys import stdin as _stdin


BUDGET_TOKENS = 200000
OVERHEAD_TOKENS = 30000
CHUNK_SIZE_BYTES = 10000


def _abbreviate_home_in_path( path: str ) -> str:
    ''' Replaces home directory prefix with tilde. '''
    home = str( Path.home( ) )
    if path.startswith( home ): return '~' + path[ len( home ): ]
    return path


def _detect_git_branch( cwd: str ) -> str | None:
    ''' Detects current Git branch by parsing .git/HEAD. '''
    git_dir = Path( cwd ).resolve( ) if cwd != '~' else Path.home( )
    while git_dir != git_dir.parent:
        git_head = git_dir / '.git' / 'HEAD'
        if git_head.exists( ):
            try:
                content = git_head.read_text( ).strip( )
                if content.startswith( 'ref: refs/heads/' ):
                    return content[ len( 'ref: refs/heads/' ): ]
                return f"detached@{content[:7]}"
            except ( OSError, IOError ): return None
        git_dir = git_dir.parent
    return None


def _extract_chunk_from_file( path: Path, size: int ) -> bytes:
    ''' Reads last N bytes from file. '''
    with open( path, 'rb' ) as f:
        f.seek( 0, 2 )
        file_size = f.tell( )
        f.seek( max( 0, file_size - size ) )
        return f.read( )


def _decode_chunk_safely( chunk: bytes ) -> list[ str ]:
    ''' Decodes byte chunk to text lines, handling UTF-8 boundaries. '''
    newline_index = chunk.find( b'\n' )
    if newline_index != -1 and newline_index + 1 < len( chunk ):
        chunk = chunk[ newline_index + 1: ]
    return chunk.decode( 'utf-8' ).splitlines( )


def _extract_token_usage( usage: dict[ str, int ] ) -> tuple[ int, float ]:
    ''' Calculates total tokens and percentage from usage dictionary. '''
    total = (
        usage.get( 'input_tokens', 0 )
        + usage.get( 'cache_creation_input_tokens', 0 )
        + usage.get( 'cache_read_input_tokens', 0 )
        + usage.get( 'output_tokens', 0 ) )
    total_with_overhead = total + OVERHEAD_TOKENS
    percentage = ( total_with_overhead / BUDGET_TOKENS ) * 100
    return ( total_with_overhead, percentage )


def _find_latest_token_info( lines: list[ str ] ) -> tuple[ int, float ] | None:
    ''' Finds most recent assistant message with token usage. '''
    for line in reversed( lines ):
        if not line.strip( ): continue
        try: msg = _json_loads( line )
        except _JSONDecodeError: continue
        if msg.get( 'type' ) == 'assistant' and 'message' in msg:
            usage = msg[ 'message' ].get( 'usage' )
            if usage: return _extract_token_usage( usage )
    return None


def _format_status(
    cwd: str, branch: str | None, token_info: tuple[ int, float ] | None
) -> str:
    ''' Formats status line with optional token usage, directory, and branch. '''
    sections = [ ]
    if token_info:
        total, percentage = token_info
        if percentage < 50: emoji = '🟢'
        elif percentage < 75: emoji = '🟡'
        else: emoji = '🔴'
        total_k = total // 1000
        sections.append( f"{emoji} {total_k}k/200k ({percentage:.0f}%)" )
    sections.append( f"📁 {cwd}" )
    if branch: sections.append( f"🌿 {branch}" )
    return ' | '.join( sections )


def main( ) -> None:
    ''' Parses transcript and displays token usage and current directory. '''
    input_data = _json_loads( _stdin.read( ) )
    transcript_path = Path( input_data[ 'transcript_path' ] )
    cwd = _abbreviate_home_in_path( input_data.get( 'cwd', '~' ) )
    branch = _detect_git_branch( input_data.get( 'cwd', '~' ) )
    chunk = _extract_chunk_from_file( transcript_path, CHUNK_SIZE_BYTES )
    lines = _decode_chunk_safely( chunk )
    token_info = _find_latest_token_info( lines )
    status = _format_status( cwd, branch, token_info )
    print( status, end = '' )


if __name__ == '__main__':
    try: main( )
    except Exception as exc:
        print( f"⚠️ {exc}", end = '' )
