Const
1) ne işe yarar:içine girilen değerleri derleme zamanında tek bir kere yazılarak değişmez olarak üretir.
2) neden kullanılır: bir widget const olarak tanımlanırsa setState olduğunda flutter bu widget'i yeniden üretmez CPU ve pil tasarufu sağlar.
** derleme zamanında çalışır.**

final
1) ne işe yarar: çalışma zamanında değeri bir kez atanan ve sonrasında referansı asla değiştirilmeyen değişkenler
** const ve final farkı: const derlenirken bilinmek zorunda(const pi=3.14) final ise çalışma anında belirlenebilir(final saat=DateTime.now())---Model sınıflarında alanlar her zaman final olmalıdır.
** çalışma zamanında çalışır.

late
1) ne işe yarar: değişken tanımlandığı anda değil,ilk kullanıldığında veye initState anında başlayacağı zaman kullanılır.

required
1) ne işe yarar: isimlendirilmiş parametrelerde o parametrenin zorunlu olduğunu belirtir.


@override

1) ne işe yarar : alt sınıfın,üst sınıftan devraldığı metodun ezdiğini belirtir.
2) faydası: eğer üst metod adını yanlış yazarsanız(örnek builds yazarsanız) derleyici @override sayesinde bunu anında hata olarak yakalar.


Null-aware operatörleri(? ?? !)

?. - place?.title -> eğer place null ise hata vermez direk null olarak döner.
?? - if null : final id = state.userId ?? 10; ->  sol taraf null ise sağkdaki (hardcode olan değer) otomatik olarak atanır
! (null / force) : final id = state.userId!; -> bu kod derleyiciye "bana güven bu değer o anda kesinlikle null değil" der. eğer null gelirse uyguluma anında çöker.(ÇOK DİKKATLİ KULLANILMALI! )

Spread Operatörü (...)  
1) ne işe yarar : bir listenin elemanlarını tek tek çıkartıp bulunduğu üst listenin içine ekler.Column ve ListView içinde dinamik kart dizini kullanmak için en temiz yöntemdir.
...listeAdi.map((p)=> _buildCard(p))




initState()
Ne zaman çalışır: Widget ağaca fiziksel olarak ilk başladığında yalnızca 1 kere çalışır.
ne yapar: ScrollController başlatmaları ve ilk api istekleri burda kurulur.
Kural: içinde doğrudan BuildContext ile Navigator çağrılmaz çünkü widget ağaca tam oturmamıştır.

didChangeDependencies()
Ne zaman çalışır: init State()'ten hemen sonra ve widget dinlendiği bir(örnek: Theme of context) değiştiğinde otomatik tetiklenir.
Ne yapar: BuildContext güvenli bir şekilde erişerek tema veya ekran boyutu bağımlılıkları ile ilgili ilk yüklemeler burada yapılır.

build(BuildContext context)
1) Ne zaman çalışır:sayfa ilk açıldığında , setState() çağrıldığında veya üst widget yeni bir inşa ağaç boyama geldiğinde saniyesinde defalarca çalışır.
Kural:build() metodu tamamen saf olmalıdır.asla içinde setState() api listeyi ya da controller başlatma yapılmamalıdır.Sdece UI döndürülmelidir.

dispose()
Ne zaman çalışır: widget hafızadan atılmadan hemen önce son bir kez çalışır
ne yapılır _controller.dispose() stream dinleyicilerin iptalleri bruada yapılır.super.dispose() un mutlaka son satırda çalıştırması gerekir.


setState((){})
1) arka planda ne yapar.State'in bağlı olduğu StatefulElement nesnesine "ben değiştim,build et"  sinyali yollar.
2) nerede kullanılır.Sayfa genelini çizdirmez.sadece onu dinleyen küçük ValueListenable'a sinyal gönderilir.

ValueNotifier<T>

