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





