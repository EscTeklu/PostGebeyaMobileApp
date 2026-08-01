import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_api/frontend_api.dart';
import 'package:go_router/go_router.dart';
import 'package:nopcommerce_mobile/common_widgets/async_value.dart';
import 'package:nopcommerce_mobile/common_widgets/custom_text_form_field.dart';
import 'package:nopcommerce_mobile/common_widgets/responsive_scrollable.dart';
import 'package:nopcommerce_mobile/common_widgets/text_link.dart';
import 'package:nopcommerce_mobile/features/app/scaffold_messenger_extansion.dart';
import 'package:nopcommerce_mobile/features/customer/presentation/account/account_providers.dart';
import 'package:nopcommerce_mobile/features/orders/presentation/orders_providers.dart';
import 'package:nopcommerce_mobile/l10n/app_localizations_context.dart';
import 'package:nopcommerce_mobile/router/route_utils.dart';
import 'package:nopcommerce_mobile/utils/base_nop_state.dart';
import 'package:nopcommerce_mobile/utils/common_utility.dart';

const _blue = Color(0xFF2C2E7B);
const _orange = Color(0xFFF5AD00);
const _bg = Color(0xFFF4F5FB);

class ReturnRequestScreen extends ConsumerWidget {
  final int orderId;

  const ReturnRequestScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<BaseNopState>(
      returnRequestControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );

    final orderValue = ref.watch(returnRequestProvider(orderId));

    return AsyncValueWidget<SubmitReturnRequestModelDto>(
      value: orderValue,
      data: (model) =>
          ReturnRequestContents(orderId: orderId, requestModel: model),
    );
  }
}

class ReturnRequestContents extends ConsumerStatefulWidget {
  final int orderId;

  const ReturnRequestContents({
    super.key,
    this.onSave,
    required this.requestModel,
    required this.orderId,
  });
  final VoidCallback? onSave;
  final SubmitReturnRequestModelDto requestModel;

  @override
  ConsumerState<ReturnRequestContents> createState() => _ReturnRequestState();
}

class _ReturnRequestState extends ConsumerState<ReturnRequestContents> {
  String? comment;
  SubmitReturnRequestModelDto? requestModel;
  Map<int, int> selectedCount = {};
  int? returnReason;
  int? returnAction;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    requestModel = requestModel ?? widget.requestModel;
    final state = ref.watch(returnRequestControllerProvider);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _blue,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.locale!.return_request_title.format([widget.orderId]),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ),
      body: ResponsiveScrollable(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _buildBody(context, state),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, BaseNopState state) {
    if (requestModel?.items?.isEmpty ?? true) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Text(
            context.locale!.return_request_no_items,
            style: const TextStyle(
              color: _blue,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Products section
        _sectionCard(
          title: context.locale!.return_request_select_product,
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: requestModel?.items?.length ?? 0,
            itemBuilder: _orderItemBuilder,
          ),
        ),
        const SizedBox(height: 16),

        // Reason & Action section
        _sectionCard(
          title: context.locale!.return_request_why_returning,
          child: Column(
            children: [
              _styledDropdown<int>(
                hint: context.locale!.return_request_return_reason,
                value: returnReason,
                items: List.generate(
                  requestModel?.availableReturnReasons?.length ?? 0,
                  (i) => DropdownMenuItem<int>(
                    value: requestModel?.availableReturnReasons?[i].id ?? 0,
                    child: Text(
                      requestModel?.availableReturnReasons?[i].name ?? '',
                    ),
                  ),
                ),
                onChanged: (v) => setState(() => returnReason = v),
              ),
              const SizedBox(height: 12),
              _styledDropdown<int>(
                hint: context.locale!.return_request_return_action,
                value: returnAction,
                items: List.generate(
                  requestModel?.availableReturnActions?.length ?? 0,
                  (i) => DropdownMenuItem<int>(
                    value: requestModel?.availableReturnActions?[i].id ?? 0,
                    child: Text(
                      requestModel?.availableReturnActions?[i].name ?? '',
                    ),
                  ),
                ),
                onChanged: (v) => setState(() => returnAction = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Comment section
        _sectionCard(
          title: context.locale!.return_request_comments,
          child: Form(
            key: _formKey,
            child: CustomerTextFormField(
              context.locale!.return_request_comments,
              hintText: context.locale!.return_request_comments_hint,
              maxLines: 5,
              value: comment,
              (value) => setState(() => comment = value),
            ),
          ),
        ),
        const SizedBox(height: 20),

        SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _orange,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: state.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send_rounded, size: 20),
            label: Text(
              context.locale!.return_request_submit,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            onPressed: state.isLoading ? null : _sendReturnRequest,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _blue.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _orange,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    color: _blue,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }

  Widget _styledDropdown<T>({
    required String hint,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          hint: Text(
            hint,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _blue),
          style: const TextStyle(
            color: _blue,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _orderItemBuilder(BuildContext context, int index) {
    final item = requestModel?.items?[index];

    if (!selectedCount.containsKey(item?.id ?? 0)) {
      selectedCount[item?.id ?? 0] = 0;
    }

    if (item == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextLink(
                  label: item.productName ?? '',
                  onTap: () => context.pushNamed(
                    Routes.product.name,
                    pathParameters: {'id': item.productId.toString()},
                  ),
                  textStyle: const TextStyle(
                    color: _blue,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                if (item.attributeInfo != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      item.attributeInfo!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            item.unitPrice ?? '',
            style: const TextStyle(
              color: _blue,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: selectedCount[item.id ?? 0] ?? 0,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: _blue,
                  size: 16,
                ),
                style: const TextStyle(
                  color: _blue,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                items: List.generate(
                  (item.quantity ?? 0) + 1,
                  (i) => DropdownMenuItem<int>(
                    value: i,
                    child: Text(i.toString()),
                  ),
                ),
                onChanged: (v) => setState(() {
                  selectedCount[item.id ?? 0] = v ?? 0;
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future _sendReturnRequest() async {
    _formKey.currentState!.save();

    final controller = ref.read(returnRequestControllerProvider.notifier);

    final model = SubmitReturnRequestModelDtoBaseModelDtoRequestBuilder();
    final dataModel = SubmitReturnRequestModelDtoBuilder();
    dataModel.replace(widget.requestModel);

    dataModel.returnRequestReasonId = returnReason;
    dataModel.returnRequestActionId = returnAction;
    dataModel.comments = comment;

    final form = MapBuilder<String, String>();

    for (final entry in selectedCount.entries) {
      if (entry.value == 0) {
        continue;
      }
      form.addAll({'quantity${entry.key}': entry.value.toString()});
    }

    model.model = dataModel;
    model.form = form;

    await controller.sendReturnRequest(widget.orderId, model.build()).then((
      value,
    ) {
      if (value != null && mounted) {
        showInSnackBar(context, value.result!);
        ref.invalidate(customerOrdersProvider);
        setState(() {
          requestModel = value;
        });
      }
    });
  }
}
