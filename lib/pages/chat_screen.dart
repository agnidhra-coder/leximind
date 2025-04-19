
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:leximind/entities/kml_entity.dart';
import 'package:leximind/models/message.dart';
import 'package:leximind/pages/connection_screen.dart';
import 'package:leximind/providers/gemma_provider.dart';
import 'package:leximind/services/lg_service.dart';
// import 'package:leximind/models/message.dart';
import 'package:leximind/widgets/chat_bubble.dart';
import 'package:markdown/markdown.dart' as md;

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  late final ScrollController _scrollController;
  String get _connectionTxt => ref.watch(connectionStatusProvider) ? "Connected" : "Disconnected";


  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  void changeConnection(bool value) {
    ref.read(connectionStatusProvider.notifier).state = value;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatNotifierProvider);
    final isLoading = ref.watch(isLoadingProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.read(chatNotifierProvider.notifier).clearChat();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => ConnectionScreen(onConnectionChanged: changeConnection,),
              ));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: ref.watch(connectionStatusProvider) ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 10,),
                Text(
                  _connectionTxt,
                  style: TextStyle(
                    color: ref.watch(connectionStatusProvider) ? Colors.green : Colors.red,
                    fontSize: 20,
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Text(
                      'Send a message to start a conversation',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: isLoading ? messages.length + 1 : messages.length,
                    itemBuilder: (context, index) {
                      if (isLoading && index == messages.length) {

                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                            child: IntrinsicWidth(
                              child: IntrinsicHeight(
                                child: SpinKitThreeInOut(
                                  color: Theme.of(context).primaryColor,
                                  size: 18.0,
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      final message = messages[index];
                      return ChatBubble(message: message);
                    },
                  ),
          ),
          MessageInput(
            onSend: (message) {
              ref.read(chatNotifierProvider.notifier).sendMessage(
                message,
                onResponse: (assistantReply) => _sendToLg(assistantReply),
              );
            },
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }
  
  void _sendToLg(String assistantReply) {
    bool isKml = assistantReply.contains('<kml');
    if(!isKml){
      final htmlContent = md.markdownToHtml(assistantReply);
      final content = '''
      <description>
      <![CDATA[
      <div style="font-family: Arial, sans-serif; padding: 10px;">
        $htmlContent
      </div>
      ]]>
      </description>''';
      final kmlToAppear = KMLEntity(name: 'prompt', content: content);
      LGService().sendPrompt(kmlToAppear);
    } else{

    }
  }
}

class MessageInput extends ConsumerStatefulWidget {
  
  final Function(String) onSend;
  final bool isLoading;

  const MessageInput({
    Key? key,
    required this.onSend,
    required this.isLoading,
  }) : super(key: key);

  @override
  ConsumerState<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends ConsumerState<MessageInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    
    if (_controller.text.trim().isNotEmpty && !widget.isLoading) {
      widget.onSend(_controller.text);
      _controller.clear();
    }
    final messages = ref.watch(chatNotifierProvider);
    if (messages.isNotEmpty) {
      // Find the last user message index
      final lastUserIndex = messages.lastIndexWhere((msg) => msg.role == MessageRole.user);
      if (lastUserIndex != -1 && lastUserIndex < messages.length - 1) {
        // The assistant's reply should be the message right after the last user message
        final assistantReply = messages[lastUserIndex + 1];
        if (assistantReply.role == MessageRole.assistant) {
          // This is the assistant's reply to the last user message
          print('Assistant reply: ${assistantReply.content}');
        }
      }
    }
    // print("Last message: ${messages.last.content}");
  }

  void _showKmlExamples() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'KML Request Examples',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildKmlExample('Generate a KML file with the top 5 tourist attractions in Paris'),
                  _buildKmlExample('Create a KML with hiking trails in Yosemite National Park'),
                  _buildKmlExample('Make a KML file of the major tech company headquarters in Silicon Valley'),
                  _buildKmlExample('Generate KML for UNESCO World Heritage sites in Italy'),
                  _buildKmlExample('Create a KML with the best restaurants in Tokyo'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKmlExample(String example) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _controller.text = example;
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(example),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.map_rounded),
            tooltip: 'KML Examples',
            onPressed: _showKmlExamples,
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send_rounded),
            onPressed: widget.isLoading ? null : _sendMessage,
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
}