import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/food_model.dart';

class UsdaService {
  static const String apiKey = 'WInbB4ZduEAzlemnXuoayedCWQtKwd3j6qtNUi5L';
  static const String _baseUrl =
      'https://api.nal.usda.gov/fdc/v1/foods/search';

  Future<List<FoodModel>> searchFood(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final uri = Uri.parse('$_baseUrl?query=${Uri.encodeComponent(query)}&api_key=$apiKey');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> foods = data['foods'] ?? [];

        return foods
            .take(10)
            .map((food) => FoodModel.fromUsdaJson(food as Map<String, dynamic>))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
