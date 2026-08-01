import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:nopcommerce_mobile/frontend_api/lib/frontend_api.dart';

mixin AddressWidget {
  static const _blue = Color(0xFF2C2E7B);
  static const _orange = Color(0xFFF5AD00);

  Widget getAddressDropdown({
    required BuildContext context,
    required ListBuilder<AddressModelDto> addressess,
    required curentItem,
    required void Function(Object?) onChange,
  }) {
    final items = <DropdownMenuItem<AddressModelDto?>>[];

    items.add(
      DropdownMenuItem<AddressModelDto?>(
        value: null,
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: _orange.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Icon(Icons.add_rounded, color: _orange, size: 16),
            ),
            const SizedBox(width: 10),
            const Text(
              'Add New Address',
              style: TextStyle(
                color: _orange,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );

    addressess.build().forEach((addr) {
      items.add(
        DropdownMenuItem<AddressModelDto?>(
          value: addr,
          child: Text(
            getAddressLine(addr),
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              color: _blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    });

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<AddressModelDto?>(
          isExpanded: true,
          dropdownColor: Colors.white,
          elevation: 2,
          items: items,
          onChanged: onChange,
          value: curentItem,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _blue),
          style: const TextStyle(fontSize: 14, color: _blue),
        ),
      ),
    );
  }

  String getAddressLine(AddressModelDto? address) {
    if (address == null) return '';
    var line = '${address.firstName ?? ''} ${address.lastName ?? ''}'.trim();
    if ((address.streetAddressEnabled ?? false) &&
        (address.address1?.isNotEmpty ?? false)) {
      line += ', ${address.address1}';
    }
    if ((address.cityEnabled ?? false) && (address.city?.isNotEmpty ?? false)) {
      line += ', ${address.city}';
    }
    if ((address.countyEnabled ?? false) &&
        (address.county?.isNotEmpty ?? false)) {
      line += ', ${address.county}';
    }
    if ((address.stateProvinceEnabled ?? false) &&
        (address.stateProvinceName?.isNotEmpty ?? false)) {
      line += ', ${address.stateProvinceName}';
    }
    if ((address.zipPostalCodeEnabled ?? false) &&
        (address.zipPostalCode?.isNotEmpty ?? false)) {
      line += ' ${address.zipPostalCode}';
    }
    if ((address.countryEnabled ?? false) &&
        (address.countryName?.isNotEmpty ?? false)) {
      line += ', ${address.countryName}';
    }
    return line.trim();
  }
}
