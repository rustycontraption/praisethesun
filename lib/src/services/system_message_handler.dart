import 'package:flutter/material.dart';
import 'package:praisethesun/src/model/model.dart';
import 'package:praisethesun/src/services/sun_logging.dart';
import 'package:praisethesun/src/widgets/snackbar_message.dart';
import 'package:provider/provider.dart';

class MessageHandler extends StatefulWidget {
  final Widget child;

  const MessageHandler({super.key, required this.child});

  @override
  State<MessageHandler> createState() => _MessageHandlerState();
}

class _MessageHandlerState extends State<MessageHandler> {
  final Logger _logger = SunLogging.getLogger('MessageHandler');
  String? _previousMessage;

  @override
  Widget build(BuildContext context) {
    return Consumer<SunLocationModel>(
      builder: (context, sunModel, _) {
        final errorMessage = sunModel.errorMessage;
        final infoMessage = sunModel.infoMessage;
        _logger.info('Checking for error messages: $errorMessage');

        if (errorMessage != null && errorMessage != _previousMessage) {
          _previousMessage = errorMessage;
          _logger.info('Displaying error message: $errorMessage');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              showErrorSnackBar(context, errorMessage);
              sunModel.clearSystemMessage();
              _previousMessage = null;
            }
          });
        } else if (errorMessage == null) {
          _previousMessage = null;
        }

        if (infoMessage != null && infoMessage != _previousMessage) {
          _previousMessage = infoMessage;
          _logger.info('Displaying info message: $infoMessage');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              showInfoSnackBar(context, infoMessage);
              sunModel.clearSystemMessage();
              _previousMessage = null;
            }
          });
        } else if (infoMessage == null) {
          _previousMessage = null;
        }

        return widget.child;
      },
    );
  }
}
