import 'package:flutter/material.dart';
import 'package:learnvironment/developer/edit_game.dart';
import 'package:learnvironment/main_pages/widgets/tag.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:provider/provider.dart';

class MyGameCard extends StatefulWidget {
  final String imagePath;
  final String gameTitle;
  final List<String> tags;
  final String gameId;
  final bool isPublic;
  final Future<void> Function(String gameId) loadGame;

  MyGameCard({
    super.key,
    required this.imagePath,
    required this.gameTitle,
    required this.tags,
    required this.gameId,
    required this.loadGame,
    required this.isPublic,
  });

  @override
  State<MyGameCard> createState() => _MyGameCardState();
}

class _MyGameCardState extends State<MyGameCard> {
  bool _isPublic = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isPublic = widget.isPublic;
  }

  Future<void> _togglePublicStatus() async {
    DataService dataService = Provider.of<DataService>(context, listen: false);

    setState(() {
      _isLoading = true;
      _isPublic = !_isPublic;
    });

    try {
      await dataService.updateGamePublicStatus(gameId: widget.gameId, status: _isPublic);

      print('Game status updated');
    } catch (e) {
      print('Error toggling public status: $e');
      setState(() {
        _isPublic = !_isPublic;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update game status!')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: GestureDetector(
        key: Key('gameCard_${widget.gameId}'),
        onTap: () async => await widget.loadGame(widget.gameId),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade400,
                blurRadius: 5,
                spreadRadius: 2,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                child: widget.imagePath.startsWith('assets/')
                    ? Image.asset(
                  widget.imagePath,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
                    : Image.network(
                  widget.imagePath,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.gameTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        List<Widget> tagWidgets = [];
                        for (int i = 0; i < widget.tags.length && i < 2; i++) {
                          tagWidgets.add(TagWidget(tag: widget.tags[i]));
                        }
                        if (widget.tags.length > 3) {
                          tagWidgets.add(
                            TagWidget(tag: '+${widget.tags.length - 2} more'),
                          );
                        }
                        return Wrap(
                          spacing: 5,
                          runSpacing: 5,
                          children: tagWidgets,
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    IconButton(
                      icon: Icon(Icons.edit),
                      key: Key("edit"),
                      tooltip: 'Edit',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditGame(gameId: widget.gameId),
                          ),
                        );
                      },
                    ),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _togglePublicStatus,
                      child: _isLoading
                          ? CircularProgressIndicator()  // Loading state
                          : Text(_isPublic ? 'Make Private' : 'Make Public'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
