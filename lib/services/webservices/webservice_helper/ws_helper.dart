import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:retry/retry.dart';

Future httpWrapper(var httptype,
    {Map<String, String> headers, String name}) async {
  final r = RetryOptions(maxAttempts: 5);
  try {
    final response = await r.retry(
      () => httptype.timeout(Duration(seconds: 5)),
      // Retry on SocketException or TimeoutException
      retryIf: (e) {
        print("Failed because $e, ${name ?? ''}");
        return e is SocketException || e is TimeoutException;
      },
    );

    return response;
  } catch (e) {
    print("FAILLED");
    throw (e);
  }
}
