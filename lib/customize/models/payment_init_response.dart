class PaymentInitResponse {
  final bool success;
  final String message;
  final String paymentUrl;
  final String orderId;
  final String txnRef;

  PaymentInitResponse({required this.success, required this.message, required this.paymentUrl, required this.orderId, required this.txnRef});

  factory PaymentInitResponse.fromJson(Map<String, dynamic> json) {
    return PaymentInitResponse(
      success: json['success'] == true || json['Success'] == true,
      message: (json['message'] ?? json['Message'] ?? '').toString(),
      paymentUrl: (json['paymentUrl'] ?? json['PaymentUrl'] ?? '').toString(),
      orderId: (json['orderId'] ?? json['orderId'] ?? '').toString(),
      txnRef: (json['txnRef'] ?? json['TxnRef'] ?? '').toString(),
    );
  }
}
