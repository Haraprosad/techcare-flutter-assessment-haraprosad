import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:techcare_assessment_app/core/bloc/navigation_event.dart';
import 'package:techcare_assessment_app/core/bloc/navigation_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(const NavigationState()) {
    on<NavigationTabChanged>(_onTabChanged);
    on<NavigationHideBottomNavBar>(_onHideBottomNavBar);
    on<NavigationShowBottomNavBar>(_onShowBottomNavBar);
  }

  void _onTabChanged(
    NavigationTabChanged event,
    Emitter<NavigationState> emit,
  ) {
    emit(state.copyWith(selectedTab: event.index));
  }

  void _onHideBottomNavBar(
    NavigationHideBottomNavBar event,
    Emitter<NavigationState> emit,
  ) {
    emit(state.copyWith(showBottomNav: false));
  }

  void _onShowBottomNavBar(
    NavigationShowBottomNavBar event,
    Emitter<NavigationState> emit,
  ) {
    emit(state.copyWith(showBottomNav: true));
  }
}
