import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/urun.dart';
import '../models/kategori.dart';
import '../services/i_urun_servisi.dart';

class ApiUrunServisi implements IUrunServisi{
    static const String _baseUrl='https://fakestoreapi.com/products';

    @override Future<List<Urun>> tumUrunleriGetir() async {

        final uri=Uri.parse(_baseUrl);
        try{
            final yanit=await http.get(uri).timeout(
                const Duration(seconds:10),
                onTimeout:()=>throw Exception("Ağ isteği zaman aşımına uğradı(Timeout)"),

            );
            if(yanit.statusCode==200)
            {
                final List<dynamic> hamListe=jsonDecode(utf8.decode(yanit.bodyBytes));
                return hamListe.map((tekilJson)=>Urun.fromJson(tekilJson as Map<String,dynamic>)).toList();
            }
            else
            {
                throw Exception('Sunucu hatası oluştu!Durum Kodu:${yanit.statusCode}');
            }
        }
        catch(hata)
        {
            throw Exception('Internet Bağlantısı Kurulamadı $hata');
        }
    }
 @override
 Future <List<Urun>> kategoriyeGoreGetir(Kategori kategori) async {
    if(kategori==Kategori.hepsi)
    {
        return tumUrunleriGetir();
    }
    String kategoriYolu;
    switch(kategori)
    {
        case Kategori.elektronik:kategoriYolu='electronics';
        break;
        case Kategori.erkekGiyim:kategoriYolu="men's clothing";
        break;
        case Kategori.taki:kategoriYolu='jewelery';
        break;
        default:
        return tumUrunleriGetir();
    }

    final uri=Uri.parse('$_baseUrl/category/$kategoriYolu');
    final yanit=await http.get(uri).timeout(const Duration(seconds:15));

    if(yanit.statusCode==200)
    {final List<dynamic> hamListe=jsonDecode(utf8.decode(yanit.bodyBytes));
    return hamListe.map((j)=>Urun.fromJson(j as Map<String,dynamic>)).toList();
    }
    else{
        throw Exception('Kategori Filtreleme Hatası: ${yanit.statusCode}');
    }
 }


@override
Future <List<Urun>> adaGoreAra(String aramaMetni) async{
    final tumUrunler=await tumUrunleriGetir();
    if(aramaMetni.trim().isEmpty) return tumUrunler;


    return tumUrunler.where((urun){
        return urun.baslik.toLowerCase().contains(aramaMetni.toLowerCase()) || urun.aciklama.toLowerCase().contains(aramaMetni.toLowerCase());
    }).toList();
}

}