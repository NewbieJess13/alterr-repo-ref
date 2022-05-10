import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';

class VideoProgressBar extends StatefulWidget {
  final VideoPlayerController? controller;
  final Function()? onDragStart;
  final Function()? onDragEnd;
  final Function()? onDragUpdate;
  final Function()? onEnd;
  final Function()? onBuffer;
  final Function? onPlay;
  final Function()? onInitialize;
  final BuildContext? context;

  VideoProgressBar(
    this.controller, {
    this.onDragEnd,
    this.onDragStart,
    this.onDragUpdate,
    this.onEnd,
    this.onBuffer,
    this.onPlay,
    this.onInitialize,
    this.context,
    Key? key,
  }) : super(key: key);

  @override
  _VideoProgressBarState createState() {
    return _VideoProgressBarState();
  }
}

class _VideoProgressBarState extends State<VideoProgressBar> {
  void listener() {
    if (!mounted) return;

    int dur = controller!.value.duration.inMilliseconds;
    int pos = controller!.value.position.inMilliseconds;

    if (dur > 0 && dur - pos < 1 && !controller!.value.isPlaying) {
      widget.onEnd!();
    } else {
      if (controller!.value.isPlaying) {
        setState(() {});
        widget.onPlay!(controller!.value.position);
      } else if (controller!.value.isBuffering) {
        widget.onBuffer!();
      }

      if (controller!.value.isInitialized) {
        widget.onInitialize!();
      }
    }
  }

  bool _controllerWasPlaying = false;

  VideoPlayerController? get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    controller?.addListener(listener);
  }

  @override
  void deactivate() {
    controller!.removeListener(listener);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    void seekToRelativePosition(Offset globalPosition) {
      final box = context.findRenderObject() as RenderBox;
      final Offset tapPos = box.globalToLocal(globalPosition);
      final double relative = tapPos.dx / box.size.width;
      final Duration position = controller!.value.duration * relative;
      controller!.seekTo(position);
    }

    return GestureDetector(
      onHorizontalDragStart: (DragStartDetails details) {
        if (!controller!.value.isInitialized) {
          return;
        }
        _controllerWasPlaying = controller!.value.isPlaying;
        if (_controllerWasPlaying) {
          controller?.pause();
        }

        widget.onDragStart?.call();
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        if (!controller!.value.isInitialized) {
          return;
        }
        seekToRelativePosition(details.globalPosition);

        widget.onDragUpdate?.call();
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        if (_controllerWasPlaying) {
          controller?.play();
        }

        widget.onDragEnd?.call();
      },
      onTapDown: (TapDownDetails details) {
        if (!controller!.value.isInitialized) {
          return;
        }
        seekToRelativePosition(details.globalPosition);
      },
      child: Center(
        child: Container(
          height: MediaQuery.of(context).size.height / 2,
          width: MediaQuery.of(context).size.width,
          color: Colors.transparent,
          child: CustomPaint(
            painter: _ProgressBarPainter(
                controller!.value, Theme.of(widget.context!).primaryColor),
          ),
        ),
      ),
    );
  }
}

class _ProgressBarPainter extends CustomPainter {
  _ProgressBarPainter(this.value, this.thumbColor);

  VideoPlayerValue value;
  Color thumbColor;

  @override
  bool shouldRepaint(CustomPainter painter) {
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    const height = 3.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(0.0, size.height / 2),
          Offset(size.width, size.height / 2 + height),
        ),
        const Radius.circular(4.0),
      ),
      Paint()..color = Colors.white.withOpacity(0.05),
    );
    if (!value.isInitialized) {
      return;
    }
    final double playedPartPercent =
        value.position.inMilliseconds / value.duration.inMilliseconds;
    final double playedPart =
        playedPartPercent > 1 ? size.width : playedPartPercent * size.width;
    for (final DurationRange range in value.buffered) {
      final double start = range.startFraction(value.duration) * size.width;
      final double end = range.endFraction(value.duration) * size.width;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromPoints(
            Offset(start, size.height / 2),
            Offset(end, size.height / 2 + height),
          ),
          const Radius.circular(0),
        ),
        Paint()..color = Colors.white.withOpacity(0.5),
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(0.0, size.height / 2),
          Offset(playedPart, size.height / 2 + height),
        ),
        const Radius.circular(0),
      ),
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(Offset(playedPart, size.height / 2 + height / 2), 7,
        Paint()..color = thumbColor);
  }
}
