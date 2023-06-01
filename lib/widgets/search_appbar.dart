import 'package:birthday_reminder/strings.dart';
import 'package:flutter/material.dart';

class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  const SearchAppBar({
    super.key,
    required this.onSearch,
    required this.onCancel,
    this.elevation,
    required this.searchEnabled,
  });

  final void Function(String query) onSearch;
  final void Function() onCancel;
  final double? elevation;
  final bool searchEnabled;

  @override
  _SearchAppBarState createState() => _SearchAppBarState();

  @override
  Size get preferredSize => AppBar().preferredSize;
}

class _SearchAppBarState extends State<SearchAppBar> {
  late final TextEditingController _controller;

  bool searching = false;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  void _onSearch() {
    widget.onSearch(_controller.text);
  }

  void _onCancel() {
    setState(() {
      searching = false;
    });
    _controller.clear();
    widget.onCancel();
  }

  @override
  Widget build(BuildContext context) {
    final strings = appStrings(context);

    if (!searching || !widget.searchEnabled) {
      return AppBar(
        title: Text(strings.mainPageTitle),
        shadowColor: Colors.black26,
        elevation: widget.elevation,
        actions: [
          if (widget.searchEnabled)
            IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  setState(() {
                    searching = true;
                  });
                }),
        ],
      );
    }

    return AppBar(
      title: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          hintText: strings.search,
          border: InputBorder.none,
        ),
        onChanged: (value) {
          _onSearch();
        },
      ),
      shadowColor: Colors.black26,
      actions: [
        IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: _onCancel,
        ),
      ],
    );
  }
}
