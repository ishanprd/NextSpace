import 'dart:math';

String generateVerificationCode() {
  final random = Random();
  const length = 6; // Length of the code
  const characters = '0123456789'; // Digits only
  return List.generate(
      length, (index) => characters[random.nextInt(characters.length)]).join();
}
