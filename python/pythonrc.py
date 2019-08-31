# -----------------------------------------------------------------------------
# Python repl config
# -----------------------------------------------------------------------------

import datetime
import math
import os
import random
import re
import sys
from math import *
from pydoc import pager

try:
    from see import see
except ImportError:
    see = dir


PY = sys.version_info[0]


class Term:
    RESET  = "\x1b[0m"
    BOLD   = "\x1b[1m"
    DIM    = "\x1b[2m"
    UNBOLD = "\x1b[21m"
    UNDIM  = "\x1b[22m"
    RED    = "\x1b[31m"
    GREEN  = "\x1b[32m"
    YELLOW = "\x1b[33m"
    BLUE   = "\x1b[34m"
    PINK   = "\x1b[35m"
    CYAN   = "\x1b[36m"

    @classmethod
    def color(cls, string, color, uncolor=RESET):
        return ''.join((color, string, uncolor))

    @classmethod
    def dim(cls, string):
        return ''.join((cls.DIM, string, cls.UNDIM))

    @classmethod
    def setup_prompt(cls):
        version = '.'.join(str(s) for s in sys.version_info[:2])
        sys.ps1 = '(py%s)> ' % version
        sys.ps2 = '%s ' % ('.' * 8)

Term.setup_prompt()


if PY < 3:
    try:
        import rlcompleter
        if 'libedit' in rlcompleter.readline.__doc__:
            rlcompleter.readline.parse_and_bind('bind ^I rl_complete')
        else:
            rlcompleter.readline.parse_and_bind('tab: complete')
    except ImportError:
        print("Install readline for tab completion.")

print('')


def take(seq, count=1):
    queue = []
    for item in seq:
        queue.append(item)
        if len(queue) == count:
            yield tuple(queue)
            queue = []

    if queue:
        yield tuple(queue)


def pairs(seq):
    return take(seq, 2)


def enhex(seq):
    if isinstance(seq, str):
        seq = seq.encode('utf-8')
    return ' '.join(hex(b)[2:].zfill(2) for b in seq).upper()


def dehex(s, utf8=True):
    s = ''.join(s.lower().split())
    if not all(c in '0123456789abcdef' for c in s):
        raise ValueError('Not a hex string')
    byteseq = bytes(int(''.join(p), 16) for p in pairs(s))
    if utf8:
        try:
            return byteseq.decode('utf-8')
        except UnicodeDecodeError:
            pass
    return byteseq
