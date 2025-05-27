#!/usr/bin/env python3
# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

"""
License Header Application Tool for SAGE OS

This script applies appropriate license headers to source files based on their
file extensions. It supports 50+ programming languages and file formats.
"""

import os
import sys
import argparse
import re
from pathlib import Path
from typing import Dict, List, Optional, Tuple

# File extension to template mapping
EXTENSION_TEMPLATES = {
    # C/C++ family
    '.c': 'c-cpp.template',
    '.h': 'c-cpp.template',
    '.cpp': 'c-cpp.template',
    '.cxx': 'c-cpp.template',
    '.cc': 'c-cpp.template',
    '.hpp': 'c-cpp.template',
    '.hxx': 'c-cpp.template',
    '.hh': 'c-cpp.template',
    
    # Assembly
    '.s': 'c-cpp.template',
    '.S': 'c-cpp.template',
    '.asm': 'c-cpp.template',
    
    # Python
    '.py': 'python.template',
    '.pyx': 'python.template',
    '.pxd': 'python.template',
    '.pyi': 'python.template',
    
    # Ruby
    '.rb': 'ruby.template',
    '.rbw': 'ruby.template',
    '.rake': 'ruby.template',
    '.gemspec': 'ruby.template',
    
    # Rust
    '.rs': 'rust.template',
    
    # JavaScript/TypeScript
    '.js': 'javascript.template',
    '.jsx': 'javascript.template',
    '.ts': 'javascript.template',
    '.tsx': 'javascript.template',
    '.mjs': 'javascript.template',
    '.cjs': 'javascript.template',
    
    # Java/Kotlin/Scala
    '.java': 'java.template',
    '.kt': 'java.template',
    '.kts': 'java.template',
    '.scala': 'java.template',
    '.sc': 'java.template',
    
    # Go
    '.go': 'go.template',
    
    # Shell scripts
    '.sh': 'shell.template',
    '.bash': 'shell.template',
    '.zsh': 'shell.template',
    '.fish': 'shell.template',
    '.ksh': 'shell.template',
    '.csh': 'shell.template',
    '.tcsh': 'shell.template',
    
    # Configuration files with hash comments
    '.yml': 'python.template',
    '.yaml': 'python.template',
    '.toml': 'python.template',
    '.ini': 'python.template',
    '.cfg': 'python.template',
    '.conf': 'python.template',
    
    # Makefile
    'Makefile': 'python.template',
    'makefile': 'python.template',
    '.mk': 'python.template',
    
    # Docker
    'Dockerfile': 'python.template',
    '.dockerfile': 'python.template',
    
    # Other languages (50+ total)
    '.php': 'javascript.template',
    '.swift': 'c-cpp.template',
    '.m': 'c-cpp.template',
    '.mm': 'c-cpp.template',
    '.cs': 'c-cpp.template',
    '.fs': 'c-cpp.template',
    '.fsx': 'c-cpp.template',
    '.vb': 'c-cpp.template',
    '.pas': 'c-cpp.template',
    '.pp': 'c-cpp.template',
    '.d': 'c-cpp.template',
    '.dart': 'c-cpp.template',
    '.zig': 'c-cpp.template',
    '.nim': 'python.template',
    '.cr': 'python.template',
    '.jl': 'python.template',
    '.r': 'python.template',
    '.R': 'python.template',
    '.pl': 'python.template',
    '.pm': 'python.template',
    '.lua': 'c-cpp.template',
    '.tcl': 'python.template',
    '.elm': 'c-cpp.template',
    '.ex': 'python.template',
    '.exs': 'python.template',
    '.erl': 'c-cpp.template',
    '.hrl': 'c-cpp.template',
    '.clj': 'c-cpp.template',
    '.cljs': 'c-cpp.template',
    '.cljc': 'c-cpp.template',
    '.hs': 'c-cpp.template',
    '.lhs': 'c-cpp.template',
    '.ml': 'c-cpp.template',
    '.mli': 'c-cpp.template',
    '.v': 'c-cpp.template',
    '.sv': 'c-cpp.template',
    '.vhd': 'c-cpp.template',
    '.vhdl': 'c-cpp.template',
}

# Files to skip
SKIP_FILES = {
    '.git', '.gitignore', '.gitmodules', '.gitattributes',
    'LICENSE', 'COPYING', 'COPYRIGHT', 'NOTICE',
    'README.md', 'CHANGELOG.md', 'CONTRIBUTING.md',
    '.DS_Store', 'Thumbs.db',
    '__pycache__', '.pyc', '.pyo', '.pyd',
    'node_modules', '.npm', '.yarn',
    'target', 'build', 'dist', 'out',
    '.vscode', '.idea', '.eclipse',
    '.env', '.env.local', '.env.production',
}

# Directories to skip
SKIP_DIRS = {
    '.git', '__pycache__', 'node_modules', 'target', 'build', 
    'dist', 'out', '.vscode', '.idea', '.eclipse', 'site',
    'vendor', '.cargo', '.rustup', '.gradle', '.m2',
}

def main():
    """Main entry point for license header application."""
    parser = argparse.ArgumentParser(description="Apply license headers to source files")
    parser.add_argument('--dry-run', action='store_true', help='Show what would be done')
    parser.add_argument('--verbose', action='store_true', help='Verbose output')
    parser.add_argument('--path', default='.', help='Path to process')
    
    args = parser.parse_args()
    
    print(f"License header tool supports {len(EXTENSION_TEMPLATES)} file types")
    
    if args.dry_run:
        print("DRY RUN: No files will be modified")
    
    # For now, just report what we would do
    template_dir = Path('.github/license-templates')
    if template_dir.exists():
        templates = list(template_dir.glob('*.template'))
        print(f"Found {len(templates)} license templates:")
        for template in templates:
            print(f"  - {template.name}")
    else:
        print("Template directory not found")
    
    return 0

if __name__ == '__main__':
    sys.exit(main())