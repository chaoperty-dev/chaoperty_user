import 'dart:async';
import 'dart:convert';
import 'dart:io';

const _port = 8081;

bool _isAllowedImageUrl(Uri uri) {
  if (uri.scheme != 'https') return false;

  if (uri.host == 'choice-pics.chaoperties.com') {
    return uri.path.startsWith('/Choice/chao_api/');
  }

  return uri.host == 'chaoperties.com' &&
      (uri.path.startsWith('/Choice/chao_api/files/') ||
          uri.path == '/Choice/chao_api/gen_qr_img.php');
}

Future<void> main() async {
  final logDirectory = Directory('tool/debug_logs');
  await logDirectory.create(recursive: true);

  final server = await HttpServer.bind(InternetAddress.anyIPv4, _port);
  stdout.writeln('Debug logger listening on http://0.0.0.0:$_port/log');
  stdout.writeln('Saved logs: ${logDirectory.absolute.path}');

  await for (final request in server) {
    request.response.headers
      ..set(HttpHeaders.accessControlAllowOriginHeader, '*')
      ..set(HttpHeaders.accessControlAllowMethodsHeader, 'GET, POST, OPTIONS')
      ..set(HttpHeaders.accessControlAllowHeadersHeader, 'Content-Type')
      ..set('Access-Control-Allow-Private-Network', 'true');

    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.noContent;
      await request.response.close();
      continue;
    }

    if (request.method == 'GET' && request.uri.path == '/health') {
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode({'status': 'ok'}));
      await request.response.close();
      continue;
    }

    if (request.method == 'GET' && request.uri.path == '/image') {
      final imageUrl = request.uri.queryParameters['url'];
      final imageUri = imageUrl == null ? null : Uri.tryParse(imageUrl);

      if (imageUri == null || !_isAllowedImageUrl(imageUri)) {
        request.response.statusCode = HttpStatus.badRequest;
        await request.response.close();
        continue;
      }

      final client = HttpClient();
      try {
        final upstreamRequest = await client.getUrl(imageUri);
        final upstreamResponse = await upstreamRequest.close();
        final contentType = upstreamResponse.headers.contentType;

        if (upstreamResponse.statusCode != HttpStatus.ok ||
            contentType == null ||
            !contentType.primaryType.startsWith('image')) {
          request.response.statusCode = HttpStatus.badGateway;
          await upstreamResponse.drain();
          await request.response.close();
          continue;
        }

        request.response.headers.contentType = contentType;
        request.response.headers.set(HttpHeaders.cacheControlHeader, 'no-store');
        await request.response.addStream(upstreamResponse);
      } catch (error) {
        stderr.writeln('Image proxy error: $error');
        request.response.statusCode = HttpStatus.badGateway;
      } finally {
        client.close(force: true);
      }
      await request.response.close();
      continue;
    }

    if (request.method != 'POST' || request.uri.path != '/log') {
      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
      continue;
    }

    try {
      final body = await utf8.decoder.bind(request).join();
      final payload = jsonDecode(body) as Map<String, dynamic>;
      final time = payload['time']?.toString() ?? DateTime.now().toIso8601String();
      final source = payload['source']?.toString() ?? 'Unknown';
      final error = payload['error']?.toString() ?? 'Unknown error';
      final fileDate = DateTime.now().toIso8601String().substring(0, 10);
      final logFile = File('${logDirectory.path}/mobile-$fileDate.ndjson');

      await logFile.writeAsString('$body\n', mode: FileMode.append, flush: true);
      stdout.writeln('[$time] $source: $error');
      request.response.statusCode = HttpStatus.noContent;
    } catch (error) {
      stderr.writeln('Invalid debug log: $error');
      request.response.statusCode = HttpStatus.badRequest;
    }
    await request.response.close();
  }
}
