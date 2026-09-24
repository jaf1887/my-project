#!/usr/bin/env python3
"""Defer four reviewed SUSFS 50 header hunks to the pinned Samsung 51 patch.

Evidence: Run130 run 36035029506, artifact jaf-run130-experimental-2.
No failed patch is accepted and no reject file is removed. The original patches
remain intact; the generated 50 patch must apply before 51 is attempted.
"""
import hashlib
from pathlib import Path
import re
import sys


def prepare(upstream: bytes, samsung: bytes) -> bytes:
    expected = (
        (upstream, 'd5d7ebf934ed1478873bb4651bdef97ff6b16a3911b5bc8c9ab47d9f72d097d5'),
        (samsung, '35bbe7e0639e33043f7e3d0b1a57674fef055b5e662a618342a99ea4269ba367'),
    )
    for content, digest in expected:
        if hashlib.sha256(content).hexdigest() != digest:
            raise ValueError('SUSFS patch differs from the reviewed Run130 input')
    targets = {'fs/exec.c', 'fs/namespace.c', 'fs/proc/base.c', 'fs/proc/task_mmu.c'}
    seen = set()
    result = []
    for section in re.split(r'(?=^diff --git )', upstream.decode(), flags=re.M):
        match = re.match(r'diff --git a/(\S+) b/(\S+)\n', section)
        if match and match[1] in targets:
            if match[1] != match[2] or match[1] in seen:
                raise ValueError('Unexpected SUSFS patch layout')
            hunks = list(re.finditer(r'^@@ .*$', section, flags=re.M))
            if len(hunks) < 2:
                raise ValueError('Expected header hunk followed by functional hooks')
            section = section[:hunks[0].start()] + section[hunks[1].start():]
            seen.add(match[1])
        result.append(section)
    if seen != targets:
        raise ValueError('Missing reviewed SUSFS header hunks')
    return ''.join(result).encode()


if __name__ == '__main__':
    if len(sys.argv) != 4:
        sys.exit('Usage: prepare-run130-susfs.py UPSTREAM_50 SAMSUNG_51 OUTPUT_50')
    try:
        result = prepare(Path(sys.argv[1]).read_bytes(), Path(sys.argv[2]).read_bytes())
    except ValueError as error:
        sys.exit(f'STOP: {error}')
    Path(sys.argv[3]).write_bytes(result)
    print('Deferred four reviewed header hunks to pinned Samsung SUSFS 51 patch.')
