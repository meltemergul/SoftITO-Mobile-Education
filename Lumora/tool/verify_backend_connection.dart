// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  const baseUrl = 'http://127.0.0.1:3000';
  final client = HttpClient();

  print('=== LUMORA LIVE BACKEND ENTEGRASYON DOGRULAMA ===');
  print('Hedef URL: $baseUrl\n');

  try {
    // 1. GET /health
    stdout.write('1. GET /health kontrol ediliyor... ');
    final healthReq = await client.getUrl(Uri.parse('$baseUrl/health'));
    final healthRes = await healthReq.close();
    final healthBody = await utf8.decodeStream(healthRes);
    if (healthRes.statusCode == 200 && healthBody.contains('"status":"ok"')) {
      print('✓ BASARILI');
    } else {
      throw Exception('Health check basarisiz: $healthBody');
    }

    // 2. Misafir kullanici ve yetkili token olustur
    stdout.write('2. POST /auth/guest (Misafir kullanici A olusturuluyor)... ');
    final guestReq = await client.postUrl(Uri.parse('$baseUrl/auth/guest'));
    guestReq.headers.contentType = ContentType.json;
    guestReq.write(jsonEncode({}));
    final guestRes = await guestReq.close();
    final guestBody = await utf8.decodeStream(guestRes);
    final guestJson = jsonDecode(guestBody) as Map<String, dynamic>;
    final tokenA = guestJson['token'] as String;
    final userIdA = guestJson['user']['id'] as String;
    print('✓ BASARILI ($userIdA)');

    // 3. Ikinci kullanici B olustur
    stdout.write('3. POST /auth/guest (Kullanici B olusturuluyor)... ');
    final guestBReq = await client.postUrl(Uri.parse('$baseUrl/auth/guest'));
    guestBReq.headers.contentType = ContentType.json;
    guestBReq.write(jsonEncode({}));
    final guestBRes = await guestBReq.close();
    final guestBBody = await utf8.decodeStream(guestBRes);
    final guestBJson = jsonDecode(guestBBody) as Map<String, dynamic>;
    final tokenB = guestBJson['token'] as String;
    print('✓ BASARILI (${guestBJson['user']['id']})');

    // 4. GET /habit-templates
    stdout.write('4. GET /habit-templates kontrol ediliyor... ');
    final tmplReq = await client.getUrl(Uri.parse('$baseUrl/habit-templates'));
    tmplReq.headers.set('Authorization', 'Bearer $tokenA');
    final tmplRes = await tmplReq.close();
    final tmplBody = await utf8.decodeStream(tmplRes);
    final tmplJson = jsonDecode(tmplBody) as List<dynamic>;
    if (tmplRes.statusCode == 200 && tmplJson.length >= 5) {
      print('✓ BASARILI (${tmplJson.length} adet sablon alindi)');
    } else {
      throw Exception('Habit templates basarisiz: $tmplBody');
    }

    // 5. POST /habits (User A)
    stdout.write('5. POST /habits (User A icin aliskanlik olusturuluyor)... ');
    final habitReq = await client.postUrl(Uri.parse('$baseUrl/habits'));
    habitReq.headers.set('Authorization', 'Bearer $tokenA');
    habitReq.headers.contentType = ContentType.json;
    habitReq.write(jsonEncode({
      'name': 'Kitap Okuma',
      'icon': 'menu_book',
      'category': 'book',
      'unit': 'sayfa',
      'dailyGoal': 20,
      'step': 5,
      'repeatDays': [1, 2, 3, 4, 5, 6, 7],
      'reminderTime': '21:00'
    }));
    final habitRes = await habitReq.close();
    final habitBody = await utf8.decodeStream(habitRes);
    final habitJson = jsonDecode(habitBody) as Map<String, dynamic>;
    if (habitRes.statusCode != 201) {
      throw Exception('Habit olusturma basarisiz: $habitBody');
    }
    final habitId = habitJson['id'] as String;
    print('✓ BASARILI (Habit ID: $habitId, Hedef: 20 sayfa)');

    // 6. Guvenlik Testi: User B, User A'nin aliskanligina erisememeli (404 Not Found)
    stdout.write('6. Guvenlik Testi (User B yetkisiz erisim denemesi)... ');
    final unauthReq = await client.getUrl(Uri.parse('$baseUrl/habits/$habitId'));
    unauthReq.headers.set('Authorization', 'Bearer $tokenB');
    final unauthRes = await unauthReq.close();
    final unauthBody = await utf8.decodeStream(unauthRes);
    final unauthJson = jsonDecode(unauthBody) as Map<String, dynamic>;
    if (unauthRes.statusCode == 404 && unauthJson['error']['code'] == 'NOT_FOUND') {
      print('✓ BASARILI (Beklendigi gibi 404 NOT_FOUND alindi)');
    } else {
      throw Exception('Yetkisiz erisim engellenemedi: $unauthBody');
    }

    // 7. PUT /habits/:id/logs/:date (amount: 10)
    stdout.write('7. PUT /habits/:id/logs/:date (amount: 10)... ');
    final logReq1 = await client.putUrl(Uri.parse('$baseUrl/habits/$habitId/logs/2026-10-22'));
    logReq1.headers.set('Authorization', 'Bearer $tokenA');
    logReq1.headers.contentType = ContentType.json;
    logReq1.write(jsonEncode({'amount': 10}));
    final logRes1 = await logReq1.close();
    final logBody1 = await utf8.decodeStream(logRes1);
    final logJson1 = jsonDecode(logBody1) as Map<String, dynamic>;
    if (logRes1.statusCode == 200 && logJson1['amount'] == 10 && logJson1['completed'] == false) {
      print('✓ BASARILI (amount=10, completed=false)');
    } else {
      throw Exception('Log kaydi basarisiz: $logBody1');
    }

    // 8. PUT /habits/:id/logs/:date (delta: +10 -> toplam 20, hedef saglandi completed=true)
    stdout.write('8. PUT /habits/:id/logs/:date (delta: +10 ile tamamlama)... ');
    final logReq2 = await client.putUrl(Uri.parse('$baseUrl/habits/$habitId/logs/2026-10-22'));
    logReq2.headers.set('Authorization', 'Bearer $tokenA');
    logReq2.headers.contentType = ContentType.json;
    logReq2.write(jsonEncode({'delta': 10}));
    final logRes2 = await logReq2.close();
    final logBody2 = await utf8.decodeStream(logRes2);
    final logJson2 = jsonDecode(logBody2) as Map<String, dynamic>;
    if (logRes2.statusCode == 200 && logJson2['amount'] == 20 && logJson2['completed'] == true) {
      print('✓ BASARILI (amount=20, completed=true)');
    } else {
      throw Exception('Delta tamamlama basarisiz: $logBody2');
    }

    // 9. DELETE /habits/:id (Aliskanligi arsivle)
    stdout.write('9. DELETE /habits/:id (Aliskanligi arsivle)... ');
    final delReq = await client.deleteUrl(Uri.parse('$baseUrl/habits/$habitId'));
    delReq.headers.set('Authorization', 'Bearer $tokenA');
    final delRes = await delReq.close();
    final delBody = await utf8.decodeStream(delRes);
    final delJson = jsonDecode(delBody) as Map<String, dynamic>;
    if (delRes.statusCode == 200 && delJson['archived'] == true) {
      print('✓ BASARILI (archived=true)');
    } else {
      throw Exception('Arsivleme basarisiz: $delBody');
    }

    // 10. GET /logs (Arsivlenen aliskanligin logu korunuyor mu?)
    stdout.write('10. GET /logs (Arsivlenen aliskanlik loglarinin korunmasi kontrolu)... ');
    final logsReq = await client.getUrl(Uri.parse('$baseUrl/logs?from=2026-10-01&to=2026-10-31'));
    logsReq.headers.set('Authorization', 'Bearer $tokenA');
    final logsRes = await logsReq.close();
    final logsBody = await utf8.decodeStream(logsRes);
    final logsJson = jsonDecode(logsBody) as List<dynamic>;
    final preservedLog = logsJson.firstWhere(
      (l) => l['habitId'] == habitId,
      orElse: () => null,
    );
    if (logsRes.statusCode == 200 && preservedLog != null && preservedLog['amount'] == 20) {
      print('✓ BASARILI (Log korundu: amount=20, completed=${preservedLog['completed']})');
    } else {
      throw Exception('Log korunmasi basarisiz: $logsBody');
    }

    // 11. GET /today (Gunun ilerlemesi, XP ve planli aliskanliklar)
    stdout.write('11. GET /today (Bugun ekrani ozeti ve ilerleme kontrolu)... ');
    final todayReq = await client.getUrl(Uri.parse('$baseUrl/today'));
    todayReq.headers.set('Authorization', 'Bearer $tokenA');
    final todayRes = await todayReq.close();
    final todayBody = await utf8.decodeStream(todayRes);
    final todayJson = jsonDecode(todayBody) as Map<String, dynamic>;
    if (todayRes.statusCode == 200 && todayJson['date'] != null && todayJson['progress'] != null) {
      print('✓ BASARILI (Tarih: ${todayJson['date']}, Ilerleme: %${todayJson['progress']['percentage']}, XP: ${todayJson['xp']['totalXp']})');
    } else {
      throw Exception('GET /today basarisiz: $todayBody');
    }

    print('\n🎉 CANLI BACKEND ALISKANLIK, LOG VE TODAY TESTLERININ TAMAMI BASARIYLA TAMAMLANDI!');
  } finally {
    client.close();
  }
}
