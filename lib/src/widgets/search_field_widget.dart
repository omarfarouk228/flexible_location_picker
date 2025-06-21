import 'package:flutter/material.dart';
import '../controllers/location_picker_controller.dart';
import '../models/location_picker_config.dart';
import '../models/location_data.dart';

/// A widget that provides an address search input field with autocomplete suggestions.
///
/// It interacts with the [LocationPickerController] to perform searches and
/// display results, allowing the user to select a location.
class SearchFieldWidget extends StatefulWidget {
  /// Creates a [SearchFieldWidget].
  const SearchFieldWidget({
    super.key,
    required this.controller,
    required this.config,
  });

  /// The controller managing location picking logic and search operations.
  final LocationPickerController controller;

  /// The configuration for the location picker, providing styling and text options.
  final LocationPickerConfig config;

  @override
  State<SearchFieldWidget> createState() => _SearchFieldWidgetState();
}

class _SearchFieldWidgetState extends State<SearchFieldWidget> {
  // Controller for the text input field.
  late TextEditingController _textController;
  // Focus node to manage the focus state of the text field.
  final FocusNode _focusNode = FocusNode();
  // Flag to control the expansion/collapse of search results.
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    // Listen for changes in focus to expand/collapse the search results.
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Callback when the text field's focus changes.
  /// Updates [_isExpanded] to show/hide search results.
  void _onFocusChanged() {
    setState(() {
      _isExpanded = _focusNode.hasFocus;
    });
  }

  /// Callback when the search text changes.
  /// Triggers an address search via the controller.
  void _onSearchChanged(String value) {
    debugPrint('Search query: $value');
    widget.controller.searchAddresses(value);
  }

  /// Callback when a search result is tapped.
  /// Updates the text field, selects the location in the controller, and unfocuses.
  void _onSearchResultTap(LocationData locationData) {
    _textController.text =
        locationData.address; // Set selected address in text field
    widget.controller.selectSearchResult(
      locationData,
    ); // Notify controller of selection
    _focusNode.unfocus(); // Close keyboard and collapse results
  }

  /// Clears the search text and results.
  void _clearSearch() {
    _textController.clear(); // Clear text field
    widget.controller.clearSearchResults(); // Clear controller's search results
    _focusNode.unfocus(); // Unfocus text field
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(
        milliseconds: 200,
      ), // Animation for container changes
      decoration: BoxDecoration(
        color: Colors.white, // Background color of the search container
        borderRadius: BorderRadius.circular(12), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Shadow for elevation
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize
            .min, // Column takes minimum space required by its children
        children: [
          // --- Search Input Field ---
          TextField(
            controller: _textController,
            focusNode: _focusNode,
            // Apply custom decoration from config or default InputDecoration.
            decoration:
                widget.config.searchFieldDecoration ??
                InputDecoration(
                  hintText: widget.config.searchHintText, // Placeholder text
                  prefixIcon: const Icon(
                    Icons.search,
                  ), // Search icon at the start
                  // Suffix icon depends on text presence or loading state.
                  suffixIcon: _textController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                          ), // Clear button if text is present
                          onPressed: _clearSearch,
                        )
                      : widget.controller.isSearching
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ), // Loading indicator if searching
                          ),
                        )
                      : null, // No suffix icon otherwise
                  border:
                      InputBorder.none, // No default border for the TextField
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
            onChanged: _onSearchChanged, // Callback when text changes
          ),

          // --- Search Results List ---
          // Only show results if the field is focused and there are results.
          if (_isExpanded && widget.controller.searchResults.isNotEmpty)
            Container(
              constraints: const BoxConstraints(
                maxHeight: 200,
              ), // Limit height of the results list
              child: ListView.builder(
                shrinkWrap:
                    true, // List takes only as much space as its children
                itemCount: widget.controller.searchResults.length,
                itemBuilder: (context, index) {
                  final result = widget.controller.searchResults[index];
                  return ListTile(
                    dense: true, // Compact ListTile
                    leading: const Icon(
                      Icons.place,
                      size: 20,
                    ), // Icon for each result
                    title: Text(
                      result.address, // Main address text
                      style: const TextStyle(fontSize: 14),
                    ),
                    subtitle: result.city != null
                        ? Text(
                            '${result.city}, ${result.country}', // City and country as subtitle
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          )
                        : null, // No subtitle if city is null
                    onTap: () =>
                        _onSearchResultTap(result), // Select result on tap
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
