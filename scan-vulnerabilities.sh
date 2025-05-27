#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# SAGE OS — Copyright (c) 2025 Ashish Vasant Yesale (ashishyesale007@gmail.com)
# SPDX-License-Identifier: BSD-3-Clause OR Proprietary
# SAGE OS is dual-licensed under the BSD 3-Clause License and a Commercial License.
# 
# This file is part of the SAGE OS Project.
# ─────────────────────────────────────────────────────────────────────────────

# SAGE OS - CVE Vulnerability Scanner
# This script scans SAGE OS kernel images for known vulnerabilities using CVE-bin-tool

echo "🔍 SAGE OS CVE Vulnerability Scanner"
echo "===================================="

# Create reports directory
REPORTS_DIR="security-reports"
mkdir -p "$REPORTS_DIR"

# Check if CVE database exists and update it
echo "📥 Updating CVE database..."
if ! cve-bin-tool --update; then
    echo "⚠️  Failed to update CVE database, proceeding with existing data..."
fi

echo ""
echo "🔍 Scanning kernel images for vulnerabilities..."

# Scan all kernel images
SCAN_COUNT=0
VULNERABLE_COUNT=0

for arch in x86_64 aarch64 riscv64; do
    KERNEL_PATH="build/$arch/kernel.img"
    ELF_PATH="build/$arch/kernel.elf"
    
    if [ -f "$KERNEL_PATH" ]; then
        echo ""
        echo "🔍 Scanning $arch kernel image..."
        
        # Scan kernel image
        REPORT_FILE="$REPORTS_DIR/cve-report-$arch-kernel.json"
        if cve-bin-tool --format json --output-file "$REPORT_FILE" "$KERNEL_PATH"; then
            echo "✅ Scan completed for $arch kernel image"
            echo "   📄 Report saved: $REPORT_FILE"
        else
            echo "❌ Scan failed for $arch kernel image"
        fi
        
        # Scan ELF file if it exists
        if [ -f "$ELF_PATH" ]; then
            REPORT_ELF_FILE="$REPORTS_DIR/cve-report-$arch-elf.json"
            if cve-bin-tool --format json --output-file "$REPORT_ELF_FILE" "$ELF_PATH"; then
                echo "✅ Scan completed for $arch ELF file"
                echo "   📄 Report saved: $REPORT_ELF_FILE"
            else
                echo "❌ Scan failed for $arch ELF file"
            fi
        fi
        
        ((SCAN_COUNT++))
    else
        echo "⚠️  Kernel image not found: $KERNEL_PATH"
    fi
done

# Scan ISO if it exists
ISO_PATH="build/x86_64/sageos.iso"
if [ -f "$ISO_PATH" ]; then
    echo ""
    echo "🔍 Scanning x86_64 ISO image..."
    
    REPORT_ISO_FILE="$REPORTS_DIR/cve-report-x86_64-iso.json"
    if cve-bin-tool --format json --output-file "$REPORT_ISO_FILE" "$ISO_PATH"; then
        echo "✅ Scan completed for x86_64 ISO image"
        echo "   📄 Report saved: $REPORT_ISO_FILE"
    else
        echo "❌ Scan failed for x86_64 ISO image"
    fi
    ((SCAN_COUNT++))
fi

# Scan build output directory
if [ -d "build-output" ]; then
    echo ""
    echo "🔍 Scanning build output directory..."
    
    REPORT_OUTPUT_FILE="$REPORTS_DIR/cve-report-build-output.json"
    if cve-bin-tool --format json --output-file "$REPORT_OUTPUT_FILE" "build-output/"; then
        echo "✅ Scan completed for build output directory"
        echo "   📄 Report saved: $REPORT_OUTPUT_FILE"
    else
        echo "❌ Scan failed for build output directory"
    fi
    ((SCAN_COUNT++))
fi

echo ""
echo "📊 Vulnerability Scan Summary:"
echo "=============================="
echo "Files scanned: $SCAN_COUNT"
echo "Reports generated: $(ls -1 $REPORTS_DIR/*.json 2>/dev/null | wc -l)"

# Generate summary report
echo ""
echo "📋 Generating summary report..."
SUMMARY_FILE="$REPORTS_DIR/vulnerability-summary.txt"

{
    echo "SAGE OS Vulnerability Scan Summary"
    echo "=================================="
    echo "Scan Date: $(date)"
    echo "CVE-bin-tool Version: $(cve-bin-tool --version 2>/dev/null || echo 'Unknown')"
    echo ""
    
    echo "Scanned Files:"
    echo "=============="
    for arch in x86_64 aarch64 riscv64; do
        if [ -f "build/$arch/kernel.img" ]; then
            echo "- $arch kernel image: $(ls -lh build/$arch/kernel.img | awk '{print $5}')"
        fi
        if [ -f "build/$arch/kernel.elf" ]; then
            echo "- $arch ELF file: $(ls -lh build/$arch/kernel.elf | awk '{print $5}')"
        fi
    done
    if [ -f "$ISO_PATH" ]; then
        echo "- x86_64 ISO image: $(ls -lh $ISO_PATH | awk '{print $5}')"
    fi
    
    echo ""
    echo "Generated Reports:"
    echo "=================="
    ls -la "$REPORTS_DIR"/*.json 2>/dev/null || echo "No JSON reports found"
    
} > "$SUMMARY_FILE"

echo "✅ Summary report saved: $SUMMARY_FILE"

# Check for vulnerabilities in reports
echo ""
echo "🔍 Checking for vulnerabilities in reports..."

TOTAL_VULNERABILITIES=0
for report in "$REPORTS_DIR"/*.json; do
    if [ -f "$report" ]; then
        # Count vulnerabilities in JSON report
        VULN_COUNT=$(python3 -c "
import json
import sys
try:
    with open('$report', 'r') as f:
        data = json.load(f)
    # Count vulnerabilities - structure may vary
    if isinstance(data, dict):
        if 'vulnerabilities' in data:
            print(len(data['vulnerabilities']))
        elif 'cves' in data:
            print(len(data['cves']))
        else:
            print(0)
    else:
        print(0)
except:
    print(0)
" 2>/dev/null || echo "0")
        
        if [ "$VULN_COUNT" -gt 0 ]; then
            echo "⚠️  Found $VULN_COUNT vulnerabilities in $(basename "$report")"
            ((TOTAL_VULNERABILITIES += VULN_COUNT))
        else
            echo "✅ No vulnerabilities found in $(basename "$report")"
        fi
    fi
done

echo ""
if [ "$TOTAL_VULNERABILITIES" -eq 0 ]; then
    echo "🎉 No vulnerabilities detected in SAGE OS kernel images!"
    echo "✅ All scanned files appear to be clean."
else
    echo "⚠️  Total vulnerabilities found: $TOTAL_VULNERABILITIES"
    echo "📋 Please review the detailed reports in: $REPORTS_DIR/"
fi

echo ""
echo "📁 All reports saved in: $REPORTS_DIR/"
ls -la "$REPORTS_DIR/"

echo ""
echo "🔍 CVE vulnerability scan completed!"