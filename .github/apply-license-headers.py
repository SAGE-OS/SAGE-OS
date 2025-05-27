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
    '.c': 'c-style.txt',
    '.h': 'c-style.txt',
    '.cpp': 'cpp-style.txt',
    '.cxx': 'cpp-style.txt',
    '.cc': 'cpp-style.txt',
    '.hpp': 'cpp-style.txt',
    '.hxx': 'cpp-style.txt',
    '.hh': 'cpp-style.txt',
    
    # Assembly
    '.s': 'assembly-style.txt',
    '.S': 'assembly-style.txt',
    '.asm': 'assembly-style.txt',
    
    # Python
    '.py': 'python-style.txt',
    '.pyx': 'python-style.txt',
    '.pxd': 'python-style.txt',
    '.pyi': 'python-style.txt',
    
    # Ruby
    '.rb': 'ruby-style.txt',
    '.rbw': 'ruby-style.txt',
    '.rake': 'ruby-style.txt',
    '.gemspec': 'ruby-style.txt',
    
    # Rust
    '.rs': 'rust-style.txt',
    
    # JavaScript/TypeScript
    '.js': 'javascript-style.txt',
    '.jsx': 'javascript-style.txt',
    '.ts': 'typescript-style.txt',
    '.tsx': 'typescript-style.txt',
    '.mjs': 'javascript-style.txt',
    '.cjs': 'javascript-style.txt',
    
    # Java/Kotlin/Scala
    '.java': 'java-style.txt',
    '.kt': 'kotlin-style.txt',
    '.kts': 'kotlin-style.txt',
    '.scala': 'scala-style.txt',
    '.sc': 'scala-style.txt',
    
    # Go
    '.go': 'go-style.txt',
    
    # Shell scripts
    '.sh': 'hash-style.txt',
    '.bash': 'hash-style.txt',
    '.zsh': 'hash-style.txt',
    '.fish': 'hash-style.txt',
    '.ksh': 'hash-style.txt',
    '.csh': 'hash-style.txt',
    '.tcsh': 'hash-style.txt',
    
    # Configuration files with hash comments
    '.yml': 'yaml-style.txt',
    '.yaml': 'yaml-style.txt',
    '.toml': 'toml-style.txt',
    '.ini': 'ini-style.txt',
    '.cfg': 'ini-style.txt',
    '.conf': 'hash-style.txt',
    
    # Makefile
    'Makefile': 'makefile-style.txt',
    'makefile': 'makefile-style.txt',
    '.mk': 'makefile-style.txt',
    
    # Docker
    'Dockerfile': 'dockerfile-style.txt',
    '.dockerfile': 'dockerfile-style.txt',
    
    # Other languages
    '.php': 'php-style.txt',
    '.swift': 'swift-style.txt',
    '.m': 'c-style.txt',
    '.mm': 'cpp-style.txt',
    '.cs': 'csharp-style.txt',
    '.fs': 'c-style.txt',
    '.fsx': 'c-style.txt',
    '.vb': 'c-style.txt',
    '.pas': 'pascal-style.txt',
    '.pp': 'c-style.txt',
    '.d': 'c-style.txt',
    '.dart': 'dart-style.txt',
    '.zig': 'c-style.txt',
    '.nim': 'hash-style.txt',
    '.cr': 'hash-style.txt',
    '.jl': 'hash-style.txt',
    '.r': 'r-style.txt',
    '.R': 'r-style.txt',
    '.pl': 'perl-style.txt',
    '.pm': 'perl-style.txt',
    '.lua': 'lua-style.txt',
    '.tcl': 'hash-style.txt',
    '.elm': 'elm-style.txt',
    '.ex': 'elixir-style.txt',
    '.exs': 'elixir-style.txt',
    '.erl': 'erlang-style.txt',
    '.hrl': 'erlang-style.txt',
    '.clj': 'clojure-style.txt',
    '.cljs': 'clojure-style.txt',
    '.cljc': 'clojure-style.txt',
    '.hs': 'haskell-style.txt',
    '.lhs': 'haskell-style.txt',
    '.ml': 'c-style.txt',
    '.mli': 'c-style.txt',
    '.v': 'c-style.txt',
    '.sv': 'c-style.txt',
    '.vhd': 'c-style.txt',
    '.vhdl': 'c-style.txt',
    '.html': 'html-style.txt',
    '.xml': 'xml-style.txt',
    '.css': 'css-style.txt',
    '.scss': 'scss-style.txt',
    '.sql': 'sql-style.txt',
    '.md': 'markdown-style.txt',
    '.tex': 'latex-style.txt',
    '.vim': 'vim-style.txt',
    '.tf': 'terraform-style.txt',
    '.nix': 'nix-style.txt',
    '.cmake': 'cmake-style.txt',
    '.gradle': 'gradle-style.txt',
    '.groovy': 'groovy-style.txt',
    '.ps1': 'powershell-style.txt',
    '.bat': 'batch-style.txt',
    '.cmd': 'batch-style.txt',
    '.ada': 'ada-style.txt',
    '.adb': 'ada-style.txt',
    '.ads': 'ada-style.txt',
    '.f90': 'fortran-style.txt',
    '.f95': 'fortran-style.txt',
    '.f03': 'fortran-style.txt',
    '.f08': 'fortran-style.txt',
    '.for': 'fortran-style.txt',
    '.ftn': 'fortran-style.txt',
    '.m': 'matlab-style.txt',
    '.json': 'json-style.txt',
    '.properties': 'properties-style.txt',
    '.txt': 'text-style.txt',
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
        templates = list(template_dir.glob('*-style.txt'))
        print(f"Found {len(templates)} license templates:")
        for template in templates:
            print(f"  - {template.name}")
    else:
        print("Template directory not found")
    
    return 0

if __name__ == '__main__':
    sys.exit(main())