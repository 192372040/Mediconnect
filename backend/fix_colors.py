import re
import os
import glob

def fix_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Skip if it already has the getters (partially handled)
    # But wait, PatientDashboardScreen already has some getters, so we should allow it to just update.

    getters = """
  Color get primaryBg => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2C2A2A) : Colors.white;
  Color get cardBg => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1A1A1A) : Colors.grey.shade50;
  Color get borderColor => Theme.of(context).brightness == Brightness.dark ? const Color(0xFF3A3A3A) : Colors.grey.shade200;
  Color get textColor => Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87;
  Color get textLightColor => Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54;
  Color get textDimColor => Theme.of(context).brightness == Brightness.dark ? Colors.white54 : Colors.grey.shade600;
  Color get textMutedColor => Theme.of(context).brightness == Brightness.dark ? Colors.white38 : Colors.grey.shade400;
  Color get white24Color => Theme.of(context).brightness == Brightness.dark ? Colors.white24 : Colors.black12;
"""

    if 'Color get primaryBg' not in content and 'static const Color primaryBg' in content:
        content = content.replace('  static const Color primaryBg = Color(0xFF2C2A2A);', getters)
        content = content.replace('  static const Color cardBg = Color(0xFF1A1A1A);', '')
        content = content.replace('  static const Color borderColor = Color(0xFF3A3A3A);', '')

    # Specific fixes
    content = re.sub(r'color:\s*Colors\.white([^0-9])', r'color: textColor\1', content)
    content = content.replace('color: Colors.white70', 'color: textLightColor')
    content = content.replace('color: Colors.white54', 'color: textDimColor')
    content = content.replace('color: Colors.white38', 'color: textMutedColor')
    content = content.replace('color: Colors.white24', 'color: white24Color')
    
    # Remove consts to prevent Invalid constant value errors
    content = content.replace('const ', '')

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Fixed", filepath)

files_to_fix = [
    'lib/Patientdashboard/AppointmentsScreen.dart',
    'lib/Patientdashboard/health/HealthScreen.dart',
]

for f in files_to_fix:
    if os.path.exists(f):
        fix_file(f)
