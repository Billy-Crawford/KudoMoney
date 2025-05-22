// lib/widgets/transaction_card.dart

import 'package:flutter/material.dart';

class TransactionCard extends StatelessWidget {
  final String beneficiary;
  final String amount;
  final String dateTime;
  final String status;

  const TransactionCard({
    super.key,
    required this.beneficiary,
    required this.amount,
    required this.dateTime,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSuccess = status.toLowerCase() == "succès";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Bénéficiaire : $beneficiary",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Text("Montant : $amount"),
          Text("Date et heure : $dateTime"),
          Row(
            children: [
              const Text("Status : "),
              Text(
                status,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSuccess ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
