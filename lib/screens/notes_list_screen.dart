import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/note.dart';
import '../services/db_helper.dart';
import '../providers/theme_provider.dart';
import 'note_editor_screen.dart';

// Accessing ThemeProvider from main context using InheritedNotifier
class ThemeScope extends InheritedNotifier<ThemeProvider> {
  const ThemeScope({
    super.key,
    required super.notifier,
    required super.child,
  });

  static ThemeProvider of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ThemeScope>();
    assert(scope != null, 'No ThemeScope found in context');
    return scope!.notifier!;
  }
}

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _SplashScreenTransition extends PageRouteBuilder {
  final Widget page;
  _SplashScreenTransition({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 400),
        );
}

class _NotesListScreenState extends State<NotesListScreen> {
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  // Premium Pastel Color Palette (index matched)
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
    _refreshNotes();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshNotes() async {
    setState(() {
      _isLoading = true;
    });
    final notes = await DBHelper.instance.getNotes();
    if (mounted) {
      setState(() {
        _notes = notes;
        _filteredNotes = notes;
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredNotes = _notes.where((note) {
        final title = note.title.toLowerCase();
        final content = note.content.toLowerCase();
        return title.contains(query) || content.contains(query);
      }).toList();
    });
  }

  Future<void> _deleteNote(int id) async {
    // Elegant Confirmation Dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final isDark = ThemeScope.of(context).isDarkMode;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Hapus Catatan',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus catatan ini secara permanen?',
            style: GoogleFonts.outfit(color: isDark ? Colors.white70 : Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Batal',
                style: GoogleFonts.outfit(color: Colors.grey, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                'Hapus',
                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await DBHelper.instance.deleteNote(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Catatan berhasil dihapus', style: GoogleFonts.outfit()),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      _refreshNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeScope.of(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom Beautiful Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Catatan Saya',
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  // Sleek circular dark mode toggle button
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? Colors.white10 : Colors.black12,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.black38 : Colors.black12,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        color: isDark ? Colors.amberAccent : Colors.indigo,
                        size: 24,
                      ),
                      onPressed: () {
                        themeProvider.toggleTheme();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Glassmorphic Search Bar
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B).withOpacity(0.8) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black38 : Colors.black12,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  style: GoogleFonts.outfit(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'Cari catatan...',
                    hintStyle: GoogleFonts.outfit(color: isDark ? Colors.white38 : Colors.black38),
                    prefixIcon: Icon(Icons.search_rounded, color: isDark ? Colors.white54 : Colors.black45),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear_rounded, color: isDark ? Colors.white54 : Colors.black45),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Body area
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.indigoAccent),
                      )
                    : _filteredNotes.isEmpty
                        ? _buildEmptyState(isDark)
                        : _buildNotesGrid(isDark),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final added = await Navigator.of(context).push(
            _SplashScreenTransition(page: const NoteEditorScreen()),
          );
          if (added == true) {
            _refreshNotes();
          }
        },
        backgroundColor: Colors.indigoAccent,
        elevation: 6,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
        label: Text(
          'Tambah Catatan',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchController.text.isNotEmpty ? Icons.search_off_rounded : Icons.note_alt_outlined,
            size: 80,
            color: isDark ? Colors.white24 : Colors.black12,
          ),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isNotEmpty ? 'Catatan tidak ditemukan' : 'Belum ada catatan',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isNotEmpty
                ? 'Coba gunakan kata kunci pencarian yang lain'
                : 'Mulai menulis hal-hal kreatif Anda sekarang!',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesGrid(bool isDark) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: _filteredNotes.length,
      itemBuilder: (context, index) {
        final note = _filteredNotes[index];
        final cardColor = _pastelColors[note.colorValue % _pastelColors.length];

        return GestureDetector(
          onTap: () async {
            final updated = await Navigator.of(context).push(
              _SplashScreenTransition(page: NoteEditorScreen(note: note)),
            );
            if (updated == true) {
              _refreshNotes();
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black26 : Colors.black12,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Delete Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        note.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => _deleteNote(note.id!),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: Color(0xFFD90429),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Content preview
                Expanded(
                  child: Text(
                    note.content,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: const Color(0xFF334155),
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Date footer
                Text(
                  note.createdAt,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
