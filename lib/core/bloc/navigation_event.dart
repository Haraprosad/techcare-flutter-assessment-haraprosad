import 'package:equatable/equatable.dart';

abstract class NavigationEvent extends Equatable{}

class NavigationTabChanged extends NavigationEvent {
  final int index;
  
  NavigationTabChanged(this.index);
  
  @override
  List<Object?> get props => [index];
}

class NavigationHideBottomNavBar extends NavigationEvent{
  @override
  List<Object?> get props => [];

}

class NavigationShowBottomNavBar extends NavigationEvent {
  @override
  List<Object?> get props => [];
}
