/*
Future<void> fetchDasboardData() async {
  try {
    final result = await Future.wait(
      [fetchUserProfile(), fetchAccountBalance(), fetchNotification()],
      eagerError: true,
    ); //eagerError true olursa hata oluştuğunda diğer işlemler iptal edilir.
    print("Tüm veriler alındı: $result");
  } catch (e) {
    print("Veri alınırken hata oluştu: $e");
  }
}

//paralel olarak çalışır.
*/

//Future: tek bir kere veri çekileceği zaman kullanılır ya hata ya da değer dönüp bitirir.
//Stream: bir boru hattı şeklinde çalışır(pipe), zaman içinde 1 10 100 ya da sonsuz sayıda veri akışı sağlanabilir.
//(borsa fiyatları,GPS konum verileri, chat mesajları,firebase canlı dinleme gibi sürekli veri akışı olan durumlarda stream kullanılır.)

import 'dart:async';

void main() {
  //controller oluşturma
  final controller = StreamController<int>();
  //StreamController ile bir stream oluşturulur. StreamController, veri akışını kontrol etmek için kullanılır.
  //dinleyici(listener) bağlama
  final subscription = controller.stream.listen(
    (data) => print("Veri alındı: $data"),
    onError: (error) => print("Hata oluştu: $error"),
    onDone: () => print("Stream tamamlandı."),
  );
  //sink ile veri ekleme
  controller.sink.add(10); //veri ekleme
  controller.sink.add(20);
  controller.sink.add(30);
  //birden çok listener olmuyor. tek bir listener var. birden çok listener için broadcast stream kullanılır.
  final broadcastStream = controller.stream
      .asBroadcastStream(); //broadcast stream oluşturma
  broadcastStream.listen((data) => print("UI Ekranı: $data"));
  broadcastStream.listen((data) => print("Analitik Servis Ekranı: $data"));

  controller.close(); //stream kapatma
}
