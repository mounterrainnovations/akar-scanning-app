/// Simple singleton to hold the currently selected event across screens.
/// No external dependencies needed — upgrade to Riverpod later if needed.
class AppState {
  AppState._();
  static final AppState instance = AppState._();

  String? selectedEventId;
  String? selectedEventName;
  String? loggedInEmail;
}
