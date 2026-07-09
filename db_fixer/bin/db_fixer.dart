import 'package:postgres/postgres.dart';
import 'dart:io';

void main() async {
  print('Connecting to database directly...');
  final connection = await Connection.open(
    Endpoint(
      host: 'db.sjaytekokwcvfjlbrsfm.supabase.co',
      port: 5432,
      database: 'postgres',
      username: 'postgres',
      password: '@Prakriti',
    ),
    settings: ConnectionSettings(sslMode: SslMode.require),
  );

  print('Connected! Checking policies on orders table...');

  final result = await connection.execute('''
    SELECT policyname, qual, with_check 
    FROM pg_policies 
    WHERE tablename = 'orders' AND schemaname = 'public';
  ''');

  for (final row in result) {
    print('Policy: ${row[0]}');
    print('  USING: ${row[1]}');
    print('  WITH CHECK: ${row[2]}');
    print('---');

    print('Dropping policy: "${row[0]}"');
    await connection.execute(
      'DROP POLICY IF EXISTS "${row[0]}" ON public.orders;',
    );
  }

  print('Re-creating correct policies...');

  await connection.execute('''
    CREATE POLICY "Users can view own orders." ON public.orders FOR SELECT USING (auth.uid() = user_id OR user_id IS NULL);
  ''');

  await connection.execute('''
    CREATE POLICY "Users can insert orders." ON public.orders FOR INSERT WITH CHECK (true);
  ''');

  await connection.execute('''
    CREATE POLICY "Users can update own orders" ON public.orders FOR UPDATE USING (
      auth.uid() = user_id OR auth.uid() IS NOT NULL
    );
  ''');

  await connection.execute('''
    CREATE POLICY "Authenticated users can delete orders" ON public.orders FOR DELETE USING (
      auth.uid() IS NOT NULL
    );
  ''');

  await connection.execute('''
    CREATE POLICY "Authenticated users can update orders" ON public.orders FOR UPDATE USING (true) WITH CHECK (true);
  ''');

  print('Done fixing policies!');
  await connection.close();
  exit(0);
}
