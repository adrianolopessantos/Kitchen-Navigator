class CookingTimerData {
  const CookingTimerData({
    required this.id,
    required this.label,
    required this.totalSeconds,
    required this.remainingSeconds,
    this.running = false,
  });

  final String id;
  final String label;
  final int totalSeconds;
  final int remainingSeconds;
  final bool running;

  bool get complete => remainingSeconds <= 0;

  CookingTimerData copyWith({
    int? remainingSeconds,
    bool? running,
  }) {
    return CookingTimerData(
      id: id,
      label: label,
      totalSeconds: totalSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      running: running ?? this.running,
    );
  }
}