1) arka planda ne iş yapar.ChangeNotifier sınıfından türer.Belleğindetek bir nesne referansı tutar.(T_value)
2) tetikleme değer atandığında (set Value(T value)), eğer yeni değer eski değere eşit değilse (_value!=newValue), kayıtlı olan fonksiyonu çağrılır.(addListener() {})

InheritedWidget
1) ne yapar:Widget ağacında alltaki childların,aradaki onlarca widgeti baypas ederek,üst widgetin verisine (state'ine) doğrudan erişmesini sağlayan soyut bir widgettir.

Material 3 Tasarım Dili Renk Algoritması ve Temalar

primary:Ana marka rengi
onPrimary:Ana rengin üstüne yazılacak yazı rengi(okunabilirlik açısından)
primaryContainer:Ana rengin daha açık tonu(arka plan için kullanılır)
onPrimaryContainer: Ana rengin yumuşak pastel arka plan tonununun üstüne yazılacak yazı(okunabilrlik açısından)
surface: sayfa arka plan yuva (Card,Dialog,Bottomnav gibi widgetlerin genel yüzeyi)
onSurface: üstündeki ana metin rengi
outlineVariant: ince sınır ve ayrım çizgilerinin rengi

ThemeMode.system
color:Colors.black.withOpacity(186) //kesinlikle 1 ila 255 sayıları arasında tam sayı olarak girilmelidir.**bu kullanım güncelde istenmiyor.**


color:Colors.black.withValues(alpha: 186/225) //double sayı olarak girilmelidir.**güncell ve doğru yöntem.**

Arayüz Düzen ve Liste Bileşenleri

Expanded ve Flexible
Expanded:Kalan boş alanın TAMAMINI kaplamya zorlar.
Flexible:Kalan boş alanı paylaştırır.(flex:1,flex:2)
Flex: yanyana iki expanded varsa birine flex2 diğerine flex 1 verir bu sayede ekran boyutuna göre otomatik olarak ayarlar.

Stack ve Positioned
Ne yapar : Widgetl'ları z ekseninde üstüne bindirir.
Positioned: Yalnızca bir stack içinde çalışır.
top:10 right:10 vererek bir resmin sağ üst köşesine bildirim rozeti eklemenizi sağlar.

ListView.builder
Klasik ListView(children:[...],) içindeki örnek vermek gerekirse 10.000 elemanın tamamını daha sayfa açılmadan belleğe yükler ve doğal olarak telefon donar.
ListView.builder ise geri dönüşümlü görünüm alanı mantığını kullanarak ekranda sadece o an eğer 5 kart görünecek ise sadece 5 kartı ram belleğe yükler.Kullanıcı aşağıya kaydıkça yukarıda kalanlar bellekten düşürülüp altta kalanlar belleğe taze olarak yeni olarak üretilir.

shrinkWrap:true
Bir listView boş bir dikey kaydırıcının(singleChildScrollView) içine konursa Vertical viewport hatası verir.
shrinkWrap true verilerek bu çözülebilir ancak: Listview'un sonsuz kayma (sonsuz scroll) özelliği kaybolur.
**Sadece 3-5 elemanınız varsa bunu kullanmalısınız**

inkwell ve GestureDetector
GestureDetector:Tıklama çift tıklama sürükleme olaylarını yakalar ama GÖRSEL HİÇ BİR TEPKİ VERMEZ.
ınkwell: tıklandığı an parmağın altından dışa doğru yayılan bir su dalgası efekti verir.

Önemli Kural: Inkwell'in arkasında mutlaka bir material widget olmak zorundadır.Aksi takdirde su dalgası arkadaki tuvalı göremediği için hiçbir şekilde görünmez.

Form mimarisi

GlobalKey<FormState>

Widget içindeki form düğümüne doğrudan dışarıdan erişilemiyor.Bu yüzden widgetin en üstüne koyduğumuz globalKey değişkeni sayesinde formun Validate(geçerli) durumunu ve içindeki değerleri(değişkenleri) dışarıdan okuyoruz.

_formKey.currentState?.validate() çağrıldğında o formun altındaki tüm TextFromFiled validator bloklarını sırasıyla çalıştırır.

validator : (String ? value)

fonksiyonda bir hata bulursa geriye String olarak hata metni döndürür.
bu metin otomatik olarak kırmızın renkte ve inputun altında belirir.
eğer veri geçerliyse null döner,Flutter için bu alanda hata yok demektir.Null gelmesi

Animasyon Motoru
AnimatedContainer: genişlik yükseklik padding margin border renk ve gölge oynatır
AnimatedOpacity: görünürlüğü 0.0 ila 1.0 arasında yumuşakça soldurur.
AnimatedScale: widget merkezinden dışarıya doğru büyütüp küçülür
AnimatedAlign: Widget kutunun içinde sağdan sola yukarıdan aşağıya karşı konumunu değştirir.

Curves
İvmelenme Karakterleri

Curves.linear:sabit hız (robotik hareketler)
Curves.easeInout:Yavaş başlar ortada hızlanır yavaşca durur.
Curves.bounceOut:Hedefe çarptığında top gibi 2 3 kez yaylanarak seker
Curves.elasticOut: Lastik gibi ileri geri titreyerek yerine oturur.



Gorouter->sayfanın geri kalanı 
Shallrouter->alt tarafftaki menü-yönlendirme varsa-bottom menü gibi

context.go('/profil')  : Route yönlendirmesidir.Rota tablosunda hiyerarşiyi takip eder sayfayı temizleyebilir.

context.push('/profil/5') stack yönlendirmedir.kullanıcı nereden gelirse gelsin mevcut sayfanın tepesine yeni bir katman ekler ve dönüş sayfası için bir geri ok butonu ekler.

context.pop() sayfanın en üstteki yığınını kapatır.

state.pathParameters["id"] : Gorouter içinde tanımladığımız /:id yapılarına erişmek için kulanılır.

/profil?user=berat
state.uri.queryParameters["user"] : Opsiyonelik filtreleme ya da arama zamanlarında kullanılır.

Cihaz içi Yerel Depolama mimarileri

SharedPreferences: 
*Temel görevler:üçük kullanıcı ayarları (tema modu,dil ayarı, "bana bir daha sorma" gibi onay kutuları)için kullanılır.
*güvenlik derecesi:düşük güvenlik
*Okuma yazma hızları:okuma hızı ortalama-yazma hızı yavaş

FlutterSecureStorage:
**Temel görevler:Şifre Token vb. saklama
*güvenlik derecesi:en yüksek güvence
*Okuma yazma hızları:orta seviye


Hive/Isar:
**Temel görevler:yüksek performanslı nesne depolama:
*güvenlik derecesi: orta(isteğe bağlı şifreleme açılabilir)
*Okuma yazma hızları:okuma hızı çok hızlı-yazma hızı çok hızlı





## Sözleşmeler, SOLID Prensipleri & OOP Mimarisi
### 1.1 Interface (Arayüz/Sözleşme)
*Sözlük Anlamı:* İki bağımsız sistemin birbiriyle  nasıl konuşacağını belirleyen, içi boş metot imzalarından oluşan kurallar bütünüdür.

*Neden Kullanılır:* Bir sınıfa göbekten bağımlı kalmamak (örneğin gerçek şarj istasyonu cihazı olmadan sahte/mock şarj servisiyle testi  çalıştırabilmek) için.

dart
abstract interface class StationContReact{
    Future<void> startCharging(String socketId);
    Stream<double> get wacthLivePower();
}


### 1.2 implements vs extends vs with
### 1.2.1 implements (Arayüz Sözleşmesi)
**Sözlük Anlamı:* Bir sınıfın, bir şablonun belirlediği kuralları kabul edip **içini sıfırda kendisinin doldurması* zorunluluğudur.

**Neden Kullanılır:** Farklı sınıflara ortak bir standart/sözleşme dayatmak, çoklu arayüz desteği sağlamak ve kodda bağımlılıkları azaltmak için.

### 1.2.2 extends (Kalıtım/Miras)
**Sözlük Anlamı:* Bir sınıfım, başka bir sınıfın özelliklerinini ve metotlarını doğrudan devralması.

**Neden Kullanılır:* Kod tekrarını önlemek (DRY), mantıksal bir sınıf hiyerarşisi oluşturmak için.


### 1.2.3 with (Mixin/Yetenek Aşılama)
**Sözlük Anlamı:** Sınıf hiyerarşisni bozmadan, bağımsız bir sınıfa hazır kod blokları (metotlar ve değişkenler) enjekte etme mekanizmasıdır.

**Neden Kullanılır:** Akraba olmayan sınıflara ortak yetenekler kazandırmak, çoklu kalıtım kimliğini önlemek ve modülerliği artırmak için.

| Özellik | extends | implements | with |
|---|---|---|---|
| *Temel felsefe* | ben senin çocuğunum, genlerini alıyorum. | seninle sözleşme imzaladım, maddeleri ben yapacağım. | ben ana sınıfıma ek bir uzmanlık yeteneği takıyorum. |
| *gövdesi dolu metot gelir mi* | evet, üst sınıfın metotlarını doğrudan kullanır. | hayır! üst sınıfın içi dolu olsa bile hepsi silinir, sıfırdan yazılır. | evet, mixin içindeki hazır metotlar sınıfa eklenir. |
| *kaç tane kullanılabilir?* | sadece 1 tane (dartta çoklu kalıtım yasaktır). | sınırsız (virgülle onlarca interface uygulanabilir). | sınırsız (virgülle birden çok mixin takılabilir). |
| *Constructor var mıdır* | evet | hayır (interfacein constructor ı olmaz). | hayır. |


## Sözleşmeler, SOLID Prensipleri & OOP Mimarisi
### 1. S - Single Responsibility Principle(Tek Sorumluluk Prensibi)
***kural:*** bir sınıfın veya dosyanın değişmesi için **yalnızca 1 sebebi** olmalıdır.
#### 2. O - Open / Closed Principle (Açık /Kapalı Prensibi)
***kural:***  yazılım varlıkları (sınıflar,modüller,fonksiyonlar) **genişlemeye açık,değiştirmeye kapalı** olmalıdır.

#### 3. L - Liskov Substitution Principle(LSP) (Liskov Yerine Geçme Prensibi)
***kural:*** bir üst sınıfın yerine,onun alt sınıflarından herhangi biri geçirildiğinde sistemin davranışı bozulmaamalı ve hata fırlatmamalıdır

### 4. I - Interface Segregation Principle(ISP) (Arayüz Soyma Prensibi)
***kural:*** istemciler(sınıflar),kullanmadıkları metotları içermeye zorlanmamalıdır. şişman(fat) interface'ler yerine küçük ,amaca yönelik arayüzler kurulmalıdır.

### 5. D - Dependency Inversion Principle(DIP) (Bağımlılık Tersine Çevirme Prensibi)
***kural:***  yüksek seviye modüller (UI,iş mantığı)  düşük seviye modüllere (veri tabanı,HTTP istemcisi) bağımlı olmamalıdır. her ikisi de soyutlamalara(`interface`) bağlı olmalıdır.  

---

### 1.4 `Coupling`(Bağlaşıklık) & 'Cohesion'(Uyum)

***Tightly Coupled(Sıkı Bağımlı)***: Sınıfların birbirinin her detayını bilmesi. birinde yapılan bir harflik değişiklik diğer 5 dosyayı bozuyorsa sistem sıkı bağımlıdır.

***Losely coupled(Gevşek Bağımlı)***:Sınıflar sadece interface üzerinden konuşmasıi.biri değiştiğinde diğeri etkilenmez.

***High Cohesion(Yüksek Uyum)***: Bir sınıfın sadece ve sadece kendi uzmanlık alanını yapması.

---

## Stream Temelleri,CUBİT & ENTERPRISE BLOC
### 2.1 `Stream` Nedir? (BLoC'un Kalbindeki Motor)
***Sözlük Anlamı:*** zaman içinde parça parça gelen, akıp giden asenkron veri dizisi.

*** BLOC sırrı** BLOC kütüphanesi sihirli bir şey yapmaz! BLOCun içinde gizli bbir `StreamController` vardır.Event'ler borunun bir ucundan girer(`sink.add`), BloC onları işler ve diğer ucundan ekran state akıtır.(`stream.listen`)


## Cubit vs BloC


| Kriter | Cubit (hafif BLoC) | Bloc (event-driven) |
| :--- | :--- | :--- |
| **tetikleme mekanizması** | Doğrudan metot çağrısı:<br>`cubit.loadStations()` | Event fırlatma:<br>`bloc.add(LoadStationsEvent())` |
| **kod miktarı** | Az dosya, sade ve hızlı | `event` dosyası + `state` dosyası + `bloc` dosyası |
| **izlenebilirlik (traceability)** | Sadece hangi fonksiyonun çağrıldığı bilinir | Hangi event'in hangi state'e yol açtığı saniye saniye izlenir |
| **event dönüştürücü (debounce/throttle)** | Elle `Timer` veya flag kurmak gerekir | `transformer: restartable()` ile tek satırda çözülür |
| **ne zaman tercih edilmeli** | Basit formlar, tema değiştirme, tab geçişleri, profil | Şarj başlatma/bitirme, sepet akışı, bakiye transferi, kimlik doğrulama |


---

### 2.3 Bloc'un 3 Temel Elemanı: `Event`, `State` ve `Emitter`

**Event(olay)** kullanıcının veya sistemin BloC'a attığı emir fişi.

**Mini sözdizimi** `class StartChargingRequested extends ChargingEvent {final string socketId;}`

**State(durum)**: ekranın o milisaniyedeki dondurulmuş fotoğrafı(snapshot).

*mini sözdizimi:* `class ChargingActiveState extends ChargingState {final double kwh;}``

*kural*: senkron çalışır; `emit(New State())` dendiği anda UI'daki builder'lar tetiklenir.

# Soru: State değiştiğinde ne yapmak istiyorsun?

### 1. Sadece arayüz çizmek
* **Örnekler:**
  * Kart basmak
  * Spinner döndürmek
  * Liste render etmek
* **Çözüm:** `BlocBuilder`

---

### 2. Sadece yan etki tetiklemek
* **Örnekler:**
  * SnackBar patlatmak
  * `showDialog()` açmak
  * `context.go()` ile gitmek
* **Çözüm:** `BlocListener`

---

### 3. Hem arayüz çizmek hem yan etki tetiklemek
* **Örnekler:**
  * Hata olunca SnackBar bas, ama listeyi ekranda tut
* **Çözüm:** `BlocConsumer`


## STREAM TEMELLERİ, CUBIT & ENTERPRISE BLOC

### 3.1. `Side Effect` (Yan Etki) Neden `BlocBuilder` İçine Yazılamaz?

* `BlocBuilder`'ın tek görevi **Widget döndürmektir**.
* Flutter motoru ekranı saniyede 60 kez çizebilir (Rebuild). Eğer siz `BlocBuilder` içine `ScaffoldMessenger.showSnackBar` veya `Navigator.push` yazarsanız; kullanıcı cihazı yan çevirdiğinde veya klavye açıldığında kullanıcıya **üst üste 10 defa SnackBar patlar veya 10 kez yeni sayfa açılır!**
* **Kural:** Yan etkiler SADECE `BlocListener` içine yazılır; çünkü `listener` sayfa rebuild olduğunda değil, **yalnızca State değiştiğinde 1 kez** tetiklenir!

### 3.2 `BlocSelector` (Mikro Performans & Pil Tasarrufu)
* **Kavram** State'in içerisindeki onlarca alandan sadece ** 1 tanesini süzüp izlemek.**

----
## 4. EŞİTLİK,DEĞİŞMEZLİK & BLOCOBSERVER
### 4.1 `Referential Equality`vs`Value Equality`
* **Dart Varsayılanı (Referans Eşitliği):** İki nesnenin bellekteki (RAM) adresi aynı mı?
  'Soket('A')== Soket('A') ` -> ** FALSE çıkar!** içerikleri aynı olsada RAM'deki evleri farklıdır. 
* **Değer Eşitliği(Value Equality):** Nesnelerin içindeki veriler aynı mı?
`Equatable` paketi tam olarak bunu çözer:Nesneleri RAM adresine göre değil,`props` listesindeki alanların değerine göre karşılaştırır.

### 4.2 `props`Listesi Yazılmazsa Ne Olur?
* BLoC ekran kartını yormamak için şu denetimi yapar: `if(yeniState == eskiState) ekraniCizme();``
* eğer siz `stationLoaded` state'ine yeni bir `filterType`alanı eklerseniz ama `props`içine yazmayı unutursanız;BLoc iki state'i eşit zanneder ve **ekranı güncellemez,arayüz donuk kalır!**

### 4.3. `Immutability` (Değişmezlik) & 'copywith'
* **Kural** State sınıflarının tüm alanları `final` olmalıdır. 
* **`copyWith` Mantığı:** Eski nesnenin 5 alanını koruyup,sadece değişen 1 alanını güncelleyerek taze bir nesne üretmen yöntemidir.

  ```dart
  final guncel = state.copyWith(isCharging: true); // Diğer alanlar bozulmadan kopyalanır
   ````

###  4.4. BlocObserver (Tüm Uygulamayı Röntgenleme)
* **Kavram:** Uygulamadaki tüm BLoC ve Cubit'lerin arkasında çalışan merkezi bir kara kutu / telemetri kaydedici.
* **Ne İşe Yarar?** Hangi ekranda hangi Event fırlatıldı, State nereden nereye geçti (`onTransition`) ve nerede hata fırlatıldı (`onError`) tek merkezden konsola loglanır. Kurumsal projelerde analitik ve çökme takibi için zorunludur



### 1. PRESENTATION (Görsel Katman)
* UI ekranları, butonlar, theme, BLoC, cubit
->
*bağımlılık içeri bakar*

### 2. DOMAIN (İş kuralları - en kutsal katman)
* `entity` (saf veri), `UseCase` (iş kuralları)
* `Repository Interface` (sözleşmeler)
* **Kural!!!** Dış dünyadan (JSON, Dio, SQLite) asla bilgi içermez! Sıfır harici paket importu!
<- 
*sözleşmeyi uygular*

### 3. DATA (Veri altyapısı)
* `Model` / `DTO` (`fromJson`/`toJson`)
* `Remote DataSource` (Dio ile API)
* `Local DataSource` (Hive / sharedPreferences ile disk)
* `Repository Implementation`



## 5. CLEAN ARCHITECTURE KATMANLARI & SORUMLULUK DUVARLARI

### 5.1. `Entity` vs `Model/DTO`
* **`Entity` (Varlık):** Saf iş nesnesidir. Bir şarj soketinin gerçek hayattaki özelliklerini (`id`, `kw`, `durum`) tutar. `fromJson` veya `toJson` İÇERMEZ.
* **`Model / DTO` (Data Transfer Object):** API'den gelen ham JSON verisini karşılayan taşıyıcıdır. `Entity`'den türer; `fromJson` ve `toJson` metotlarını barındırır.
* *"Neden Entity içine `fromJson` yazmıyoruz?"*
  *(Cevap: Yarın backend JSON yerine XML veya Protobuf formatına geçerse; Domain katmanındaki iş kurallarımız ve UI sayfalarımız zerre kadar etkilenmesin, sadece DATA katmanındaki Model etkilensin diye!)*

### 5.2. `UseCase` (Kullanım Senaryosu)
* **Kavram** Kullanıcının veya sistemib gerçekleştirebileceği **tek ve atomik bir iş kuralı**.
* **Örnekler:** `StartChargingSessionUseCase`, `GetStationSocketsUseCase`, `RefundWalletBalanceUseCase`.
* **Kural:** Her UseCase sınıfının içinde sadece tek bir `call()` veya `execute()` fonksiyonu bulunur.

### 5.3 `Repository Contract`vs `Repository Implementation`
Contract (Domain Katmanında): Sadece sözleşmedir (abstract interface class StationRepository). Verinin nereden geleceğini bilmez.
Implementation (Data Katmanında): Sözleşmeyi uygulayan somut sınıftır (class StationRepositoryImpl implements StationRepository). Verinin önce yerel diskten mi yoksa internetten mi çekileceğine karar verir.

## 6. Bağımlılık Yönetimi: DEPENDECY INJECTION & `get_it`
Eğer 5 ayrı sayfada `final dio = Dio();` derseniz:

1. Bellekte 5 ayrı bağlantı havuzu açılır, telefonun soket sınırını zorlar.
2. Base URL veya Timeout değiştiğinde 5 ayrı dosyayı elle değiştirmek zorunda kalırsınız.
3. Test yazarken sahte (mock) veri enjekte edemezsiniz.

### 6.2 `GetIt`Kayıt Tipleri: Singleton vs LazySingleton vs Factory

* **`Singleton`:** Uygulama açıldığı milisaniyede nesneyi üretir ve belleğe çiviler.
* **`LazySingleton`:** Uygulama açıldığında üretmez! Ne zaman ilk kez birisi `sl<Dio>()` derse o an üretir ve sonrasında hep aynı nesneyi verir. (Bellek ve açılış hızı dostudur).
* **`Factory`:** Her çağrıldığında yepyeni, sıfır bir kopya üretir.

## 7. KURUMSAL AĞ MİMARİSİ : DIO,INTERCEPTOR & HTPP STATUS KODLARI


* **Sözlük Anlamı:** Ağ isteği telefondan çıkıp ınternete gitmeden önce veya sunucdan cevap gelip koda düşmeden önce araya girip paketi inceleyen/değiştiren güvenlik noktası.

### 7.2. Bearer Token & Payload
* **Bearer Token:** "Bu anahtarı taşıyan kişi giriş yapmaya yetkilidir" anlamına gelen şifrelenmiş kimlik kartı metni (Authorization: Bearer eyJhbGci...).
* **Payload:** Bir API isteğiyle sunucuya gönderilen veya sunucudan bize dönen asıl veri gövdesi (Body).

### 7.3 HTTP Durum Kodları Sözlüğü

* **`200 OK`:** İstek başarılı, veri gövdede.
* **`201 Created`:** Yeni kayıt (örneğin yeni şarj oturumu) başarıyla oluşturuldu.
* **`400 Bad Request`:** İstemci hatası; eksik veya hatalı parametre gönderdin.
* **`401 Unauthorized`:** Token yok veya süresi dolmuş; hemen Login'e yönlendir!
* **`403 Forbidden`:** Giriş yaptın ama bu veriyi görmeye yetkin yok (Admin değilsin).
* **`404 Not Found`:** Aradığın soket veya istasyon sunucuda bulunamadı.
* **`500 Internal Server Error`:** Backend sunucusu patladı; istemcilik bir hata yok.

## 8. VERİ DAYANIKLILIĞI: CACHE-FIRST & SAVUNMACI KODLAMA

### 8.1. `Cache-First` (Önce Önbellek) Stratejisi
* **Mantık:** Kullanıcı şarj istasyonu listesini açtığında 1 saniye bile beyaz ekranda spinner bekletme! Diskteki dünkü veriyi **0.01 milisaniyede** ekrana bas. Arka planda sunucudan taze veriyi çek; gelince ekranı ve diski sessizce güncelle.


### 8.2 `Defensive Programming` (Savunmacı Programlama)
* **Mantık:** Sunucudan gelen veriye asla %100 güvenme prensibi.