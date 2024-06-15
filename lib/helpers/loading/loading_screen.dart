import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mynotes_x/helpers/loading/loading_controller.dart';

class LoadingScreen {
  LoadingScreen._sharedInstance();
  static final _shared = LoadingScreen._sharedInstance();
  factory LoadingScreen() => _shared;

  LoadingController? loadingController;

  void show({required BuildContext context, required String text}) {
    if (loadingController?.updateLoadingScreen(text) ?? false) {
      return;
    } else {
      loadingController = showOverlay(
        context: context,
        text: text,
      );
    }
  }

  void hide() {
    loadingController?.closeLoadinScreen();
    loadingController = null;
  }

  LoadingController showOverlay({
    required BuildContext context,
    required String text,
  }) {
    // ignore: no_leading_underscores_for_local_identifiers
    final _text = StreamController<String>();
    _text.add(text);

    final state = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    final overlay = OverlayEntry(
      builder: (context) {
        return Material(
          color: Theme.of(context).colorScheme.inversePrimary.withAlpha(150),
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxHeight: size.height * 0.8,
                maxWidth: size.width * 0.8,
                minWidth: size.width * 0.5,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  12,
                ),
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    StreamBuilder(
                      stream: _text.stream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text(
                            snapshot.data as String,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                            ),
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    state.insert(overlay);
    return LoadingController(
      updateLoadingScreen: (text) {
        _text.add(text);
        return true;
      },
      closeLoadinScreen: () {
        _text.close();
        overlay.remove();
        return true;
      },
    );
  }
}
