// ignore_for_file: avoid_print
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

void main() async {
  final supabaseUrl = 'https://sjaytekokwcvfjlbrsfm.supabase.co';
  final supabaseKey = 'sb_publishable_BDgWRw7xUPBxH-4bT9V8mw_6lqDmTPd';
  final client = SupabaseClient(supabaseUrl, supabaseKey);

  try {
    final response = await client
        .from('orders')
        .update({'status': 'prep'})
        .eq('orders.id', '123e4567-e89b-12d3-a456-426614174000');
    print('SUCCESS: $response');
  } catch (e) {
    print('ERROR: $e');
  }
  exit(0);
}
