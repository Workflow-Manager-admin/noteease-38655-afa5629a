import 'package:flutter/material.dart';

void main() {
  runApp(NoteEaseApp());
}

// PUBLIC_INTERFACE
class NoteEaseApp extends StatelessWidget {
  /// This is the root of the NoteEase application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NoteEase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF4A90E2),
        colorScheme: ColorScheme.light(
          primary: Color(0xFF4A90E2),
          secondary: Color(0xFFFFFFFF),
          tertiary: Color(0xFFF5A623),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF4A90E2),
        ),
        scaffoldBackgroundColor: Color(0xFFFFFFFF),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF4A90E2),
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Color(0xFF4A90E2),
            ),
          ),
        ),
      ),
      home: NoteEaseMainContainer(),
    );
  }
}

// --- Note Model ---

class Note {
  String id;
  String title;
  String content;
  Set<String> tags;
  DateTime lastEdited;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.tags,
    required this.lastEdited,
  });

  // Clone for editing
  Note copyWith({
    String? id,
    String? title,
    String? content,
    Set<String>? tags,
    DateTime? lastEdited,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      tags: tags ?? Set<String>.from(this.tags),
      lastEdited: lastEdited ?? this.lastEdited,
    );
  }
}

// --- Main Container ---

// PUBLIC_INTERFACE
class NoteEaseMainContainer extends StatefulWidget {
  /// Main container widget for NoteEase.
  @override
  _NoteEaseMainContainerState createState() => _NoteEaseMainContainerState();
}

class _NoteEaseMainContainerState extends State<NoteEaseMainContainer> {
  // List of all notes (in-memory for now)
  List<Note> _notes = [];

  // Set of all available tags in the system
  Set<String> _allTags = {};

  // Search & Filter state
  String _searchQuery = '';
  String? _activeTag;

  @override
  void initState() {
    super.initState();
    // Optionally pre-populate some sample notes/tags for demonstration
    _notes = [
      Note(
        id: UniqueKey().toString(),
        title: 'Welcome to NoteEase',
        content: 'Tap the + button to add a new note. You can edit, delete, search, and categorize notes.',
        tags: {'GettingStarted'},
        lastEdited: DateTime.now(),
      ),
      Note(
        id: UniqueKey().toString(),
        title: 'Shopping List',
        content: 'Eggs\nMilk\nBread\nBananas',
        tags: {'Personal'},
        lastEdited: DateTime.now().subtract(Duration(days: 1)),
      ),
      Note(
        id: UniqueKey().toString(),
        title: 'Work Todo',
        content: 'Update status document\nPrepare for Monday meeting',
        tags: {'Work', 'Urgent'},
        lastEdited: DateTime.now().subtract(Duration(days: 2)),
      )
    ];
    _regenerateTags();
  }

  void _regenerateTags() {
    final tags = <String>{};
    for (final n in _notes) {
      tags.addAll(n.tags);
    }
    setState(() {
      _allTags = tags;
    });
  }

  void _addOrUpdateNote(Note note) {
    setState(() {
      final idx = _notes.indexWhere((n) => n.id == note.id);
      if (idx >= 0) {
        _notes[idx] = note;
      } else {
        _notes.insert(0, note); // New notes at the top
      }
      _regenerateTags();
    });
  }

  void _deleteNote(String noteId) {
    setState(() {
      _notes.removeWhere((n) => n.id == noteId);
      _regenerateTags();
    });
  }

  void _setSearch(String query) {
    setState(() {
      _searchQuery = query.trim();
    });
  }

  void _setActiveTag(String? tag) {
    setState(() {
      _activeTag = tag == _activeTag ? null : tag;
    });
  }

  // PUBLIC_INTERFACE
  List<Note> get filteredNotes {
    var notes = _notes;
    if (_activeTag != null) {
      notes = notes.where((n) => n.tags.contains(_activeTag)).toList();
    }
    if (_searchQuery.isNotEmpty) {
      notes = notes
          .where((n) =>
              n.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              n.content.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    return notes;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('NoteEase'),
        elevation: 1.0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(theme),
            _buildFilterChips(theme),
            Expanded(child: _buildNotesList(theme)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNoteEditDialog(context),
        tooltip: 'Add Note',
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: Color(0xFF4A90E2)),
          hintText: 'Search notes...',
          filled: true,
          fillColor: Color(0xFFF5F7FA),
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onChanged: _setSearch,
      ),
    );
  }

