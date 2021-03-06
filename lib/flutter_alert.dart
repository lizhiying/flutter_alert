import 'dart:io' show Platform;
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// An action configuration object. For each button in an alert dialog
/// one set of options and one callback handles should be defined.
class AlertAction {
  /// The title of the alert button.
  /// Required.
  final String text;

  final TextStyle textStyle;

  /// Defines if the button is the default button.
  /// Set this value to true to render the button with a bold text weight.
  /// The default value is false.
  final bool isDefaultAction;

  /// Defines if the button is a destructive or dangerous button.
  /// Set this value to true to render this button with a red text color.
  /// The default value is false.
  final bool isDestructiveAction;

  /// Callback handler when this button was pressed.
  final VoidCallback onPressed;

  /// Defines if the button will automatically close the dialog by
  /// trigger a Navigation pop action or not.
  /// The default value is true.
  final bool automaticallyPopNavigation;

  const AlertAction({
    /// The title of the alert button.
    /// Required.
    @required this.text,

    /// Defines if the button is the default button.
    /// Set this value to true to render the button with a bold text weight.
    /// The default value is false.
    this.isDefaultAction = false,

    /// Defines if the button is a destructive or dangerous button.
    /// Set this value to true to render this button with a red text color.
    /// The default value is false.
    this.isDestructiveAction = false,

    /// Callback handler when this button was pressed.
    @required this.onPressed,
    @required this.textStyle,

    /// Defines if the button will automatically close the dialog by
    /// trigger a Navigation pop action or not.
    /// The default value is true.
    this.automaticallyPopNavigation = true,
  });
}

/// Shows an alert dialog.
void showAlert({
  /// A build context. Required.
  @required BuildContext context,

  /// The title of the modal dialog.
  String title,
  TextStyle titleStyle,

  /// The body (or content) of the modal dialog.
  /// The text was automatically rendered in a ScrollView.
  String body,
  TextStyle bodyStyle,
  TextStyle cancelTextStyle,

  /// A List of actions. For each action there was shown one button.
  /// If there was no action defined, a default action with a
  /// (localized) "OK" button was shown.
  List<AlertAction> actions,

  /// Allow you to define if the alert dialog is closable when
  /// the users taps beside the alert dialog.
  /// Default is only true when cancelable is set to true
  /// and the platform is not iOS.
  bool barrierDismissible,

  //when the Android phone back button is pressed
  VoidCallback onPhoneBackPressed,
  //Is it allowed to disappear when the Android phone back button is pressed
  bool isWillPop = true,

  /// Automatically adds a (localized) "Cancel" button to the list
  /// of buttons. Currently its not possible to handle the cancel
  /// button.
  /// Only if this option was set to true. The default is false.
  bool cancelable = false,

  /// Define if the Cupertino or Material UI package should be used.
  /// The default is that the Cupertino package was used on iOS,
  /// and the Material UI package in all other cases.
  bool useCupertino,
}) {
  if (actions == null || actions.isEmpty) {
    actions = [
      AlertAction(
          text: MaterialLocalizations.of(context).okButtonLabel,
          onPressed: () {})
    ];
  }
  if (barrierDismissible == null) {
    barrierDismissible = cancelable && !Platform.isIOS;
  }
  if (cancelable) {
    actions.add(AlertAction(
        text: MaterialLocalizations.of(context)
                .cancelButtonLabel
                .substring(0, 1) +
            MaterialLocalizations.of(context)
                .cancelButtonLabel
                .substring(1)
                .toLowerCase(),
        textStyle: cancelTextStyle,
        onPressed: () {}));
  }
  if (useCupertino == null) {
    useCupertino = Platform.isIOS;
  }

  if (useCupertino) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => _buildDialog(
          context, title, body, actions, useCupertino, onPhoneBackPressed,
          isWillPop: isWillPop, titleStyle: titleStyle, bodyStyle: bodyStyle),
    );
  } else {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) => _buildDialog(
          context, title, body, actions, useCupertino, onPhoneBackPressed,
          isWillPop: isWillPop, titleStyle: titleStyle, bodyStyle: bodyStyle),
    );
  }
}

Widget _buildDialog(
    BuildContext context,
    String title,
    String body,
    List<AlertAction> actions,
    bool useCupertino,
    VoidCallback onPhoneBackPressed,
    {bool isWillPop,
    TextStyle titleStyle,
    TextStyle bodyStyle}) {
  if (useCupertino) {
    return WillPopScope(
        child: CupertinoAlertDialog(
          title: _buildTitle(title, titleStyle),
          content: _buildBody(body, bodyStyle),
          actions: _buildActionButtons(context, actions, useCupertino),
        ),
        onWillPop: () async {
          if (onPhoneBackPressed != null) {
            onPhoneBackPressed();
          }
          return Future.value(isWillPop);
        });
  } else {
    return WillPopScope(
        child: AlertDialog(
          title: _buildTitle(title, titleStyle),
          content: _buildBody(body, bodyStyle),
          actions: _buildActionButtons(context, actions, useCupertino),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5))),
        ),
        onWillPop: () async {
          if (onPhoneBackPressed != null) {
            onPhoneBackPressed();
          }
          return Future.value(isWillPop);
        });
  }
}

Widget _buildTitle(String title, TextStyle titleStyle) {
  if (title == null || title.isEmpty) {
    return null;
  }
  return Text(
    title,
    style: titleStyle,
  );
}

Widget _buildBody(String body, TextStyle bodyStyle) {
  if (body == null || body.isEmpty) {
    return null;
  }
  return SingleChildScrollView(
      child: new Container(
          margin: new EdgeInsets.only(top: 10.0),
          child: Text(
            body,
            style: bodyStyle,
          )));
}

List<Widget> _buildActionButtons(
  BuildContext context,
  List<AlertAction> actions,
  bool useCupertino,
) {
  return actions
      .map((AlertAction action) =>
          _buildActionButton(context, action, useCupertino))
      .toList();
}

Widget _buildActionButton(
    BuildContext context, AlertAction action, bool useCupertino) {
  VoidCallback onPressed = () {
    if (action.automaticallyPopNavigation) {
      NavigatorState navigatorState = Navigator.of(context);
      if (navigatorState.canPop()) {
        navigatorState.pop();
      }
    }
    if (action.onPressed != null) {
      action.onPressed();
    }
  };

  if (useCupertino) {
    return CupertinoDialogAction(
      child: Text(
        action.text != null ? action.text : "",
        style: action.textStyle,
      ),
      isDefaultAction: action.isDefaultAction,
      isDestructiveAction: action.isDestructiveAction,
      onPressed: onPressed,
    );
  } else {
    return FlatButton(
      child: Text(
        action.text != null ? action.text.toUpperCase() : "",
        style: action.isDefaultAction
            ? TextStyle(fontWeight: FontWeight.bold)
            : null,
      ),
      textColor: action.isDestructiveAction ? Colors.red.shade600 : null,
      highlightColor: action.isDestructiveAction ? Colors.red.shade50 : null,
      onPressed: onPressed,
    );
  }
}
