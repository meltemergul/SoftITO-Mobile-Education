// soyutlama abrasction kavramı

//1.adım (sözleşmeler) contract
/*
abstract class AuthRepository {
  //soyut sınıf
  Future<String> login(String email, String password);
  Future<void> logout();
  bool get isAuth; //getter
}

class FirebaseAuthRepository implements AuthRepository {
  @override
  Future<String> login(String email, String password) async {
    // gerçek firebase SDK çağrısı
    return "firebase_token_xyx_123";
  }

  @override
  Future<void> logout() async {
    // firebase logout
  }

  @override
  bool get isAuth => true;
}

//implents ile extens arasındaki fark
//implent contract (sözleşme) ile sınıfı implement ederken (imzayı alır) türetir, extends ile sınıfı genişletiriz(hem imza hem de kod alır).
//Test ve offline simülasyon
class MockAuthRepository implements AuthRepository {
  //mock sınıf
  @override
  Future<String> login(String email, String password) async {
    await Future.delayed(Duration(seconds: 1));
    return "mock_token_abc_789";
  }

  @override
  Future<void> logout() async {
    //asenkron olduğu için aynı anda çalışır. await ile bekletiriz.
    // test için sahte logout işlemi
  }

  @override
  bool get isAuth => false;
}

//birden fazla mixin kullanmak için with kullanılır. mixinler bir sınıfın davranışını başka bir sınıfa eklemek için kullanılır.
//async olmadığı için analytics yazılır
mixin Logger {
  void log(String message) => print("LOG: $message");
}

mixin Analytics {
  void log(String message) => print("Analiz: $message");
}

class PaymentService with Logger, Analytics {
  void pay() {
    log("Ödeme yapıldı");
  }
}

abstract class BaseWidget {}
//sadece baseWidget ve alt sınıflarda kullanılabilir.

mixin LifeLogeer on BaseWidget {
  //on sınıfı ile sınırlı. sadece BaseWidget ve alt sınıflarında kullanılabilir.
  //sadece o sayfaya özel çalışır. BaseWidget ile sınırlı.
  void logInit() => print("Widget başlatıldı");
}

extension StringValidator on String {
  bool get isValidEmail {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(this); //email regex pattern
  }

  String toCapitalized() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1); //ilk harfi büyük yapar
  }
}

void main() {
  String email = "meltemergul34@gmail.com";
  if (email.isValidEmail) {
    print("geçerli bir e-posta adresi");
  } else {
    print("geçersiz bir e-posta adresi");
  }
}

abstract class Identifiable {
  // sınıfın id özelliği olmasını zorunlu kılar. Identifiable sınıfını implement eden sınıflar id özelliğini tanımlamak zorundadır.
  String get id;
}

//T tipi mutlaka identifiable arayüzünü uygulamak zorundadur.
class GenericCache<T extends Identifiable> {
  //generic sınıf herhangi bir türü alabilir. T türü Identifiable ile sınırlıdır.
  final Map<String, T> _storage = {};

  void save(T item) {
    _storage[item.id] = item; //tip güvenliği sağlanır. item.id ile item nesnesinin id özelliğine erişilir ve _storage map'ine eklenir.
    print("ID ${item.id} önbelleğe alındı");
  }

  T? get(String id) => _storage[id];
}
*/
import 'dart:async';

void main() {
  print("1.senkron başladı");
  scheduleMicrotask(() {
    //önce çalışır
    print("2.microtask oluştu.(VİP Kuyruk)");
  });
  Future(() {
    //future özellik olarak çalıştırır.sonucu gösterir.
    // değer hazır olduğunda çalışır. hata mı sonuç mu döndüğünü kontrol eder. future ile çalıştırılan kodlar event kuyruğuna eklenir.
    print("3.standart event kuyruğu");
  });
  Future.microtask(() {
    //future microtask amacı
    print("4.future microtask çalıştı");
  });
  print("5.senkron kod tamamlandı.");
}