  Widget _buildFilterChips(ThemeData theme) {
    if (_allTags.isEmpty) return SizedBox.shrink();
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _allTags
            .map((tag) => Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(tag),
                    selected: _activeTag == tag,
                    onSelected: (_) => _setActiveTag(tag),
                    selectedColor: Color(0xFFF5A623).withOpacity(0.22),
                    labelStyle: TextStyle(
                        color: _activeTag == tag
                            ? Color(0xFFF5A623)
                            : Color(0xFF4A90E2)),
                    backgroundColor: Color(0xFFE9EDF5),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildNotesList(ThemeData theme) {
    final notes = filteredNotes;
    if (notes.isEmpty) {
      return Center(
        child: Text(
          'No notes found',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey,
          ),
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: notes.length,
      itemBuilder: (ctx, idx) =>
          _buildNoteListTile(context, notes[idx], theme),
      separatorBuilder: (_, __) => SizedBox(height: 8),
    );
  }

  Widget _buildNoteListTile(BuildContext context, Note note, ThemeData theme) {
    return Material(
      elevation: 1.5,
      borderRadius: BorderRadius.circular(14),
      color: Color(0xFFE9EDF5),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _showNoteEditDialog(context, note: note),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _noteTitleAndPreview(note),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red[300]),
                tooltip: 'Delete',
                onPressed: () {
                  _confirmDelete(context, note);
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _noteTitleAndPreview(Note note) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          note.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFF4A90E2),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2),
        Text(
          note.content.replaceAll('\n', ' '),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[800],
          ),
        ),
        if (note.tags.isNotEmpty) ...[
          SizedBox(height: 6),
          Wrap(
            spacing: 6,
            children: note.tags
                .map((t) => Chip(
                      label: Text(
                        t,
                        style: TextStyle(
                          color: Color(0xFFF5A623),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: Color(0xFFFFF7EC),
                      padding:
                          EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                      visualDensity:
                          VisualDensity(horizontal: -3.0, vertical: -4.0),
                    ))
                .toList(),
          ),
        ]
      ],
    );
  }

  // --- Editing/Creating Notes ---

  void _showNoteEditDialog(BuildContext ctx, {Note? note}) {
    showDialog(
      context: ctx,
      builder: (context) {
        return NoteEditorDialog(
          note: note,
          allAvailableTags: _allTags,
          onSaved: (updatedNote) {
            _addOrUpdateNote(updatedNote);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext ctx, Note note) async {
    final isConfirmed = await showDialog<bool>(
        context: ctx,
        builder: (context) => AlertDialog(
              title: Text('Delete Note?'),
              content: Text('Are you sure you want to delete this note?'),
              actions: [
                TextButton(
                  child: Text('Cancel', style: TextStyle(color: Color(0xFF4A90E2))),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: Text('Delete', style: TextStyle(color: Colors.red)),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                )
              ],
            ));
    if (isConfirmed == true) {
      _deleteNote(note.id);
    }
  }
}

// --- Note Editor Dialog Widget ---

// PUBLIC_INTERFACE
class NoteEditorDialog extends StatefulWidget {
  /// Dialog for editing or creating a note.
  final Note? note;
  final Set<String> allAvailableTags;
  final void Function(Note note) onSaved;

  NoteEditorDialog({
    Key? key,
    this.note,
    required this.allAvailableTags,
    required this.onSaved,
  }) : super(key: key);

  @override
  _NoteEditorDialogState createState() => _NoteEditorDialogState();
}

class _NoteEditorDialogState extends State<NoteEditorDialog> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late Set<String> _editingTags;
  final _formKey = GlobalKey<FormState>();

  final _tagInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.note?.title ?? '');
    _contentController =
        TextEditingController(text: widget.note?.content ?? '');
    _editingTags = Set<String>.from(widget.note?.tags ?? {});
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagInputController.dispose();
    super.dispose();
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_editingTags.contains(tag)) {
        _editingTags.remove(tag);
      } else {
        _editingTags.add(tag);
      }
    });
  }

  void _addTag(String tag) {
    if (tag.trim().isEmpty) return;
    setState(() {
      _editingTags.add(tag.trim());
      _tagInputController.clear();
    });
  }

  void _removeTag(String tag) {
    setState(() {
      _editingTags.remove(tag);
    });
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    final isNew = widget.note == null;
    final note = (widget.note ??
        Note(
          id: UniqueKey().toString(),
          title: '',
          content: '',
          tags: {},
          lastEdited: DateTime.now(),
        ))
      .copyWith(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        tags: _editingTags,
        lastEdited: DateTime.now(),
      );
    widget.onSaved(note);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      insetPadding: EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.note == null ? 'Create Note' : 'Edit Note',
                  style: theme.textTheme.titleLarge,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Title',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Title can\'t be empty' : null,
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: _contentController,
                  maxLines: 8,
                  decoration: InputDecoration(
                    hintText: 'Type your note here...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Tags',
                    style: theme.textTheme.labelLarge,
                  ),
                ),
                SizedBox(height: 7),
                Wrap(
                  spacing: 6,
                  runSpacing: 2,
                  children: [
                    ..._editingTags.map(
                      (tag) => Chip(
                        label: Text(
                          tag,
                          style:
                              TextStyle(color: Color(0xFFF5A623), fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: Color(0xFFFFF7EC),
                        onDeleted: () => _removeTag(tag),
                        deleteIcon: Icon(Icons.close, size: 17, color: Color(0xFFF5A623)),
                        padding: EdgeInsets.symmetric(horizontal: 5),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 7),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _tagInputController,
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: 'Add tag',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onSubmitted: _addTag,
                      ),
                    ),
                    SizedBox(width: 8),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Color(0xFF4A90E2)),
                        backgroundColor: Color(0xFF4A90E2).withOpacity(0.07),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text('+', style: TextStyle(color: Color(0xFF4A90E2), fontSize: 18)),
                      onPressed: () => _addTag(_tagInputController.text),
                    ),
                  ],
                ),
                SizedBox(height: 7),
                if (widget.allAvailableTags.isNotEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 6,
                      children: widget.allAvailableTags
                          .where((t) => !_editingTags.contains(t))
                          .map((tag) => ChoiceChip(
                                label: Text(tag),
                                selected: false,
                                onSelected: (_) => _toggleTag(tag),
                                selectedColor: Color(0xFFF5A623).withOpacity(0.22),
                                labelStyle: TextStyle(color: Color(0xFF4A90E2)!),
                                backgroundColor: Color(0xFFE9EDF5),
                              ))
                          .toList(),
                    ),
                  ),
                SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child: Text('Cancel', style: TextStyle(color: Color(0xFF4A90E2))),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4A90E2),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text('Save'),
                      onPressed: _onSave,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
