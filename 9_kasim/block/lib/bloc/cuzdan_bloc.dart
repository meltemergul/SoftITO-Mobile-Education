import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/islem.dart';
import 'cuzdan_event.dart';
import 'cuzdan_state.dart';

class CuzdanBloc extends Bloc<CuzdanEvent, CuzdanState> {
  CuzdanBloc() : super(const CuzdanYukleniyorState()) {
    on<CuzdanYukleEvent>(_onCuzdanYukle);
    on<ParaYukleEvent>(_onParaYukle);
    on<ParaHarcaEvent>(_onParaHarca);
  }

  Future<void> _onCuzdanYukle(
    CuzdanYukleEvent event,
    Emitter<CuzdanState> emit,
  ) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final baslangicIslemleri = [
      Islem(
        baslik: "açılış bonusu",
        id: "1",
        miktar: 1000.0,
        tarih: DateTime.now().subtract(const Duration(days: 2)),
        tip: IslemTipi.gelir,
      ),
      Islem(
        baslik: "öğle yemeği",
        id: "2",
        miktar: 650.0,
        tarih: DateTime.now().subtract(const Duration(hours: 4)),
        tip: IslemTipi.gider,
      ),
    ];
    emit(CuzdanYuklendiState(bakiye: 350.0, islemler: baslangicIslemleri));
  }

  void _onParaYukle(ParaYukleEvent event, Emitter<CuzdanState> emit) {
    if (state is CuzdanYuklendiState) {
      final mevcutState = state as CuzdanYuklendiState;
      final yeniIslem = Islem(
        baslik: event.baslik,
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        miktar: event.miktar,
        tarih: DateTime.now(),
        tip: IslemTipi.gelir,
      );

      final yeniListe = List<Islem>.from(mevcutState.islemler)
        ..insert(0, yeniIslem);
      final yeniBakiye = mevcutState.bakiye + event.miktar;

      emit(CuzdanYuklendiState(bakiye: yeniBakiye, islemler: yeniListe));
    }
  }

  void _onParaHarca(ParaHarcaEvent event, Emitter<CuzdanState> emit) {
    if (state is CuzdanYuklendiState) {
      final mevcutState = state as CuzdanYuklendiState;

      if (mevcutState.bakiye < event.miktar) {
        emit(const CuzdanHataState('Yetersiz Bakiye'));
        emit(mevcutState);
        return;
      }
      final yeniIslem = Islem(
        baslik: event.baslik,
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        miktar: event.miktar,
        tarih: DateTime.now(),
        tip: IslemTipi.gider,
      );

      final yeniListe = List<Islem>.from(mevcutState.islemler)
        ..insert(0, yeniIslem);
      final yeniBakiye = mevcutState.bakiye - event.miktar;
      emit(CuzdanYuklendiState(bakiye: yeniBakiye, islemler: yeniListe));
    }
  }
}
