import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/services.dart' show rootBundle;


//import 'dart:convert';
//import 'package:flutter/services.dart' show rootBundle;

Future<String> assetToBase64(String path) async {
  final bytes = await rootBundle.load(path);
  return base64Encode(bytes.buffer.asUint8List());
}

Future<String> buildInvoiceHtml(InvoiceData data) async {
  final logoBase64 = await assetToBase64('assets/logo.png');
  final stampBase64 = await assetToBase64('assets/stamp.png');
  //final qr = Barcode.qrCode();
  //final qrSvg = qr.toSvg('CC70472685XET', width: 150, height: 150);
  final itemsHtml = data.items.map((item) => """
    <tr>
      <td>${item.name}</td>
      <td>${item.price.toStringAsFixed(2)}</td>
      <td>${item.qty}</td>
      <td>${item.total.toStringAsFixed(2)}</td>
    </tr>
  """).join();

  return """
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>${data.invoiceNumber}</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 40px; }
    h1 { text-align: center; }
    table { width: 100%; border-collapse: collapse; margin-top: 20px; }
    th, td { border: 1px solid #ccc; padding: 8px; text-align: left; }
    .header {
      background-color: #2B2E7B;
      color: white;
      padding: 15px;
    }
    .watermark {
      position: fixed;
      top: 25%;
      left: 30%;
      opacity: 0.1;
      font-size: 80px;
      transform: rotate(-30deg);
      color: red;
    }
  </style>
</head>
<body>
  <div class="header">
    
    <div style="text-align:right; margin-top:0px;">
    <img src="data:image/png;base64,$logoBase64" width="80" style="vertical-align:middle;" />
    <span style="font-size:22px; font-weight:bold; margin-left:10px;">PostGebeya</span><br/>
    </div>
    <div style="text-align:left; margin-top:0px;">
    TIN: 0001033388<br/>
    VAT Reg.: 11977510003<br/>
    VAT Reg. Date: 16/06/2017<br/>
    Address: Addis Ababa, Lideta, Woreda 09, HouseNo 935
  </div>
  </div>

  <h1>Invoice #${data.invoiceNumber}</h1>
  <p><b>Date:</b> ${data.date.toLocal()}</p>
  <p><b>Tracking Number:</b> ${data.trackingNumber}</p>

  <h3>Billing Information</h3>
  <p>${data.companyName}, ${data.customerName}, ${data.customerPhone}, ${data.customerAddress}</p>

  <h3>Items</h3>
  <table>
    <tr><th>Name</th><th>Price</th><th>Qty</th><th>Total</th></tr>
    $itemsHtml
  </table>

  <p><b>Sub-total:</b> ${data.subtotal.toStringAsFixed(2)}</p>
  <p><b>Shipping:</b> ${data.shipping.toStringAsFixed(2)}</p>
  <p><b>Tax:</b> ${data.tax.toStringAsFixed(2)}</p>
  <p><b>Total:</b> ${data.total.toStringAsFixed(2)}</p>

  <!-- QR code aligned right -->
  <div style="text-align:right; margin-top:0px;">
    <img src="data:image/png;base64,$logoBase64" width="150" />
  </div>
  
  <div class="watermark">STAMP</div>

  <!-- Stamp watermark -->
  <div class="watermark">
    <img src="data:image/png;base64,$stampBase64" width="250" />
  </div>
  
</body>
</html>
""";
}


class InvoiceItem {
  final String name;
  final double price;
  final int qty;

  InvoiceItem({required this.name, required this.price, required this.qty});

  double get total => price * qty;
}

class InvoiceData {
  final String invoiceNumber;
  final DateTime date;
  final String trackingNumber;
  final String companyName;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final List<InvoiceItem> items;
  final double shipping;
  final double tax;

  InvoiceData({
    required this.invoiceNumber,
    required this.date,
    required this.trackingNumber,
    required this.companyName,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.items,
    required this.shipping,
    required this.tax,
  });

  double get subtotal => items.fold(0, (sum, item) => sum + item.total);
  double get total => subtotal + shipping + tax;
}

class InvoicePreviewPage extends StatelessWidget {
  final String htmlContent;
  InvoicePreviewPage(this.htmlContent);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Order Invoice")),
      body: InAppWebView(
        initialData: InAppWebViewInitialData(
          data: htmlContent,
          mimeType: "text/html",
          encoding: "utf-8",
        ),
      ),
    );
  }
}
