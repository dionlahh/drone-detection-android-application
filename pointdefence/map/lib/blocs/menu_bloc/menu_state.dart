part of 'menu_bloc.dart';

abstract class MenuState extends Equatable {
  const MenuState();

  @override
  List<Object> get props => [];
}

class MenuInitial extends MenuState {}

class MainMenuState extends MenuState {}

class MarkerMenuState extends MenuState {}

class CircleMenuState extends MenuState {}

class PolygonMenuState extends MenuState {}

class PolylineMenuState extends MenuState {}

class EditCircleState extends MenuState {
  final int circleID;
  const EditCircleState({required this.circleID});

  @override
  List<Object> get props {
    return [circleID];
  }
}

class EditPolygonState extends MenuState {
  final int polygonID;
  const EditPolygonState({required this.polygonID});

  @override
  List<Object> get props {
    return [polygonID];
  }
}
