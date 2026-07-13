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
import 'package:tpmentorship/widgets/subject_picker.dart';
// the subject chips + "More..." custom subject input

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
      final fullName = _nameController.text.trim();
      final course = _courseController.text.trim();
      final bio = _bioController.text.trim();
      await ref.read(userServiceProvider).updateProfile(
            uid: widget.profile.uid,
            fullName: fullName,
            studentId: _studentIdController.text.trim().toUpperCase(),
            course: course,
            academicYear: _academicYear ?? '',
            bio: bio,
            subjects: _selectedSubjects,
          );

      // keep the "browse students" directory in sync too, so mentors
      // looking for mentees can find real registered students (not just
      // the seed data) - see StudentService.publishToDirectory
      if (_selectedSubjects.isNotEmpty) {
        await ref.read(studentServiceProvider).publishToDirectory(
              uid: widget.profile.uid,
              name: fullName,
              course: course,
              academicYear: _academicYear ?? '',
              subjects: _selectedSubjects,
              bio: bio,
            );
      } else {
        // no subjects set - nothing to browse them for
        await ref.read(studentServiceProvider).removeFromDirectory(widget.profile.uid);
      }

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
                // ----- role (read only - changes automatically when you
                // sign up as a mentor from the Mentor Profile tab) -----
                _label('Role'),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.tpRed.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: AppTheme.tpRed.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    widget.profile.role,
                    style: TextStyle(
                      color: AppTheme.tpRed,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

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
                SubjectPicker(
                  selected: _selectedSubjects,
                  onChanged: (subjects) =>
                      setState(() => _selectedSubjects = subjects),
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
