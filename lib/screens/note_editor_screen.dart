import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Make sure to use clean date formatting
import '../models/note.dart';
import '../services/db_helper.dart';
import 'notes_list_screen.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;

  const NoteEditorScreen({super.key, this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late int _selectedColorIndex;
  late bool _isEditing;

  // Premium Pastel Color Palette (must match list screen!)
  static const List<Color> _pastelColors = [
    Color(0xFFFFADAD), // Soft Red
    Color(0xFFFFD6A5), // Soft Orange
    Color(0xFFFDFFB6), // Soft Yellow
    Color(0xFFCAFFBF), // Soft Green
    Color(0xFF9BF6FF), // Soft Blue
    Color(0xFFA0C4FF), // Soft Indigo
    Color(0xFFBDB2FF), // Soft Purple
    Color(0xFFFFC6FF), // Soft Pink
  ];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.note != null;
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _selectedColorIndex = widget.note?.colorValue ?? 0;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Judul catatan tidak boleh kosong', style: GoogleFonts.outfit()),
          backgroundColor: Colors.amber[800],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    // Modern Date String
    final now = DateTime.now();
    final formattedDate = DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(now); // Localized formatted date

    if (_isEditing) {
      // Update
      final updatedNote = widget.note!.copyWith(
        title: title,
        content: content,
        colorValue: _selectedColorIndex,
        createdAt: formattedDate,
      );
      await DBHelper.instance.updateNote(updatedNote);
    } else {
      // Create
      final newNote = Note(
        title: title,
        content: content,
        colorValue: _selectedColorIndex,
        createdAt: formattedDate,
      );
      await DBHelper.instance.insertNote(newNote);
    }

    if (mounted) {
      Navigator.of(context).pop(true); // Return success to reload list
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeScope.of(context).isDarkMode;
    final editorBgColor = _pastelColors[_selectedColorIndex];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Sleek glassmorphic save button
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: _saveNote,
                icon: const Icon(Icons.save_rounded, size: 18, color: Colors.white),
                label: Text(
                  'Simpan',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigoAccent,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Horizontal Color Picker Toolbar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pilih Warna Catatan',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _pastelColors.length,
                      itemBuilder: (context, index) {
                        final isSelected = _selectedColorIndex == index;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedColorIndex = index;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: _pastelColors[index],
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.indigoAccent
                                    : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: Colors.indigoAccent.withOpacity(0.4),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      )
                                    ]
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      )
                                    ],
                            ),
                            child: isSelected
                                ? const Center(
                                    child: Icon(
                                      Icons.check_rounded,
                                      color: Color(0xFF0F172A),
                                      size: 18,
                                    ),
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 24, thickness: 1),
            // Core Text Editors inside a stylish note body container
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: editorBgColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black45 : Colors.black12,
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Title field
                    TextField(
                      controller: _titleController,
                      maxLines: 1,
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Judul Catatan...',
                        hintStyle: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A).withOpacity(0.4),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                    const Divider(color: Colors.black12, thickness: 1, height: 16),
                    // Content field
                    Expanded(
                      child: TextField(
                        controller: _contentController,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          color: const Color(0xFF334155),
                          height: 1.4,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Mulai menulis di sini...',
                          hintStyle: GoogleFonts.outfit(
                            fontSize: 16,
                            color: const Color(0xFF334155).withOpacity(0.4),
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
