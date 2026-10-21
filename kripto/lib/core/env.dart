class AppEnv {
  AppEnv._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://ygfunxnzfgaqmjnqkokz.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_d5iDOsQgYJb_iicO14d8tQ_ypxqBZD0',
  );
}
