import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_project/Patientdashboard/services/api_service.dart';
import 'package:my_project/LoginScreen.dart';
import 'package:my_project/main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const Color primary = Color(0xFF0F6E56);
  static const Color primaryBg = Color(0xFF2C2A2A);
  static const Color cardBg = Color(0xFF1A1A1A);
  static const Color borderColor = Color(0xFF3A3A3A);

  // ── Theme ─────────────────────────────────
  bool _isDarkMode = true;
  String _bgColor = 'Dark';
  String _language = 'English';

  // ── Profile ───────────────────────────────
  String _email = '';
  String _name = 'User';
  String _phone = '';
  int _age = 0;
  String _bloodGroup = 'B+';
  String _gender = 'Female';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _email = prefs.getString("user_email") ?? "";
      _name = prefs.getString("user_name") ?? "User";
      _phone = prefs.getString("phone") ?? "";
      _age = prefs.getInt("age") ?? 0;
      _bloodGroup = prefs.getString("blood_group") ?? "B+";
      _gender = prefs.getString("gender") ?? "Female";
      _language = prefs.getString("settings_language") ?? "English";
      _isDarkMode = prefs.getBool("dark_mode") ?? true;
      _bgColor = _isDarkMode ? 'Dark' : 'White';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkMode ? const Color(0xFF2C2A2A) : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSection('Account Settings', [
                    _buildTile(Icons.person_rounded, 'Edit profile',
                        onTap: () => _showEditProfile()),
                    _buildTile(Icons.phone_rounded, 'Change phone number',
                        onTap: () => _showChangePhone()),
                    _buildTile(Icons.language_rounded, 'Language',
                        trailing: _language,
                        onTap: () => _showLanguagePicker()),
                  ]),
                  const SizedBox(height: 16),
                  _buildSection('Appearance', [
                    _buildToggleTile(
                        Icons.dark_mode_rounded, 'Dark mode', _isDarkMode,
                        onToggle: (v) async {
                          setState(() {
                            _isDarkMode = v;
                            _bgColor = v ? 'Dark' : 'White';
                          });
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool("dark_mode", v);
                          themeNotifier.value = v ? ThemeMode.dark : ThemeMode.light;
                        }),
                    _buildColorTile(),
                  ]),
                  const SizedBox(height: 16),
                  _buildSection('About & Actions', [
                    _buildTile(Icons.info_rounded, 'About MediConnect',
                        trailing: 'v1.0.0', onTap: () => _showAbout()),
                    _buildTile(Icons.delete_rounded, 'Delete account',
                        isDestructive: true, onTap: () => _showDeleteAccount()),
                  ]),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: _isDarkMode ? primaryBg : Colors.white,
        border: Border(
            bottom: BorderSide(
                color: _isDarkMode ? borderColor : Colors.grey.shade200,
                width: 0.5)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _isDarkMode ? Colors.white : Colors.grey.shade100,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 1),
              ),
              child: const Icon(Icons.chevron_left_rounded,
                  color: primary, size: 22),
            ),
          ),
          const SizedBox(width: 12),
          Text('Settings',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _isDarkMode ? Colors.white : Colors.black)),
        ],
      ),
    );
  }

  // ── Section builder ───────────────────────
  Widget _buildSection(String title, List<Widget> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _isDarkMode ? Colors.white38 : Colors.grey.shade500,
                letterSpacing: 0.8)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: _isDarkMode ? cardBg : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: _isDarkMode ? borderColor : Colors.grey.shade200,
                width: 0.5),
          ),
          child: Column(
            children: List.generate(
                tiles.length,
                (i) => Column(
                      children: [
                        tiles[i],
                        if (i != tiles.length - 1)
                          Divider(
                              height: 1,
                              color: _isDarkMode
                                  ? borderColor
                                  : Colors.grey.shade200,
                              indent: 16,
                              endIndent: 16),
                      ],
                    )),
          ),
        ),
      ],
    );
  }

  // ── Regular tile ──────────────────────────
  Widget _buildTile(
    IconData icon,
    String label, {
    String? trailing,
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Icon(icon,
                color: isDestructive
                    ? const Color(0xFFE24B4A)
                    : _isDarkMode
                        ? Colors.white54
                        : Colors.grey.shade600,
                size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      color: isDestructive
                          ? const Color(0xFFE24B4A)
                          : _isDarkMode
                              ? Colors.white
                              : Colors.black87)),
            ),
            if (trailing != null) ...[
              Text(trailing,
                  style: const TextStyle(
                      fontSize: 12,
                      color: primary,
                      fontWeight: FontWeight.w500)),
              const SizedBox(width: 4),
            ],
            Icon(Icons.chevron_right_rounded,
                color: _isDarkMode ? Colors.white38 : Colors.grey.shade400,
                size: 18),
          ],
        ),
      ),
    );
  }

  // ── Toggle tile ───────────────────────────
  Widget _buildToggleTile(
    IconData icon,
    String label,
    bool value, {
    required Function(bool) onToggle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Icon(icon,
              color: _isDarkMode ? Colors.white54 : Colors.grey.shade600,
              size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: 13,
                    color: _isDarkMode ? Colors.white : Colors.black87)),
          ),
          Switch(
            value: value,
            onChanged: onToggle,
            activeThumbColor: primary,
            activeTrackColor: const Color(0xFF1A2A22),
          ),
        ],
      ),
    );
  }

  // ── Color tile ────────────────────────────
  Widget _buildColorTile() {
    final colors = [
      {'label': 'Dark', 'bg': const Color(0xFF2C2A2A), 'text': Colors.white},
      {'label': 'Black', 'bg': Colors.black, 'text': Colors.white},
      {'label': 'White', 'bg': Colors.white, 'text': Colors.black},
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.palette_rounded,
                  color: Colors.white54, size: 18),
              const SizedBox(width: 12),
              Text('Background color',
                  style: TextStyle(
                      fontSize: 13,
                      color: _isDarkMode ? Colors.white : Colors.black87)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: colors.map((c) {
              final isSelected = _bgColor == c['label'];
              return Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final isDark = c['label'] != 'White';
                    setState(() {
                      _bgColor = c['label'] as String;
                      _isDarkMode = isDark;
                    });
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool("dark_mode", isDark);
                    themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    height: 52,
                    decoration: BoxDecoration(
                      color: c['bg'] as Color,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? primary : Colors.grey.shade600,
                        width: isSelected ? 2 : 0.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isSelected)
                          Icon(Icons.check_circle_rounded,
                              color: isSelected ? primary : Colors.transparent,
                              size: 16),
                        Text(c['label'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: c['text'] as Color,
                            )),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Edit profile ──────────────────────────
  void _showEditProfile() {
    final nameController = TextEditingController(text: _name);
    final ageController =
        TextEditingController(text: _age > 0 ? _age.toString() : '');
    String selectedBloodGroup = _bloodGroup;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sheetHandle(),
              const SizedBox(height: 16),
              const Text('Edit profile',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              const SizedBox(height: 16),
              _inputField('Full name', nameController),
              const SizedBox(height: 10),
              _inputField('Age', ageController,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 10),
              const Text('Blood group',
                  style: TextStyle(fontSize: 12, color: Colors.white54)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']
                    .map((bg) => GestureDetector(
                          onTap: () {
                            setModalState(() {
                              selectedBloodGroup = bg;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: bg == selectedBloodGroup
                                  ? primary
                                  : const Color(0xFF2C2A2A),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: bg == selectedBloodGroup
                                      ? primary
                                      : borderColor,
                                  width: 0.5),
                            ),
                            child: Text(bg,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.white)),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 20),
              _saveButton('Save changes', () async {
                final newName = nameController.text.trim();
                final newAgeStr = ageController.text.trim();
                final newAge = int.tryParse(newAgeStr) ?? 0;

                if (newName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name cannot be empty')),
                  );
                  return;
                }

                // Call update profile on backend
                final res = await ApiService.updateProfile(
                  _email,
                  newName,
                  _phone,
                  newAge,
                  selectedBloodGroup,
                  _gender,
                  [], // Medical history
                );

                if (res["error"] == null) {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString("user_name", newName);
                  await prefs.setInt("age", newAge);
                  await prefs.setString("blood_group", selectedBloodGroup);

                  setState(() {
                    _name = newName;
                    _age = newAge;
                    _bloodGroup = selectedBloodGroup;
                  });

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile updated successfully! ✅'),
                      backgroundColor: primary,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${res["error"]}')),
                  );
                }
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ── Change phone ──────────────────────────
  void _showChangePhone() {
    final phoneController = TextEditingController(text: _phone);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sheetHandle(),
            const SizedBox(height: 16),
            const Text('Change phone number',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
            const SizedBox(height: 6),
            Text('Current: $_phone',
                style: const TextStyle(fontSize: 12, color: Colors.white54)),
            const SizedBox(height: 16),
            _inputField('New phone number', phoneController,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 20),
            _saveButton('Save changes', () async {
              final newPhone = phoneController.text.trim();
              if (newPhone.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Phone number cannot be empty')),
                );
                return;
              }

              final res = await ApiService.updateProfile(
                _email,
                _name,
                newPhone,
                _age,
                _bloodGroup,
                _gender,
                [],
              );

              if (res["error"] == null) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString("phone", newPhone);

                setState(() {
                  _phone = newPhone;
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Phone number updated successfully! ✅'),
                    backgroundColor: primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${res["error"]}')),
                );
              }
            }),
          ],
        ),
      ),
    );
  }

  // ── Language picker ───────────────────────
  void _showLanguagePicker() {
    final languages = [
      'English',
      'Tamil',
      'Hindi',
      'Telugu',
      'Kannada',
      'Malayalam',
      'Bengali',
      'Marathi',
      'Gujarati',
      'Punjabi',
      'Urdu',
      'Odia',
    ];
    final searchController = TextEditingController();
    List<String> filtered = List.from(languages);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text('Select language',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              const SizedBox(height: 12),

              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: searchController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  onChanged: (val) {
                    setModalState(() {
                      filtered = languages
                          .where((l) =>
                              l.toLowerCase().contains(val.toLowerCase()))
                          .toList();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search language...',
                    hintStyle:
                        const TextStyle(color: Colors.white38, fontSize: 13),
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: primary, size: 18),
                    filled: true,
                    fillColor: const Color(0xFF2C2A2A),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: primary, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: borderColor, width: 0.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Language list with scrollbar
              Expanded(
                child: Scrollbar(
                  thumbVisibility: true,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final lang = filtered[i];
                      final isSelected = _language == lang;
                      return GestureDetector(
                        onTap: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setString("settings_language", lang);
                          setState(() => _language = lang);
                          Navigator.pop(context);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF1A2A22)
                                : const Color(0xFF2C2A2A),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? primary : borderColor,
                              width: isSelected ? 1.5 : 0.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(lang,
                                  style: const TextStyle(
                                      fontSize: 13, color: Colors.white)),
                              const Spacer(),
                              if (isSelected)
                                const Icon(Icons.check_circle_rounded,
                                    color: primary, size: 18),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
  // ── Family accounts ───────────────────────

  // ── Profile visibility ────────────────────

  // ── Unit picker ───────────────────────────

  // ── Default hospital ──────────────────────

  // ── Emergency contacts ────────────────────

  // ── Help ──────────────────────────────────

  // ── About ─────────────────────────────────
  void _showAbout() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sheetHandle(),
            const SizedBox(height: 20),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(color: primary, shape: BoxShape.circle),
              child: const Icon(Icons.medical_services_rounded,
                  color: Colors.white, size: 28),
            ),
            const SizedBox(height: 12),
            const Text('MediConnect',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
            const SizedBox(height: 4),
            const Text('Version 1.0.0',
                style: TextStyle(fontSize: 12, color: Colors.white54)),
            const SizedBox(height: 20),
            _aboutRow('Developer', 'MediConnect Team'),
            _aboutRow('Contact', 'hello@mediconnect.in'),
            _aboutRow('Website', 'www.mediconnect.in'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2A2A),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderColor, width: 0.5),
                      ),
                      child: const Center(
                          child: Text('Terms of service',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.white54))),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2A2A),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderColor, width: 0.5),
                      ),
                      child: const Center(
                          child: Text('Privacy policy',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.white54))),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _aboutRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$label: ',
              style: const TextStyle(fontSize: 12, color: Colors.white54)),
          Text(value,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white)),
        ],
      ),
    );
  }

  // ── Delete account ────────────────────────
  void _showDeleteAccount() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: cardBg,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Delete account',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  'This will permanently delete your account and all data. Type DELETE to confirm.',
                  style: TextStyle(
                      fontSize: 13, color: Colors.white54, height: 1.5)),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                onChanged: (_) => setDialogState(() {}),
                decoration: InputDecoration(
                  hintText: 'Type DELETE',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF2C2A2A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: controller.text == 'DELETE'
                  ? () async {
                      Navigator.pop(context); // Close dialog
                      final deleteRes = await ApiService.deleteAccount(_email);
                      if (!mounted) return;
                      if (deleteRes["success"] == true) {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.clear(); // Clear local storage
                        if (!mounted) return;

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Failed to delete account: ${deleteRes["error"]}')),
                        );
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE24B4A),
                disabledBackgroundColor: const Color(0xFF3A3A3A),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child:
                  const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helper widgets ────────────────────────
  Widget _sheetHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _inputField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.white54)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF2C2A2A),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: primary, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: borderColor, width: 0.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _saveButton(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(label,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
      ),
    );
  }
}
