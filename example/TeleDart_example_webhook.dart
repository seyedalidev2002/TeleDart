import 'dart:io' as io;
import 'dart:io' show Platform;

import 'package:path/path.dart' as Path;
import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';
import 'package:teledart/model.dart';

void main() {
  final Map<String, String> envVars = Platform.environment;

  TeleDart teledart = TeleDart(Telegram(envVars['BOT_TOKEN']), Event());

  teledart.setupWebhook(envVars['HOST_URL'], envVars['BOT_TOKEN'],
      port: 8443,
      privateKey: new io.File(envVars['KEY_PATH']),
      certificate: new io.File(envVars['CERT_PATH']));

  teledart.startFetching(webhook: true);

  // You can listen to messages like this
  teledart.onMessage(entityType: 'bot_command', keyword: 'start').listen(
      (message) =>
          teledart.telegram.sendMessage(message.from.id, 'Hello TeleDart!'));

  // Or using short cuts
  teledart
      .onCommand('short')
      .listen(((message) => teledart.replyMessage(message, 'This works too!')));

  // You can even filter streams even more diverse with stream processing methods
  // See: https://www.dartlang.org/tutorials/language/streams#methods-that-modify-a-stream
  teledart
      .onMessage(keyword: 'dart')
      .where((message) => message.text.contains('telegram'))
      .listen((message) => teledart.replyPhoto(
          message,
          // io.File('example/dart_bird_catchs_telegram.png'),
          'https://raw.githubusercontent.com/DinoLeung/TeleDart/master/example/dart_bird_catchs_telegram.png',
          caption: 'This is how the Dart Bird and Telegram are met'));

  // Inline mode.
  teledart
      .onInlineQuery()
      .listen((inlineQuery) => teledart.answerInlineQuery(inlineQuery, [
            InlineQueryResultArticle()
              ..id = 'ping'
              ..title = 'ping'
              ..input_message_content = (InputTextMessageContent()
                ..message_text = '*pong*'
                ..parse_mode = 'markdown'),
            InlineQueryResultArticle()
              ..id = 'ding'
              ..title = 'ding'
              ..input_message_content = (InputTextMessageContent()
                ..message_text = '_dong_'
                ..parse_mode = 'markdown')
          ]));
}
