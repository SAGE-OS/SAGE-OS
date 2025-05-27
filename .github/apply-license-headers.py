#!/usr/bin/env python3
"""
SAGE OS License Header Application Tool
Automatically applies license headers to source files based on file extensions.
"""

import os
import sys
import argparse
import glob
from pathlib import Path

# File extension to template mapping
EXTENSION_MAPPING = {
    '.c': 'c-style.txt',
    '.h': 'c-style.txt',
    '.cpp': 'cpp-style.txt',
    '.cxx': 'cpp-style.txt',
    '.cc': 'cpp-style.txt',
    '.hpp': 'cpp-style.txt',
    '.hxx': 'cpp-style.txt',
    '.java': 'java-style.txt',
    '.js': 'javascript-style.txt',
    '.ts': 'typescript-style.txt',
    '.cs': 'csharp-style.txt',
    '.go': 'go-style.txt',
    '.rs': 'rust-style.txt',
    '.swift': 'swift-style.txt',
    '.kt': 'kotlin-style.txt',
    '.scala': 'scala-style.txt',
    '.dart': 'dart-style.txt',
    '.php': 'php-style.txt',
    '.py': 'python-style.txt',
    '.rb': 'ruby-style.txt',
    '.pl': 'perl-style.txt',
    '.sh': 'hash-style.txt',
    '.bash': 'hash-style.txt',
    '.zsh': 'hash-style.txt',
    '.fish': 'hash-style.txt',
    '.yml': 'yaml-style.txt',
    '.yaml': 'yaml-style.txt',
    '.toml': 'toml-style.txt',
    '.ini': 'ini-style.txt',
    '.cfg': 'ini-style.txt',
    '.conf': 'hash-style.txt',
    '.properties': 'properties-style.txt',
    '.ps1': 'powershell-style.txt',
    '.r': 'r-style.txt',
    '.R': 'r-style.txt',
    '.bat': 'batch-style.txt',
    '.cmd': 'batch-style.txt',
    '.sql': 'sql-style.txt',
    '.lua': 'lua-style.txt',
    '.hs': 'haskell-style.txt',
    '.ada': 'ada-style.txt',
    '.adb': 'ada-style.txt',
    '.ads': 'ada-style.txt',
    '.f': 'fortran-style.txt',
    '.f90': 'fortran-style.txt',
    '.f95': 'fortran-style.txt',
    '.f03': 'fortran-style.txt',
    '.f08': 'fortran-style.txt',
    '.m': 'matlab-style.txt',
    '.tex': 'latex-style.txt',
    '.html': 'html-style.txt',
    '.htm': 'html-style.txt',
    '.xml': 'xml-style.txt',
    '.css': 'css-style.txt',
    '.scss': 'scss-style.txt',
    '.sass': 'scss-style.txt',
    '.md': 'markdown-style.txt',
    '.markdown': 'markdown-style.txt',
    '.txt': 'text-style.txt',
    '.vim': 'vim-style.txt',
    '.lisp': 'lisp-style.txt',
    '.lsp': 'lisp-style.txt',
    '.clj': 'clojure-style.txt',
    '.cljs': 'clojure-style.txt',
    '.erl': 'erlang-style.txt',
    '.hrl': 'erlang-style.txt',
    '.ex': 'elixir-style.txt',
    '.exs': 'elixir-style.txt',
    '.dockerfile': 'dockerfile-style.txt',
    '.cmake': 'cmake-style.txt',
    '.gradle': 'gradle-style.txt',
    '.groovy': 'groovy-style.txt',
    '.tf': 'terraform-style.txt',
    '.nix': 'nix-style.txt',
    '.pas': 'pascal-style.txt',
    '.pp': 'pascal-style.txt',
    '.s': 'assembly-style.txt',
    '.S': 'assembly-style.txt',
    '.asm': 'assembly-style.txt',
}

