import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../../../services/token_helper.dart';

class EventApiService {
  static const String baseUrl = 'https://api.welvors.com/api';

  static Future<Map<String, String>> get _headers async {
    final token = await TokenHelper.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>?> getEvents({
    String? eventType,
    String? dateFilter,
    bool? freeOnly,
  }) async {
    try {
      String urlString = '$baseUrl/admin/events/get';
      List<String> queryParams = [];

      if (eventType != null && eventType.isNotEmpty && eventType != 'ALL') {
        queryParams.add('eventType=$eventType');
      }
      if (dateFilter != null && dateFilter.isNotEmpty) {
        queryParams.add('dateFilter=$dateFilter');
      }
      if (freeOnly == true) {
        queryParams.add('freeOnly=true');
      }

      if (queryParams.isNotEmpty) {
        urlString += '?${queryParams.join('&')}';
      }
      final url = Uri.parse(urlString);
      final response = await http.get(url, headers: await _headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        debugPrint('Failed to get events: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error getting events: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getEventDetails(String eventId) async {
    try {
      final url = Uri.parse('$baseUrl/admin/events/details/$eventId');
      final response = await http.get(url, headers: await _headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        debugPrint('Failed to get event details: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error getting event details: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getCheckoutDetails({
    required String eventId,
    required String ticketType,
    required int ticketCount,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/admin/events/$eventId/checkout?ticketType=$ticketType&ticketCount=$ticketCount');
      final response = await http.get(url, headers: await _headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        debugPrint('Failed to get checkout details: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error getting checkout details: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> calculateCheckout({
    required String eventId,
    required List<Map<String, dynamic>> tickets,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/admin/events/$eventId/checkout/calculate');
      final response = await http.post(
        url,
        headers: await _headers,
        body: jsonEncode({'tickets': tickets}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        debugPrint('Failed to calculate checkout: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error calculating checkout: $e');
      return null;
    }
  }
  static Future<Map<String, dynamic>?> createEventOrder({
    required String eventId,
    required int menTicketCount,
    required int womenTicketCount,
    int otherTicketCount = 0,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/payments/order-create');
      final response = await http.post(
        url,
        headers: await _headers,
        body: jsonEncode({
          "purpose": "EVENT_BOOKING",
          "eventId": eventId,
          "menTicketCount": menTicketCount,
          "womenTicketCount": womenTicketCount,
          "otherTicketCount": otherTicketCount,
          "currency": "INR"
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        debugPrint('Failed to create event order: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error creating event order: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getChatConversations() async {
    try {
      final url = Uri.parse('$baseUrl/user/chat/conversations');
      final response = await http.get(url, headers: await _headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        debugPrint('Failed to get chat conversations: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error getting chat conversations: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getMyTickets({String? status}) async {
    try {
      String urlString = '$baseUrl/user/event/my-ticket';
      if (status != null && status.isNotEmpty && status != 'ALL') {
        urlString += '?status=$status';
      }
      final url = Uri.parse(urlString);
      final response = await http.get(url, headers: await _headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        debugPrint('Failed to get my tickets: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error getting my tickets: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> cancelEventBooking({
    required String bookingId,
    required String reason,
    required String comment,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/user/event-bookings/$bookingId/cancel');
      final body = json.encode({
        'reason': reason,
        'comment': comment,
      });

      final response = await http.post(
        url,
        headers: await _headers,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        debugPrint('Failed to cancel event booking: ${response.statusCode} - ${response.body}');
        return {'success': false, 'error': json.decode(response.body)['message'] ?? 'Failed to cancel booking'};
      }
    } catch (e) {
      debugPrint('Error cancelling event booking: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>?> sendEventInvite({
    required String eventId,
    required String receiverId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/user/chat/event/$eventId/invite');
      final body = json.encode({
        'receiverId': receiverId,
      });

      final response = await http.post(
        url,
        headers: await _headers,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        debugPrint('Failed to send invite: ${response.statusCode} - ${response.body}');
        final errorMsg = json.decode(response.body)['message'] ?? 'Failed to send invite';
        return {'success': false, 'error': errorMsg};
      }
    } catch (e) {
      debugPrint('Error sending invite: $e');
      return {'success': false, 'error': e.toString()};
    }
  }
}
