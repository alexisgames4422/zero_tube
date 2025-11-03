class DownloadProgress {
  const DownloadProgress({this.percent, this.message});

  final double? percent;
  final String? message;
}

class DownloadState {
  const DownloadState._({
    required this.isDownloading,
    required this.completed,
    this.errorMessage,
  });

  final bool isDownloading;
  final bool completed;
  final String? errorMessage;

  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  factory DownloadState.idle() {
    return const DownloadState._(isDownloading: false, completed: false);
  }

  factory DownloadState.inProgress() {
    return const DownloadState._(isDownloading: true, completed: false);
  }

  factory DownloadState.completed() {
    return const DownloadState._(isDownloading: false, completed: true);
  }

  factory DownloadState.failed(String message) {
    return DownloadState._(isDownloading: false, completed: false, errorMessage: message);
  }
}
