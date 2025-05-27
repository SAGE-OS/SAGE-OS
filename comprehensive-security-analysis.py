#!/usr/bin/env python3
"""
SAGE OS Comprehensive Security Analysis Tool
Analyzes the codebase for common security vulnerabilities
"""

import os
import re
import json
import subprocess
from pathlib import Path
from datetime import datetime

class SecurityAnalyzer:
    def __init__(self, project_root):
        self.project_root = Path(project_root)
        self.vulnerabilities = []
        self.security_issues = {
            'critical': [],
            'high': [],
            'medium': [],
            'low': [],
            'info': []
        }
        
    def analyze_buffer_overflows(self, file_path, content):
        """Check for potential buffer overflow vulnerabilities"""
        issues = []
        dangerous_functions = [
            'strcpy', 'strcat', 'sprintf', 'gets', 'scanf',
            'strncpy', 'strncat', 'snprintf'
        ]
        
        for line_num, line in enumerate(content.split('\n'), 1):
            for func in dangerous_functions:
                if func in line and not line.strip().startswith('//'):
                    issues.append({
                        'type': 'Buffer Overflow Risk',
                        'severity': 'high' if func in ['strcpy', 'strcat', 'gets'] else 'medium',
                        'file': str(file_path),
                        'line': line_num,
                        'description': f'Use of potentially unsafe function: {func}',
                        'code': line.strip()
                    })
        return issues
    
    def analyze_memory_management(self, file_path, content):
        """Check for memory management issues"""
        issues = []
        lines = content.split('\n')
        
        malloc_lines = []
        free_lines = []
        
        for line_num, line in enumerate(lines, 1):
            if 'malloc(' in line or 'calloc(' in line or 'realloc(' in line:
                malloc_lines.append((line_num, line.strip()))
            if 'free(' in line:
                free_lines.append((line_num, line.strip()))
                
        # Simple heuristic: if more mallocs than frees, potential memory leak
        if len(malloc_lines) > len(free_lines):
            issues.append({
                'type': 'Memory Leak Risk',
                'severity': 'medium',
                'file': str(file_path),
                'line': 0,
                'description': f'Potential memory leak: {len(malloc_lines)} allocations vs {len(free_lines)} frees',
                'code': f'malloc calls: {len(malloc_lines)}, free calls: {len(free_lines)}'
            })
            
        return issues
    
    def analyze_input_validation(self, file_path, content):
        """Check for input validation issues"""
        issues = []
        
        # Check for direct user input usage without validation
        risky_patterns = [
            (r'scanf\s*\([^)]*\)', 'Unsafe input reading with scanf'),
            (r'gets\s*\([^)]*\)', 'Extremely unsafe gets() function'),
            (r'system\s*\([^)]*\)', 'Potential command injection with system()'),
        ]
        
        for line_num, line in enumerate(content.split('\n'), 1):
            for pattern, desc in risky_patterns:
                if re.search(pattern, line) and not line.strip().startswith('//'):
                    issues.append({
                        'type': 'Input Validation',
                        'severity': 'high',
                        'file': str(file_path),
                        'line': line_num,
                        'description': desc,
                        'code': line.strip()
                    })
        return issues
    
    def analyze_privilege_escalation(self, file_path, content):
        """Check for potential privilege escalation issues"""
        issues = []
        
        # Check for setuid/setgid usage
        privilege_patterns = [
            (r'setuid\s*\(', 'setuid usage - potential privilege escalation'),
            (r'setgid\s*\(', 'setgid usage - potential privilege escalation'),
            (r'seteuid\s*\(', 'seteuid usage - check for proper validation'),
        ]
        
        for line_num, line in enumerate(content.split('\n'), 1):
            for pattern, desc in privilege_patterns:
                if re.search(pattern, line) and not line.strip().startswith('//'):
                    issues.append({
                        'type': 'Privilege Escalation Risk',
                        'severity': 'critical',
                        'file': str(file_path),
                        'line': line_num,
                        'description': desc,
                        'code': line.strip()
                    })
        return issues
    
    def analyze_assembly_security(self, file_path, content):
        """Check assembly files for security issues"""
        issues = []
        
        # Check for stack manipulation without proper bounds checking
        asm_patterns = [
            (r'mov\s+%esp', 'Direct stack pointer manipulation'),
            (r'jmp\s+\*', 'Indirect jump - potential ROP gadget'),
            (r'call\s+\*', 'Indirect call - potential security risk'),
        ]
        
        for line_num, line in enumerate(content.split('\n'), 1):
            for pattern, desc in asm_patterns:
                if re.search(pattern, line, re.IGNORECASE) and not line.strip().startswith('#'):
                    issues.append({
                        'type': 'Assembly Security',
                        'severity': 'medium',
                        'file': str(file_path),
                        'line': line_num,
                        'description': desc,
                        'code': line.strip()
                    })
        return issues
    
    def analyze_file(self, file_path):
        """Analyze a single file for security issues"""
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
        except Exception as e:
            return []
        
        issues = []
        
        # Run different analyzers based on file type
        if file_path.suffix in ['.c', '.h']:
            issues.extend(self.analyze_buffer_overflows(file_path, content))
            issues.extend(self.analyze_memory_management(file_path, content))
            issues.extend(self.analyze_input_validation(file_path, content))
            issues.extend(self.analyze_privilege_escalation(file_path, content))
        elif file_path.suffix in ['.S', '.s']:
            issues.extend(self.analyze_assembly_security(file_path, content))
            
        return issues
    
    def scan_project(self):
        """Scan the entire project for security issues"""
        print("🔍 Starting comprehensive security analysis...")
        
        # File types to analyze
        file_patterns = ['**/*.c', '**/*.h', '**/*.S', '**/*.s']
        
        total_files = 0
        for pattern in file_patterns:
            for file_path in self.project_root.glob(pattern):
                if file_path.is_file():
                    total_files += 1
                    print(f"Analyzing: {file_path.relative_to(self.project_root)}")
                    issues = self.analyze_file(file_path)
                    
                    for issue in issues:
                        self.security_issues[issue['severity']].append(issue)
        
        print(f"\n✅ Analysis complete! Scanned {total_files} files.")
        return self.security_issues
    
    def generate_report(self):
        """Generate a comprehensive security report"""
        report = {
            'scan_date': datetime.now().isoformat(),
            'project': 'SAGE OS',
            'total_issues': sum(len(issues) for issues in self.security_issues.values()),
            'issues_by_severity': {
                severity: len(issues) for severity, issues in self.security_issues.items()
            },
            'detailed_findings': self.security_issues
        }
        
        # Save JSON report
        with open('security-analysis-report.json', 'w') as f:
            json.dump(report, f, indent=2)
        
        # Generate human-readable report
        self.generate_markdown_report(report)
        
        return report
    
    def generate_markdown_report(self, report):
        """Generate a markdown security report"""
        md_content = f"""# SAGE OS Security Analysis Report

**Scan Date:** {report['scan_date']}
**Total Issues Found:** {report['total_issues']}

## Summary by Severity

| Severity | Count |
|----------|-------|
| Critical | {report['issues_by_severity']['critical']} |
| High     | {report['issues_by_severity']['high']} |
| Medium   | {report['issues_by_severity']['medium']} |
| Low      | {report['issues_by_severity']['low']} |
| Info     | {report['issues_by_severity']['info']} |

## Detailed Findings

"""
        
        for severity in ['critical', 'high', 'medium', 'low', 'info']:
            issues = self.security_issues[severity]
            if issues:
                md_content += f"\n### {severity.upper()} Severity Issues ({len(issues)})\n\n"
                
                for i, issue in enumerate(issues, 1):
                    md_content += f"""#### {i}. {issue['type']}

**File:** `{issue['file']}`
**Line:** {issue['line']}
**Description:** {issue['description']}

```
{issue['code']}
```

---

"""
        
        md_content += """
## Recommendations

### Critical Issues
- Address all critical issues immediately
- Review privilege escalation risks
- Implement proper input validation

### High Priority
- Fix buffer overflow vulnerabilities
- Implement bounds checking
- Use safe string functions

### Medium Priority
- Review memory management
- Add proper error handling
- Implement security best practices

### Security Hardening
- Enable stack protection (-fstack-protector)
- Use ASLR (Address Space Layout Randomization)
- Implement DEP (Data Execution Prevention)
- Add security-focused compiler flags

## Next Steps

1. Review and fix critical and high severity issues
2. Implement automated security testing
3. Add security-focused unit tests
4. Regular security audits
5. Consider using static analysis tools like:
   - Clang Static Analyzer
   - Cppcheck
   - PVS-Studio
   - Coverity

"""
        
        with open('SECURITY_ANALYSIS_REPORT.md', 'w') as f:
            f.write(md_content)

def main():
    analyzer = SecurityAnalyzer('.')
    issues = analyzer.scan_project()
    report = analyzer.generate_report()
    
    print(f"\n📊 Security Analysis Summary:")
    print(f"   Critical: {len(issues['critical'])}")
    print(f"   High:     {len(issues['high'])}")
    print(f"   Medium:   {len(issues['medium'])}")
    print(f"   Low:      {len(issues['low'])}")
    print(f"   Info:     {len(issues['info'])}")
    print(f"\n📄 Reports generated:")
    print(f"   - security-analysis-report.json")
    print(f"   - SECURITY_ANALYSIS_REPORT.md")

if __name__ == "__main__":
    main()