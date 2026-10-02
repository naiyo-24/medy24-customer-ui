import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'b2b_graphql_provider.dart';
import 'auth_provider.dart';

final shopProfileProvider = FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  final user = ref.watch(authProvider).user;
  if (user?.customerId == null || user?.role != 'retailer') return null;

  final client = await ref.read(b2bGraphQLClientProvider.future);
  
  const query = r'''
    query GetShopProfile($shopId: String!) {
      getShopProfile(shopId: $shopId) {
        shopId
        shopName
        ownerName
        shopImage
        address
        isVerified
        phone
        licenseNumber
        gstinNo
        drugLicenseUpload
        panCardUpload
        registrationCertificateUpload
        bankAccountNo
        bankIfscCode
        bankName
      }
    }
  ''';

  final result = await client.query(
    QueryOptions(
      document: gql(query),
      variables: {'shopId': user!.customerId!},
      fetchPolicy: FetchPolicy.networkOnly,
    ),
  );

  if (result.hasException) {
    throw Exception(result.exception.toString());
  }

  return result.data?['getShopProfile'] as Map<String, dynamic>?;
});
