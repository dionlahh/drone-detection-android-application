import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'menu_event.dart';
part 'menu_state.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  MenuBloc._privateConstructor() : super(MenuInitial()) {
    on<MenuEvent>((event, emit) {
      emit(MainMenuState());
    });

    on<MainMenuEvent>((event, emit) {
      emit(MainMenuState());
    });

    on<CircleMenuEvent>((event, emit) {
      emit(CircleMenuState());
    });

    on<PolylineMenuEvent>((event, emit) {
      emit(PolylineMenuState());
    });

    on<PolygonMenuEvent>((event, emit) {
      emit(PolygonMenuState());
    });

    on<MarkerMenuEvent>((event, emit) {
      emit(MarkerMenuState());
    });

    on<EditCircleEvent>((event, emit) {
      emit(EditCircleState(circleID: event.circleID));
    });

    on<EditPolygonEvent>((event, emit) {
      emit(EditPolygonState(polygonID: event.polygonID));
    });
  }

  static final MenuBloc _instance = MenuBloc._privateConstructor();

  factory MenuBloc() {
    return _instance;
  }
}
