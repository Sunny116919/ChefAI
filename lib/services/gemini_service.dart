import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  final String _apiKey = 'AIzaSyBT5XfKrT5_9WjGJJIM7UnwfGPuNDop0LM';

  Future<String> generateRecipe(String ingredients) async {
    if (_apiKey.isEmpty) {
      throw Exception("Gemini API key is missing.");
    }

    final model = GenerativeModel(
      model: 'models/gemini-1.5-flash',
      apiKey: _apiKey,
    );

    final prompt =
        '''
Suggest a healthy, easy-to-cook recipe using these ingredients: $ingredients.
Include:
- Recipe name
- Ingredients list
- Step-by-step instructions
- Cooking time
- calories
- protien
''';

    final content = [Content.text(prompt)];

    final response = await model.generateContent(content);
    return response.text ?? 'No recipe generated.';
  }
}
