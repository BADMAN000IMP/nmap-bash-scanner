#!/bin/bash

echo "===== Simple Nmap Bash Scanner ====="
read -p "Enter the target IP or domain: " target

# Clean target name for filenames
safe_target=$(echo "$target" | tr -cd '[:alnum:]._-')
timestamp=$(date +%Y%m%d_%H%M%S)

# Create folders if not present
mkdir -p results reports logs

filename="results/${safe_target}_scan_${timestamp}.txt"
xmlfile="reports/${safe_target}_scan_${timestamp}.xml"
htmlfile="reports/${safe_target}_scan_${timestamp}.html"
logfile="logs/scan_errors.log"

{
  echo "Target: $target"
  echo "Started at: $(date)"
  echo ""

  echo "=== Ping Scan ==="
  nmap -sn "$target"

  echo ""
  echo "=== Full Port Scan ==="
  nmap -p- "$target"

  echo ""
  echo "=== OS Detection & Service Versions ==="
  nmap -A "$target"
} | tee "$filename" 2>>"$logfile"

echo -e "\nGenerating XML report..."
nmap -A -oX "$xmlfile" "$target" >> "$filename" 2>>"$logfile"

echo "Converting to HTML..."
xsltproc "$xmlfile" -o "$htmlfile"

echo -e "\n✅ Scan complete!"
echo "📄 Text Result: $filename"
echo "🌐 HTML Report: $htmlfile"
echo "📝 Error Log: $logfile"

