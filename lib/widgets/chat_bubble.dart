import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:leximind/entities/kml_entity.dart';
import 'package:leximind/models/message.dart';
import 'package:leximind/services/lg_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ChatBubble extends StatefulWidget {
  final Message message;

  const ChatBubble({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  bool isProcessing = false;

  bool get isUser => widget.message.role == MessageRole.user;
  String get content => widget.message.content;
  
  String? extractKml(String text) {
    final RegExp kmlRegex = RegExp(
      r'<\?xml[\s\S]*?</kml>',
      caseSensitive: false,
      dotAll: true,
    );
    final match = kmlRegex.firstMatch(text);
    return match?.group(0);
  }

  @override
  Widget build(BuildContext context) {
    final kmlContent = !isUser ? extractKml(widget.message.content) : null;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser
              ? Theme.of(context).primaryColor.withOpacity(0.2)
              : Colors.grey.withOpacity(0.1),
          borderRadius: isUser ? BorderRadius.only(
              bottomLeft: Radius.circular(16), 
              bottomRight: Radius.circular(16), 
              topLeft: Radius.circular(16), 
              topRight: Radius.circular(3), 
            )
            : BorderRadius.only(
              bottomLeft: Radius.circular(16), 
              bottomRight: Radius.circular(16), 
              topLeft: Radius.circular(3), 
              topRight: Radius.circular(16), 
            ),
          border: Border.all(
            color: isUser
                ? Theme.of(context).primaryColor.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MarkdownBody(
              data: widget.message.content,
              styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                p: TextStyle(
                  color: isUser
                      ? Theme.of(context).primaryColor.withOpacity(0.9)
                      : const Color.fromARGB(221, 228, 227, 227),
                ),
              ),
              selectable: true,
            ),
            
            if (!isUser && widget.message.containsKml)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      icon: isProcessing 
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Theme.of(context).primaryColor.withOpacity(0.9),
                              ),
                            )
                          : const Icon(Icons.upload_rounded),
                      label: Text(isProcessing ? 'Sending...' : 'Send KML'),
                      onPressed: isProcessing 
                          ? null 
                          : () async {
                              final kml = await _requestKmlGeneration(context, widget.message.content);
                              if (kml != null) {
                                _saveAndShareKml(context, kml);
                              }
                            },
                    ),
                    if (kmlContent != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: IconButton(
                          icon: const Icon(Icons.content_copy),
                          tooltip: 'Copy KML',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: kmlContent));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('KML copied to clipboard')),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<String?> _requestKmlGeneration(BuildContext context, String content) async {
    final kmlContent = extractKml(content);
    if (kmlContent == null) return null;

    final shouldSend = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send KML'),
        content: const Text('The response contains information that could be formatted as KML. Would you like to send it to Liquid Galaxy?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
            style: TextButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.red,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Send'),
          ),
        ],
      ),
    );

    if (shouldSend == true) {
      print("kml content: ${kmlContent.trim().split('\n').last}");
      return kmlContent;
    }
    
    return null;
  }
  
  Future<void> _saveAndShareKml(BuildContext context, String kml) async {
    final RootIsolateToken? rootIsolateToken = ServicesBinding.rootIsolateToken;
    if (rootIsolateToken == null) {
      throw Exception('RootIsolateToken is null!');
    }
    await compute(
      LGService.sendKmlStatic,
      {'token': rootIsolateToken, 'kml': kml},
    );
    try {
      setState(() {
        isProcessing = true;
      });

      await Future.delayed(Duration.zero);
      
      try {
        await compute(LGService.sendKmlStatic, {'token': rootIsolateToken, 'kml': kml});
        
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('KML sent successfully')),
        );
      } catch (e) {
        print("send error: ${e.toString()}");
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending KML: ${e.toString()}')),
        );
      }
    } catch (e) {
      print("Error in _saveAndShareKml: ${e.toString()}");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unexpected error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }
}