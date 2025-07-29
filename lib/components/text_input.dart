import 'package:flutter/material.dart';
import 'package:location_tracker/util/consts.dart';

class CustomTextInput extends StatelessWidget {
  final TextEditingController? controller;
  final Function(String)? onChange;
  final Function? onTrailingTitleClick;
  final String? Function(String?)? validator;
  final String? floatingText;
  final String? hintText;
  final String? titleLabel;
  final int? maxLine;
  final String? trailingTitleLabel;
  final double? titleFontSize;
  final FontWeight? titleFontWeight;
  final Color? fieldTextColor;
  final Color? trailingTitleColor;
  final Color? controllerTextColor;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final double? borderRadius;
  final double? controllerFontSize;
  final double? contentPaddingValue;
  final double? hintFontSize;
  final FontWeight? fontWeight;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final FocusNode? focusNode;
  final Color? inactiveBorderColor;
  final Color? borderRadiusColor;
  final Color? bgColor;
  final Color? titleColor;
  final bool? obscure;
  final bool? isActive;
  final bool readOnly;
  final bool? applyBgColor;
  final bool? isNairaField;
  final bool? preventNumericInNameField;
  final bool? useThousandSeparator;
  final bool? shouldFormatDate;

  const CustomTextInput({
    super.key,
    this.controller,
    this.onChange,
    this.onTrailingTitleClick,
    this.validator,
    this.floatingText,
    this.hintText,
    this.titleLabel,
    this.maxLine = 1,
    this.trailingTitleLabel,
    this.trailingTitleColor,
    this.titleFontSize,
    this.titleFontWeight,
    this.fieldTextColor,
    this.controllerTextColor,
    this.keyboardType,
    this.textInputAction,
    this.controllerFontSize,
    this.borderRadius,
    this.contentPaddingValue,
    this.hintFontSize,
    this.fontWeight,
    this.focusNode,
    this.inactiveBorderColor,
    this.borderRadiusColor,
    this.bgColor,
    this.titleColor,
    this.prefixIcon,
    this.suffixIcon,
    this.obscure = false,
    this.isActive = true,
    this.readOnly = false,
    this.applyBgColor = false,
    this.isNairaField = false,
    this.preventNumericInNameField = false,
    this.useThousandSeparator = false,
    this.shouldFormatDate = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: floatingText == null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  titleLabel ?? "",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: titleFontSize,
                    fontWeight: titleFontWeight ?? FontWeight.w500,
                  ),
                ),
              ),
              Visibility(
                visible: trailingTitleLabel != null,
                child: InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: onTrailingTitleClick == null ? null : () => onTrailingTitleClick!(),
                  child: Text(
                    trailingTitleLabel ?? "",
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: titleFontWeight ?? FontWeight.w500,
                      color: trailingTitleColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller ?? TextEditingController(),
          keyboardType: keyboardType,
          textInputAction: textInputAction ?? TextInputAction.next,
          obscureText: obscure ?? false,
          validator: validator,
          focusNode: focusNode,
          enabled: isActive,
          maxLines: maxLine,
          readOnly: readOnly,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          textCapitalization: TextCapitalization.words,
          style: TextStyle(
            color: controllerTextColor,
            fontSize: controllerFontSize,
          ),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: contentPaddingValue ?? 10),
            border: OutlineInputBorder(
              borderSide: BorderSide(width: 0.3, color: borderRadiusColor ?? kPrimaryColor),
              borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? 10)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 0.3, color: borderRadiusColor ?? kPrimaryColor),
              borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? 10)),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 0.3, color: borderRadiusColor ?? kPrimaryColor),
              borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? 10)),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 0.3, color: borderRadiusColor ?? kPrimaryColor),
              borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? 10)),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(width: 0.3, color: Colors.red),
              borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? 10)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: const BorderSide(width: 0.3, color: Colors.red),
              borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? 10)),
            ),
            hintText: floatingText == null ? hintText : "",
            labelText: floatingText,
            hintStyle: TextStyle(color: fieldTextColor ?? Colors.grey.withOpacity(0.5), fontSize: hintFontSize ?? 14, fontWeight: fontWeight),
            labelStyle: TextStyle(color: fieldTextColor ?? Colors.grey.withOpacity(0.5)),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
          ),
          onChanged: onChange == null ? null : (val) async => onChange!(val),
        ),
      ],
    );
  }
}
