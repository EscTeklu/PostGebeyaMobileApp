import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:nopcommerce_mobile/frontend_api/lib/frontend_api.dart';

mixin AddressWidget {
  Widget getAddressDropdown({
    required BuildContext context,
    required ListBuilder<AddressModelDto> addressess,
    required curentItem,
    required void Function(Object?) onChange,
  }) {
    final itemo = <DropdownMenuItem<AddressModelDto>>[];
    itemo.add(

      const DropdownMenuItem(
        value: null,
        child: Card(
          color: Colors.indigo,
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text("New Address", style: TextStyle(color: Colors.white),),
            ),
          ),
        ) ,
      ),
    );
    var items = addressess.build().map((AddressModelDto items) {

      itemo.add(
        DropdownMenuItem(
          value: items,
          child: Card(
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  getAddressLine(items),
                ),
              ),
            ),
          ),
        ),
      );
      return ;
    }).toList();



    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButton(
          isExpanded: true,
          itemHeight: null,
          dropdownColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          elevation: 0,
          items: itemo,
          onChanged: onChange,
          value: curentItem,
          icon: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.arrow_right),
          ),
          style: Theme.of(context).textTheme.bodyLarge,
          underline: Container(
            height: 1,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String getAddressLine(AddressModelDto? address) {
    if (address == null) {
      return "";
    }

    var addressLine = address.firstName ?? "";
    addressLine += " ${address.lastName}";

    if ((address.streetAddressEnabled ?? false) &&
        (address.address1 != null && address.address1!.isNotEmpty)) {
      addressLine += ", ${address.address1}";
    }
    if ((address.cityEnabled ?? false) &&
        (address.city != null && address.city!.isNotEmpty)) {
      addressLine += ", ${address.city}";
    }
    if ((address.countyEnabled ?? false) &&
        (address.county != null && address.county!.isNotEmpty)) {
      addressLine += ", ${address.county}";
    }
    if ((address.stateProvinceEnabled ?? false) &&
        (address.stateProvinceName != null &&
            address.stateProvinceName!.isNotEmpty)) {
      addressLine += ", ${address.stateProvinceName}";
    }
    if ((address.zipPostalCodeEnabled ?? false) &&
        (address.zipPostalCode != null && address.zipPostalCode!.isNotEmpty)) {
      addressLine += " ${address.zipPostalCode}";
    }
    if ((address.countryEnabled ?? false) &&
        (address.countryName != null && address.countryName!.isNotEmpty)) {
      addressLine += ", ${address.countryName}";
    }

    return addressLine;
  }
}
