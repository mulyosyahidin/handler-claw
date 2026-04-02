import 'package:flutter/material.dart';

class EmptyAccountsPlaceholder extends StatelessWidget {
  const EmptyAccountsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 60, horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 64,
            color: Color(0x33000000), // Subtle color
          ),
          SizedBox(height: 16),
          Text(
            'Belum ada daftar rekening',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0x99000000),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Ketuk ikon + untuk menambah rekening baru',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Color(0x66000000)),
          ),
        ],
      ),
    );
  }
}
