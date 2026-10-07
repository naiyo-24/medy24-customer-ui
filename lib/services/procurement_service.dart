import 'dart:convert';
import 'package:dio/dio.dart';
import 'api_url.dart';

class ProcurementService {
  static final Dio _dio = Dio(BaseOptions(baseUrl: ApiUrl.baseUrl));

  static Future<dynamic> checkout(String token, String manufacturerId, List<Map<String, dynamic>> items) async {
    const String mutation = r'''
      mutation CheckoutProcurementDirect($manufacturerId: String!, $itemsJsonStr: String!, $paymentTerms: String!) {
        checkoutProcurementDirect(
          manufacturerId: $manufacturerId, 
          itemsJsonStr: $itemsJsonStr, 
          paymentTerms: $paymentTerms
        ) {
          dpoId
          subtotal
          totalInvoiceAmount
          dpoStatus
        }
      }
    ''';
    
    final response = await _dio.post(
      '/graphql',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
      data: {
        'query': mutation,
        'variables': {
          'manufacturerId': manufacturerId,
          'itemsJsonStr': jsonEncode(items),
          'paymentTerms': 'prepaid',
        },
      },
    );
    
    if (response.data['errors'] != null) {
      throw Exception(response.data['errors'][0]['message']);
    }
    return response.data['data']['checkoutProcurementDirect'];
  }
  
  static Future<List<dynamic>> getHistory(String token) async {
    const String query = r'''
      query GetProcurementOrders {
        getProcurementOrders {
          dpoId
          subtotal
          totalInvoiceAmount
          dpoStatus
          paymentTerms
          createdAt
          manufacturer {
            companyName
          }
          items {
            medicineId
            batchNumber
            qtyCartons
            ptd
          }
        }
      }
    ''';
    
    final response = await _dio.post(
      '/graphql',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
      data: {'query': query},
    );
    
    if (response.data['errors'] != null) {
      throw Exception(response.data['errors'][0]['message']);
    }
    return response.data['data']['getProcurementOrders'];
  }
}
