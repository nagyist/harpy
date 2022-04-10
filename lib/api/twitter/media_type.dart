import 'package:mime_type/mime_type.dart';

/// The [MediaType] as it is returned in from twitter.
const kMediaPhoto = 'photo';
const kMediaVideo = 'video';
const kMediaGif = 'animated_gif';

/// The type of media that can be attached to a tweet.
enum MediaType {
  image,
  gif,
  video,
}

/// Uses [mime] to find the [MediaType] from a file path.
MediaType? mediaTypeFromPath(String? path) {
  final mimeType = mime(path);

  if (mimeType == null) {
    return null;
  } else if (mimeType.startsWith('video')) {
    return MediaType.video;
  } else if (mimeType == 'image/gif') {
    return MediaType.gif;
  } else if (mimeType.startsWith('image')) {
    return MediaType.image;
  } else {
    return null;
  }
}
