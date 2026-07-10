import 'package:flutter/material.dart';
// built in ui widgets
import 'package:flutter_riverpod/flutter_riverpod.dart';
// riverpod state management
import 'package:tpmentorship/models/user_profile.dart';
// the user profile data type
import 'package:tpmentorship/providers/auth_provider.dart';
import 'package:tpmentorship/providers/data_providers.dart';
// the app's providers
import 'package:tpmentorship/theme/app_theme.dart';
// app colours and styling
import 'package:tpmentorship/utils/snackbar_helper.dart';
// helper to show popup messages

class EditProfileScreen extends ConsumerStatefulWidget {
// a validated form for editing the user's Firestore profile
// the subjects picked here are what the AI matching feature uses
  final UserProfile profile;
  // the current profile values to pre-fill the form with

  const EditProfileScreen({super.key, required this.profile});

  @override
  ConsumerState<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  // lets us run every field's validator at once on submit

  late final TextEditingController _nameController;
  late final TextEditingController _studentIdController;
  late final TextEditingController _courseController;
  late final TextEditingController _bioController;
  // pre-filled with the current profile values in initState

  String? _academicYear;
  late List<String> _selectedSubjects;
  // which subject chips are picked

  bool _saving = false;
  // true while saving, shows the button spinner

  // the subjects students can pick from (same codes the mentors teach)
  static const _allSubjects = ['DAVA', 'LOMA', 'COMT', 'ECOMM', 'GSOST'];
  static const _years = ['Year 1', 'Year 2', 'Year 3'];

  @override
  void initState() {
    super.initState();
    // start every field with what the profile currently says
    _nameController = TextEditingController(text: widget.profile.fullName);
    _studentIdController =
        TextEditingController(text: widget.profile.studentId);
    _courseController = TextEditingController(text: widget.profile.course);
    _bioController = TextEditingController(text: widget.profile.bio);
    _academicYear = widget.profile.academicYear.isEmpty
        ? null
        : widget.profile.academicYear;
    _selectedSubjects = List.from(widget.profile.subjects);
  }

  @override
  void dispose() {
  // free the controllers memory to avoid leaks
    _nameController.dispose();
    _studentIdController.dispose();
    _courseController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // checks the form then saves the changes to Firestore
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    // stop if any field is invalid

    setState(() => _saving = true);
    try {
      await ref.read(userServiceProvider).updateProfile(
            uid: widget.profile.uid,
            fullName: _nameController.text.trim(),
            studentId: _studentIdController.text.trim().toUpperCase(),
            course: _courseController.text.trim(),
            academicYear: _academicYear ?? '',
            bio: _bioController.text.trim(),
            subjects: _selectedSubjects,
          );

      // keep the auth display name in sync so the greeting matches
      final newName = _nameController.text.trim();
      if (newName != widget.profile.fullName) {
        await ref.read(authServiceProvider).updateDisplayName(newName);
      }

      if (!mounted) return;
      showAppSnackBar(context, 'Profile updated!', success: true);
      Navigator.pop(context);
      // profile screen refreshes by itself - its watching the stream
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(context, 'Could not save your profile. Try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ----- full name -----
                _label('Full Name'),
                TextFormField(
                  controller: _nameController,
                  style: TextStyle(color: AppTheme.textPrimary),
                  keyboardType: TextInputType.name,
                  decoration:
                      const InputDecoration(hintText: 'Your full name'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    if (value.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ----- student id -----
                _label('Student ID'),
                TextFormField(
                  controller: _studentIdController,
                  style: TextStyle(color: AppTheme.textPrimary),
                  keyboardType: TextInputType.text,
                  decoration:
                      const InputDecoration(hintText: 'e.g. 2501587F'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your student ID';
                    }
                    // TP student ids are 7 digits then a letter
                    final pattern = RegExp(r'^\d{7}[A-Za-z]$');
                    if (!pattern.hasMatch(value.trim())) {
                      return 'Student ID should be 7 digits then a letter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ----- course -----
                _label('Course'),
                TextFormField(
                  controller: _courseController,
                  style: TextStyle(color: AppTheme.textPrimary),
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                      hintText: 'e.g. Diploma in AAI'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your course';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ----- academic year dropdown -----
                _label('Academic Year'),
                DropdownButtonFormField<String>(
                  initialValue: _academicYear,
                  dropdownColor: AppTheme.darkCardBg,
                  style: TextStyle(color: AppTheme.textPrimary),
                  decoration:
                      const InputDecoration(hintText: 'Select your year'),
                  items: _years
                      .map((y) =>
                          DropdownMenuItem(value: y, child: Text(y)))
                      .toList(),
                  onChanged: (year) => setState(() => _academicYear = year),
                  validator: (value) =>
                      value == null ? 'Please select your year' : null,
                ),
                const SizedBox(height: 16),

                // ----- bio -----
                _label('Bio'),
                TextFormField(
                  controller: _bioController,
                  style: TextStyle(color: AppTheme.textPrimary),
                  keyboardType: TextInputType.multiline,
                  maxLines: 3,
                  maxLength: 150,
                  // the counter under the box is another form of feedback
                  decoration: InputDecoration(
                    hintText: 'Tell mentors a little about yourself',
                    counterStyle:
                        TextStyle(color: AppTheme.textSecondary),
                  ),
                  // bio is optional - no validator
                ),
                const SizedBox(height: 8),

                // ----- subjects the student needs help with -----
                _label('Subjects I need help with'),
                Text(
                  'The AI uses these to recommend your best-fit mentors',
                  style: TextStyle(
                      color: AppTheme.textSecondary, fontSize: 11),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _allSubjects.map((subject) {
                    final selected = _selectedSubjects.contains(subject);
                    return FilterChip(
                      label: Text(subject),
                      selected: selected,
                      onSelected: (picked) {
                        setState(() {
                          // add or remove the subject from the list
                          if (picked) {
                            _selectedSubjects.add(subject);
                          } else {
                            _selectedSubjects.remove(subject);
                          }
                        });
                      },
                      selectedColor: AppTheme.tpRed,
                      backgroundColor: AppTheme.darkCardBg,
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color: selected
                            ? Colors.white
                            : AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      side: BorderSide(
                          color: selected
                              ? AppTheme.tpRed
                              : AppTheme.darkBorder),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // ----- save button with loading spinner -----
                ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // small bold heading above each field
  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
            color: AppTheme.textPrimary, fontWeight: FontWeight.w700),
      ),
    );
  }
}
