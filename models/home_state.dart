import 'home_data.dart';

enum HomeStatus {
  initial,
  loading,
  loaded,
  refreshing,
  loadingMore,
  empty,
  error,
}

class HomeState {
  final HomeStatus status;
  final HomeData? data;
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.data,
    this.errorMessage,
  });

  bool get isLoading => status == HomeStatus.loading;

  bool get isRefreshing => status == HomeStatus.refreshing;

  bool get isLoadingMore => status == HomeStatus.loadingMore;

  bool get hasError => status == HomeStatus.error;

  bool get isLoaded => status == HomeStatus.loaded;

  bool get isEmpty =>
      status == HomeStatus.empty ||
      (status == HomeStatus.loaded &&
          data != null &&
          !data!.hasPosts);

  HomeState copyWith({
    HomeStatus? status,
    HomeData? data,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}