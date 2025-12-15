#!/usr/bin/env python3
"""
Script to fix Flutter analyze errors for GitHub Pages deployment
"""
import re
import sys
from pathlib import Path

def replace_with_opacity(file_path):
    """Replace withOpacity() with withValues(alpha:)"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Replace .withOpacity(X) with .withValues(alpha: X)
    pattern = r'\.withOpacity\(([0-9.]+)\)'
    replacement = r'.withValues(alpha: \1)'
    new_content = re.sub(pattern, replacement, content)
    
    if new_content != content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        return True
    return False

def fix_curly_braces(file_path):
    """Add curly braces to single-line for loops"""
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    modified = False
    new_lines = []
    i = 0
    while i < len(lines):
        line = lines[i]
        # Check if it's a for loop without braces
        if re.match(r'\s*for\s*\([^)]+\)\s+[^{]', line):
            # Extract indentation
            indent = len(line) - len(line.lstrip())
            # Split the for loop and the statement
            match = re.match(r'(\s*for\s*\([^)]+\))\s+(.+)', line)
            if match:
                for_part = match.group(1)
                statement = match.group(2)
                # Reconstruct with braces
                new_lines.append(for_part + ' {\n')
                new_lines.append(' ' * (indent + 2) + statement)
                new_lines.append(' ' * indent + '}\n')
                modified = True
                i += 1
                continue
        new_lines.append(line)
        i += 1
    
    if modified:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.writelines(new_lines)
    return modified

def main():
    base_dir = Path(r'c:\Users\Melih\Desktop\bodyecho\lib')
    
    files_to_fix = [
        'features/profile/views/profile_screen.dart',
        'features/trends/views/trends_screen.dart',
        'widgets/body_risk_map_widget.dart',
        'widgets/points_toast_widget.dart',
        'features/nutrition/views/calorie_tracking_screen.dart',
    ]
    
    for file_rel in files_to_fix:
        file_path = base_dir / file_rel
        if file_path.exists():
            if replace_with_opacity(file_path):
                print(f'Fixed withOpacity in {file_rel}')
            if fix_curly_braces(file_path):
                print(f'Fixed curly braces in {file_rel}')
    
    print('Done!')

if __name__ == '__main__':
    main()
