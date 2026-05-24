import 'package:flutter_test/flutter_test.dart';
import 'package:flymap/ui/screens/create_flight/flight_number_search/viewmodel/flight_number_validator.dart';

void main() {
  group('FlightNumberValidator', () {
    test('accepts plausible flight numbers', () {
      expect(FlightNumberValidator.isValid('BA117'), isTrue);
      expect(FlightNumberValidator.isValid(' u2 5528 '), isTrue);
      expect(FlightNumberValidator.isValid('VS3'), isTrue);
    });

    test('rejects invalid flight numbers', () {
      expect(FlightNumberValidator.isValid('5746'), isFalse);
      expect(FlightNumberValidator.isValid('BA'), isFalse);
      expect(FlightNumberValidator.isValid('ABCDEFGH1'), isFalse);
      expect(FlightNumberValidator.isValid('BA-117'), isFalse);
    });
  });
}
