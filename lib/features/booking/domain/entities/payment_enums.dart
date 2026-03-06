
import 'package:app/core/constants/app_images.dart';
import 'package:flutter/material.dart';

enum PaymentMethod { esewa, khalti, cash }

class PaymentMethodData {
  final int id;
  final String name;
  final String svgPath;
  final Color? color;

  const PaymentMethodData({
    required this.id,
    required this.name,
    required this.svgPath,
    this.color,
  });
}

extension PaymentMethodX on PaymentMethod {
  PaymentMethodData get data {
    switch (this) {
      case PaymentMethod.esewa:
        return const PaymentMethodData(
          id: 1,
          name: 'eSewa',
          svgPath: AppImages.esewaIcon,
          color: Color(0xFF60BB46),
        );

      case PaymentMethod.khalti:
        return const PaymentMethodData(
          id: 2,
          name: 'Khalti',
          svgPath: AppImages.khaltiIcon,
          color: Color(0xFFFA084D),
        );

      case PaymentMethod.cash:
        return const PaymentMethodData(
          id: 3,
          name: 'Cash',
          svgPath: AppImages.bankTransferIcon,
          color: Colors.green,
        );
    }
  }
}
