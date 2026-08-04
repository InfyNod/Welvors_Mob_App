void main() {
  int? id = 2;
  var result = {
    'languageIds': id != null ? [id] : <int>[],
    'motherTongue': 'Hindi',
  };
  
  try {
    List<int> ids = result['languageIds'] as List<int>;
    print("Success: $ids");
  } catch (e) {
    print("Error: $e");
  }
}
