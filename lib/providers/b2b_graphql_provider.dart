import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_url.dart';

final b2bGraphQLClientProvider = FutureProvider<GraphQLClient>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final userJson = prefs.getString('user');
  String? token;

  if (userJson != null) {
    try {
      final user = UserModel.fromJson(userJson);
      token = user.token;
    } catch (e) {
      // Ignore parse errors
    }
  }

  final HttpLink httpLink = HttpLink(
    ApiUrl.graphql, // Assuming ApiUrl.graphql is defined in api_url.dart
  );

  final AuthLink authLink = AuthLink(
    getToken: () async => token != null ? 'Bearer $token' : null,
  );

  final Link link = authLink.concat(httpLink);

  return GraphQLClient(
    cache: GraphQLCache(store: InMemoryStore()),
    link: link,
  );
});
