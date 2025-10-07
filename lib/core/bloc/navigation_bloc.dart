import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:techcare_assessment_app/core/bloc/navigation_event.dart';
import 'package:techcare_assessment_app/core/bloc/navigation_state.dart';
import 'package:injectable/injectable.dart';

/// Manages the bottom navigation bar state and tab selection.
///
/// This BLoC handles which tab is currently selected and controls
/// the visibility of the bottom navigation bar across the app.
@injectable
class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(const NavigationState()) {
    on<NavigationTabChanged>(_onTabChanged);
    on<NavigationHideBottomNavBar>(_onHideBottomNavBar);
    on<NavigationShowBottomNavBar>(_onShowBottomNavBar);
  }

  /// Updates the currently selected tab index when user taps a different tab
  void _onTabChanged(
    NavigationTabChanged event,
    Emitter<NavigationState> emit,
  ) {
    emit(state.copyWith(selectedTab: event.index));
  }

  /// Hides the bottom nav bar - useful when showing full-screen content
  void _onHideBottomNavBar(
    NavigationHideBottomNavBar event,
    Emitter<NavigationState> emit,
  ) {
    emit(state.copyWith(showBottomNav: false));
  }

  /// Shows the bottom nav bar again after it was hidden
  void _onShowBottomNavBar(
    NavigationShowBottomNavBar event,
    Emitter<NavigationState> emit,
  ) {
    emit(state.copyWith(showBottomNav: true));
  }
}
