class NavigationState {
  final int selectedTab;
  final bool showBottomNav;

  const NavigationState({this.selectedTab = 0, this.showBottomNav = true});

  NavigationState copyWith({int? selectedTab,bool? showBottomNav}) {
    return NavigationState(selectedTab: selectedTab ?? this.selectedTab,showBottomNav: showBottomNav ?? this.showBottomNav);
  }
}