# Files to skip (no license headers needed)
SKIP_FILES = {
    '.gitignore',
    '.gitmodules',
    'LICENSE',
    'COPYING',
    'README.md',
    'CHANGELOG.md',
    'CONTRIBUTING.md',
    'CODE_OF_CONDUCT.md',
    'SECURITY.md',
    'MANIFEST.in',
    'setup.py',
    'setup.cfg',
    'pyproject.toml',
    'requirements.txt',
    'package.json',
    'package-lock.json',
    'yarn.lock',
    'Cargo.toml',
    'Cargo.lock',
    'go.mod',
    'go.sum',
}

# Directories to skip
SKIP_DIRS = {
    '.git',
    '.github',
    'node_modules',
    '__pycache__',
    '.pytest_cache',
    'build',
    'dist',
    'target',
    '.vscode',
    '.idea',
    'venv',
    'env',
    '.env',
}

def has_license_header(file_path):
    """Check if a file already has a license header."""
    try:
        with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read(1000)  # Read first 1000 characters
            return 'SAGE OS' in content and 'Copyright' in content
    except Exception:
        return False

def get_license_template(template_name):
    """Load license template from file."""
    template_path = Path(__file__).parent / 'license-templates' / template_name
    
    if not template_path.exists():
        print(f"Warning: Template {template_name} not found")
        return None
    
    try:
        with open(template_path, 'r', encoding='utf-8') as f:
            return f.read()
    except Exception as e:
        print(f"Error reading template {template_name}: {e}")
        return None

def apply_license_header(file_path, dry_run=False):
    """Apply license header to a file."""
    file_ext = Path(file_path).suffix.lower()
    
    if file_ext not in EXTENSION_MAPPING:
        return False
    
    if has_license_header(file_path):
        return False
    
    template_name = EXTENSION_MAPPING[file_ext]
    license_header = get_license_template(template_name)
    
    if not license_header:
        return False
    
    if dry_run:
        print(f"Would add license header to: {file_path}")
        return True
    
    try:
        # Read existing content
        with open(file_path, 'r', encoding='utf-8') as f:
            existing_content = f.read()
        
        # Handle shebang lines
        lines = existing_content.split('\n')
        shebang = ''
        content_start = 0
        
        if lines and lines[0].startswith('#!'):
            shebang = lines[0] + '\n'
            content_start = 1
            # Skip empty lines after shebang
            while content_start < len(lines) and not lines[content_start].strip():
                content_start += 1
        
        remaining_content = '\n'.join(lines[content_start:])
        
        # Combine shebang, license header, and existing content
        new_content = shebang
        if shebang:
            new_content += '\n'
        new_content += license_header
        if remaining_content.strip():
            new_content += '\n\n' + remaining_content
        
        # Write back to file
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        
        print(f"Added license header to: {file_path}")
        return True
        
    except Exception as e:
        print(f"Error processing {file_path}: {e}")
        return False

def find_source_files(root_dir):
    """Find all source files that need license headers."""
    source_files = []
    
    for root, dirs, files in os.walk(root_dir):
        # Skip certain directories
        dirs[:] = [d for d in dirs if d not in SKIP_DIRS]
        
        for file in files:
            if file in SKIP_FILES:
                continue
            
            file_path = os.path.join(root, file)
            file_ext = Path(file).suffix.lower()
            
            if file_ext in EXTENSION_MAPPING:
                source_files.append(file_path)
    
    return source_files

def main():
    parser = argparse.ArgumentParser(description="Apply license headers to SAGE OS source files")
    parser.add_argument("--dry-run", action="store_true", 
                       help="Show what would be done without making changes")
    parser.add_argument("--directory", default=".", 
                       help="Directory to process (default: current directory)")
    
    args = parser.parse_args()
    
    if not os.path.exists(args.directory):
        print(f"Error: Directory {args.directory} does not exist")
        sys.exit(1)
    
    # Find all source files
    source_files = find_source_files(args.directory)
    
    if not source_files:
        print("No source files found that need license headers")
        return
    
    print(f"Found {len(source_files)} source files")
    
    # Process files
    processed_count = 0
    for file_path in source_files:
        if apply_license_header(file_path, args.dry_run):
            processed_count += 1
    
    if args.dry_run:
        print(f"\nDry run complete. Would process {processed_count} files.")
    else:
        print(f"\nProcessed {processed_count} files.")

if __name__ == "__main__":
    main()