/// [url] if it points into the public avatars bucket of the backend at
/// [apiUrl], else null.
///
/// A profile's `avatar_url` is text its owner writes, and the partner's app
/// loads it: an address on another server would hand that server the
/// partner's IP address. The app itself only ever stores URLs from
/// `getPublicUrl` on its own bucket.
String? trustedAvatarUrl(String? url, {required String apiUrl}) {
  if (url == null || apiUrl.isEmpty) return null;
  final base = apiUrl.endsWith('/')
      ? apiUrl.substring(0, apiUrl.length - 1)
      : apiUrl;
  final prefix = '$base/storage/v1/object/public/avatars/';
  if (!url.startsWith(prefix) || url.contains('..')) return null;
  return url;
}
