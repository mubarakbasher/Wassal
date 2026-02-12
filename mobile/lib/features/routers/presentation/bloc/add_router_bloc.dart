import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'add_router_event.dart';
import 'add_router_state.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/error_handler.dart';

class AddRouterBloc extends Bloc<AddRouterEvent, AddRouterState> {
  final Dio dio;

  AddRouterBloc({required this.dio}) : super(AddRouterInitial()) {
    on<SubmitAddRouterForm>(_onSubmitAddRouterForm);
  }

  Future<void> _onSubmitAddRouterForm(
    SubmitAddRouterForm event,
    Emitter<AddRouterState> emit,
  ) async {
    emit(AddRouterLoading());

    try {
      await dio.post(
        '${AppConstants.apiBaseUrl}/routers',
        data: {
          'name': event.name,
          'ipAddress': event.ipAddress,
          'apiPort': event.apiPort,
          'username': event.username,
          'password': event.password,
          'description': event.description,
          'location': event.location,
        },
      );

      emit(AddRouterSuccess());
    } catch (e) {
      emit(AddRouterFailure(ErrorHandler.mapDioErrorToMessage(e)));
    }
  }
}
