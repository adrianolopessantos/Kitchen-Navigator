import 'package:flutter_test/flutter_test.dart';
import 'package:kitchen_navigator/core/services/voice_cooking_service.dart';

void main() {
  test('voice cooking commands are parsed without native plugins', () {
    expect(
      VoiceCookingService.parseCommand('next step'),
      CookingVoiceCommand.next,
    );
    expect(
      VoiceCookingService.parseCommand('please repeat'),
      CookingVoiceCommand.repeat,
    );
    expect(
      VoiceCookingService.parseCommand('start timer'),
      CookingVoiceCommand.startTimer,
    );
    expect(
      VoiceCookingService.parseCommand('pause timer'),
      CookingVoiceCommand.pauseTimer,
    );
    expect(
      VoiceCookingService.parseCommand('add minute'),
      CookingVoiceCommand.addMinute,
    );
  });
}
