import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class GemmaServiceException implements Exception {
  final String message;
  final int? statusCode;

  GemmaServiceException(this.message, {this.statusCode});

  @override
  String toString() => 'GemmaServiceException: $message${statusCode != null ? ' (Status code: $statusCode)' : ''}';
}

class GemmaService {
  final String apiKey;
  
  
  final String apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemma-3-4b-it:generateContent';

  GemmaService({required this.apiKey});

  // Future<String> generateKmlResponse(
  //   String originalPrompt, 
  //   {List<Message>? conversationHistory}
  // ) async {
  //   String contextPrompt = '';


  //   final enhancedPrompt = """
  // **KML Generation Guidelines**
  // $contextPrompt

  // I need you to generate a valid KML file based on this request: "$originalPrompt"

  // Please follow these guidelines:
  // 1. The KML should contain proper XML structure with the KML namespace
  // 2. Include meaningful placemarks with accurate coordinates 
  // 3. Each placemark should have a name, description, and point with coordinates
  // 4. Coordinates should be in the format: longitude,latitude,0
  // 5. Only respond with the KML code, nothing else
  // 6. Remove the xml notation that you give using ```xml
  // 7. Include follow up question too

  // Here's the expected format:
  // <?xml version="1.0" encoding="UTF-8"?>
  // <kml xmlns="http://www.opengis.net/kml/2.2">
  //   <Document>
  //     <name>[Title]</name>
  //     <description>[Description]</description>
      
  //     <Placemark>
  //       <name>[Location Name]</name>
  //       <description>[Details about this location]</description>
  //       <Point>
  //         <coordinates>[longitude],[latitude],0</coordinates>
  //       </Point>
  //     </Placemark>
  //     <!-- More placemarks as needed -->
  //   </Document>
  // </kml>
  // """;

  //   return await generateResponse(enhancedPrompt);
  // }

  Future<String> generateResponse(String prompt, {List<Message>? conversationHistory}) async {
    try {
      
      final contents = [];
      
      if (conversationHistory != null && conversationHistory.isNotEmpty) {
        for (final message in conversationHistory) {
          contents.add({
            'role': message.role == MessageRole.user ? 'user' : 'model',
            'parts': [{'text': message.content}]
          });
        }
      }
      
      
      contents.add({
        'role': 'user',
        'parts': [{'text': prompt}]
      });

      // print("Prompt is: $prompt");

      final response = await http.post(
        Uri.parse('$apiUrl?key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': contents,
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 1000,
            'topP': 0.95,
            'topK': 40
          }
        }),
      );

      print("Reponse is: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        
        final candidates = data['candidates'];
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          if (content != null && content['parts'] != null && content['parts'].isNotEmpty) {
            return content['parts'][0]['text'] ?? 'No response generated';
          }
        }
        return 'Failed to parse response';
      } else {
        throw GemmaServiceException(
          'Failed to get response from API', 
          statusCode: response.statusCode
        );
      }
    } catch (e) {
      if (e is GemmaServiceException) {
        rethrow;
      }
      throw GemmaServiceException('Error connecting to API: $e');
    }
  }
}