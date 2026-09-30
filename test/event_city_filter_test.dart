import 'package:flutter_test/flutter_test.dart';
import 'package:country_state_city/country_state_city.dart';

bool matchesCity(dynamic event, String? targetCity) {
  if (targetCity == null ||
      targetCity.isEmpty ||
      targetCity.toLowerCase() == 'all cities' ||
      targetCity.toLowerCase() == 'all') {
    return true;
  }

  final selectedLower = targetCity.toLowerCase().trim();
  final eventCity = (event['city'] ?? '').toString().toLowerCase().trim();
  final fullAddress = (event['fullAddress'] ?? '').toString().toLowerCase().trim();
  final venueAddress = (event['venueAddress'] ?? '').toString().toLowerCase().trim();
  final addressComb = '$fullAddress $venueAddress';

  // Direct match with city field
  if (eventCity.isNotEmpty) {
    if (eventCity == selectedLower ||
        eventCity.contains(selectedLower) ||
        selectedLower.contains(eventCity)) {
      return true;
    }
  }

  // Delhi NCR special handling
  if (selectedLower.contains('delhi') || selectedLower.contains('ncr')) {
    final ncrKeywords = ['delhi', 'ncr', 'noida', 'gurgaon', 'gurugram', 'ghaziabad', 'faridabad'];
    for (var kw in ncrKeywords) {
      if (eventCity.contains(kw) || addressComb.contains(kw)) {
        return true;
      }
    }
  }

  // Bengaluru / Bangalore special handling
  if (selectedLower.contains('bengaluru') || selectedLower.contains('bangalore')) {
    if (eventCity.contains('bengaluru') || eventCity.contains('bangalore') ||
        addressComb.contains('bengaluru') || addressComb.contains('bangalore')) {
      return true;
    }
  }

  // Mumbai / Suburban special handling
  if (selectedLower == 'mumbai') {
    if (eventCity.contains('mumbai') || addressComb.contains('mumbai') ||
        addressComb.contains('bandra') || addressComb.contains('andheri') ||
        addressComb.contains('colaba') || addressComb.contains('parel') ||
        addressComb.contains('juhu') || addressComb.contains('worli')) {
      return true;
    }
  }

  return addressComb.contains(selectedLower);
}

void main() {
  group('Event City Matching Tests', () {
    final mockEvents = [
      {
        'id': '1',
        'city': 'Pune',
        'fullAddress': 'Sinhagad Ghat Road, Thoptewadi, Pune, Maharashtra 411025',
      },
      {
        'id': '2',
        'city': 'Mumbai',
        'fullAddress': 'Skyline Rooftop, Bandra West, Mumbai, Maharashtra',
      },
      {
        'id': '3',
        'city': 'Noida',
        'fullAddress': 'Sector 18, Noida, Uttar Pradesh',
      },
      {
        'id': '4',
        'city': 'Bangalore',
        'fullAddress': 'Indiranagar, Bangalore, Karnataka',
      },
    ];

    test('Filter by Pune returns only Pune events', () {
      final puneEvents = mockEvents.where((e) => matchesCity(e, 'Pune')).toList();
      expect(puneEvents.length, 1);
      expect(puneEvents.first['city'], 'Pune');
    });

    test('Filter by Mumbai returns Mumbai events', () {
      final mumbaiEvents = mockEvents.where((e) => matchesCity(e, 'Mumbai')).toList();
      expect(mumbaiEvents.length, 1);
      expect(mumbaiEvents.first['city'], 'Mumbai');
    });

    test('Filter by Delhi NCR matches Noida event', () {
      final ncrEvents = mockEvents.where((e) => matchesCity(e, 'Delhi NCR')).toList();
      expect(ncrEvents.length, 1);
      expect(ncrEvents.first['city'], 'Noida');
    });

    test('Filter by Bengaluru matches Bangalore event', () {
      final blrEvents = mockEvents.where((e) => matchesCity(e, 'Bengaluru')).toList();
      expect(blrEvents.length, 1);
      expect(blrEvents.first['city'], 'Bangalore');
    });

    test('Filter by All Cities returns all events', () {
      final allEvents = mockEvents.where((e) => matchesCity(e, 'All Cities')).toList();
      expect(allEvents.length, 4);
    });

    test('Filter by empty city returns all events', () {
      final allEvents = mockEvents.where((e) => matchesCity(e, '')).toList();
      expect(allEvents.length, 4);
    });

    test('Filter by city with no events returns empty list', () {
      final nashikEvents = mockEvents.where((e) => matchesCity(e, 'Nashik')).toList();
      expect(nashikEvents.isEmpty, true);
    });

    test('CityDataService loads dynamically without hardcoded list', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final states = await getStatesOfCountry('IN');
      final stateMap = {for (var s in states) s.isoCode: s.name};
      final rawCities = await getCountryCities('IN');

      expect(rawCities.length, greaterThan(1000));
      expect(states.length, greaterThan(30));

      final maharashtraCities = rawCities.where((c) => stateMap[c.stateCode] == 'Maharashtra').toList();
      expect(maharashtraCities.length, greaterThan(50));
      final pune = maharashtraCities.where((c) => c.name.toLowerCase() == 'pune').firstOrNull;
      expect(pune, isNotNull);
    });
  });
}
