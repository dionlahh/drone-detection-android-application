part of 'menu_bloc.dart';

abstract class MenuEvent extends Equatable {
  const MenuEvent();

  @override
  List<Object> get props => [];
}

class MainMenuEvent extends MenuEvent {}

class CircleMenuEvent extends MenuEvent {}

class PolygonMenuEvent extends MenuEvent {}

class PolylineMenuEvent extends MenuEvent {}

class MarkerMenuEvent extends MenuEvent {}

class EditCircleEvent extends MenuEvent {
  final int circleID;

  const EditCircleEvent({required this.circleID});

  @override
  List<Object> get props => [circleID];
}

class EditPolygonEvent extends MenuEvent {
  final int polygonID;

  const EditPolygonEvent({required this.polygonID});

  @override
  List<Object> get props => [polygonID];
}
