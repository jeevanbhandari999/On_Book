enum PaymentMethod {
  esewa,
  khalti,
  cash,
}

extension PaymentMethodX on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.esewa:
        return 'eSewa';
      case PaymentMethod.khalti:
        return 'Khalti';
      case PaymentMethod.cash:
        return 'Cash';
    }
  }
}
