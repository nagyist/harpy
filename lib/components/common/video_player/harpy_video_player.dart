import 'package:flutter/material.dart';
import 'package:harpy/components/common/video_player/harpy_video_player_model.dart';
import 'package:harpy/components/common/video_player/overlay/static_video_player_overlay.dart';
import 'package:harpy/components/common/video_player/video_thumbnail.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

/// The size for icons appearing in the center of the video player
const double kVideoPlayerCenterIconSize = 48;

typedef OnVideoPlayerTap = void Function(HarpyVideoPlayerModel model);

/// Builds a [VideoPlayer] with a [VideoPlayerOverlay] to control the video.
///
/// When built initially, the video will not be initialized and instead the
/// [thumbnail] url is used to build an image in place of the video. After being
/// tapped the video will be initialized and starts playing.
///
/// A [HarpyVideoPlayerModel] is used to control the video.
class HarpyVideoPlayer extends StatefulWidget {
  const HarpyVideoPlayer.fromUrl(
    this.url, {
    this.thumbnail,
    this.thumbnailAspectRatio,
    this.onVideoPlayerTap,
  }) : model = null;

  const HarpyVideoPlayer.fromModel(
    this.model, {
    this.thumbnail,
    this.thumbnailAspectRatio,
    this.onVideoPlayerTap,
  }) : url = null;

  final String url;

  /// An optional url to a thumbnail that is built when the video is not
  /// initialized.
  final String thumbnail;
  final double thumbnailAspectRatio;

  final HarpyVideoPlayerModel model;
  final OnVideoPlayerTap onVideoPlayerTap;

  @override
  _HarpyVideoPlayerState createState() => _HarpyVideoPlayerState();
}

class _HarpyVideoPlayerState extends State<HarpyVideoPlayer> {
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller =
        widget.model?.controller ?? VideoPlayerController.network(widget.url);
  }

  @override
  void dispose() {
    if (widget.model == null) {
      _controller.dispose();
    }

    super.dispose();
  }

  /// Builds a [VideoThumbnail] that will start to initialize the video when
  /// tapped.
  Widget _buildUninitialized(HarpyVideoPlayerModel model) {
    return VideoThumbnail(
      thumbnail: widget.thumbnail,
      aspectRatio: widget.thumbnailAspectRatio,
      icon: Icons.play_arrow,
      initializing: model.initializing,
      onTap: () {
        model.initialize();
        // widget.onVideoPlayerTap(model);
      },
    );
  }

  Widget _buildVideo(HarpyVideoPlayerModel model) {
    // todo: change overlay to be static and not use a gesture detector

    return Stack(
      children: <Widget>[
        // let the top / bottom overflow when the height is constrained
        OverflowBox(
          minHeight: 0,
          maxHeight: double.infinity,
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
        ),
        StaticVideoPlayerOverlay(model),
      ],
    );
  }

  Widget _builder(BuildContext context, Widget child) {
    final HarpyVideoPlayerModel model = HarpyVideoPlayerModel.of(context);

    if (!model.initialized) {
      return _buildUninitialized(model);
    } else {
      return _buildVideo(model);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.model != null) {
      return ChangeNotifierProvider<HarpyVideoPlayerModel>.value(
        value: widget.model,
        builder: _builder,
      );
    } else {
      return ChangeNotifierProvider<HarpyVideoPlayerModel>(
        create: (BuildContext context) => HarpyVideoPlayerModel(_controller),
        builder: _builder,
      );
    }
  }
}
