import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../config.dart';
import '../models/message.dart';
import '../services/gemma_service.dart';

part 'gemma_provider.g.dart';

final connectionStatusProvider = StateProvider<bool>((ref) => false);


@riverpod
GemmaService gemmaService(GemmaServiceRef ref) {
  return GemmaService(
    apiKey: AppConfig.apiKey
  );
}

@riverpod
class ChatNotifier extends _$ChatNotifier {
  @override
  List<Message> build() {
    return [];
  }

  Future<void> sendMessage(String message, {void Function(String response)? onResponse}) async {
    if (message.trim().isEmpty) return;

    
    final userMessage = Message(
      content: message,
      role: MessageRole.user,
    );
    
    state = [...state, userMessage];

    try {
      
      final isKmlRequest = message.toLowerCase().contains("kml");
      String response;
      
      // if (isKmlRequest) {
      //   final gemmaService = ref.read(gemmaServiceProvider);
      //   response = await gemmaService.generateKmlResponse(
      //     message
      //   );
      // } else {
        final gemmaService = ref.read(gemmaServiceProvider);
        response = await gemmaService.generateResponse(
          message.trimRight(),
          conversationHistory: state.length > 1 ? state.sublist(0, state.length - 1) : null,
        );
      // }
      
      final assistantMessage = Message(
        content: response,
        role: MessageRole.assistant,
        containsKml: response.contains("<kml") && response.contains("</kml>"),
      );
      
      state = [...state, assistantMessage];

      if (onResponse != null) {
        onResponse(response);
      }
    } catch (e) {
      
      final errorMessage = Message(
        content: 'Sorry, I encountered an error: ${e.toString()}',
        role: MessageRole.assistant,
      );
      
      state = [...state, errorMessage];
    }
  }

  void clearChat() {
    state = [];
  }
}

@riverpod
class IsLoading extends _$IsLoading {
  @override
  bool build() {
    final messages = ref.watch(chatNotifierProvider);
    
    
    if (messages.isNotEmpty && messages.last.role == MessageRole.user) {
      return true;
    }
    
    return false;
  }
}