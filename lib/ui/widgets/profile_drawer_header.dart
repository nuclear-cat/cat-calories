import 'package:flutter/material.dart';
import 'dart:math' as math;

class ProfileDrawerHeader extends StatefulWidget {
  const ProfileDrawerHeader({
    Key? key,
    this.decoration,
    this.margin = const EdgeInsets.only(bottom: 8.0),
    this.currentAccountPicture,
    this.otherAccountsPictures,
    this.currentAccountPictureSize = const Size.square(72.0),
    this.otherAccountsPicturesSize = const Size.square(40.0),
    required this.profileName,
    required this.info,
    this.onDetailsPressed,
    this.arrowColor = Colors.white,
  }) : super(key: key);

  final Decoration? decoration;
  final EdgeInsetsGeometry? margin;
  final Widget? currentAccountPicture;
  final List<Widget>? otherAccountsPictures;
  final Size currentAccountPictureSize;
  final Size otherAccountsPicturesSize;
  final Widget? profileName;
  final Widget? info;
  final VoidCallback? onDetailsPressed;
  final Color arrowColor;

  @override
  _ProfileDrawerHeaderState createState() => _ProfileDrawerHeaderState();
}

class _ProfileDrawerHeaderState extends State<ProfileDrawerHeader> {
  bool _isOpen = false;

  void _handleDetailsPressed() {
    setState(() {
      _isOpen = !_isOpen;
    });
    widget.onDetailsPressed!();
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    assert(debugCheckHasMaterialLocalizations(context));
    return Semantics(
      container: true,
      label: MaterialLocalizations.of(context).signedInLabel,
      child: DrawerHeader(
        decoration: widget.decoration ?? BoxDecoration(
          color: Theme.of(context).primaryColor,
        ),
        margin: widget.margin,
        padding: const EdgeInsetsDirectional.only(top: 16.0, start: 16.0),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(end: 16.0),
                  child: _AccountPictures(
                    currentAccountPicture: widget.currentAccountPicture,
                    otherAccountsPictures: widget.otherAccountsPictures,
                    currentAccountPictureSize: widget.currentAccountPictureSize,
                    otherAccountsPicturesSize: widget.otherAccountsPicturesSize,
                  ),
                ),
              ),
              _AccountDetails(
                accountName: widget.profileName,
                accountEmail: widget.info,
                isOpen: _isOpen,
                onTap: widget.onDetailsPressed == null ? null : _handleDetailsPressed,
                arrowColor: widget.arrowColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class _AccountDetails extends StatefulWidget {
  const _AccountDetails({
    Key? key,
    required this.accountName,
    required this.accountEmail,
    this.onTap,
    required this.isOpen,
    this.arrowColor,
  }) : super(key: key);

  final Widget? accountName;
  final Widget? accountEmail;
  final VoidCallback? onTap;
  final bool isOpen;
  final Color? arrowColor;

  @override
  _AccountDetailsState createState() => _AccountDetailsState();
}

class _AccountDetailsState extends State<_AccountDetails> with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _controller;
  @override
  void initState () {
    super.initState();
    _controller = AnimationController(
      value: widget.isOpen ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.fastOutSlowIn.flipped,
    )
      ..addListener(() => setState(() {
        // [animation]'s value has changed here.
      }));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget (_AccountDetails oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the state of the arrow did not change, there is no need to trigger the animation
    if (oldWidget.isOpen == widget.isOpen) {
      return;
    }

    if (widget.isOpen) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasDirectionality(context));
    assert(debugCheckHasMaterialLocalizations(context));
    assert(debugCheckHasMaterialLocalizations(context));

    final ThemeData theme = Theme.of(context);
    final MaterialLocalizations localizations = MaterialLocalizations.of(context);

    Widget accountDetails = CustomMultiChildLayout(
      delegate: _AccountDetailsLayout(
        textDirection: Directionality.of(context),
      ),
      children: <Widget>[
        if (widget.accountName != null)
          LayoutId(
            id: _AccountDetailsLayout.accountName,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: DefaultTextStyle(
                style: theme.primaryTextTheme.bodyText1!,
                overflow: TextOverflow.ellipsis,
                child: widget.accountName!,
              ),
            ),
          ),
        if (widget.accountEmail != null)
          LayoutId(
            id: _AccountDetailsLayout.accountEmail,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: DefaultTextStyle(
                style: theme.primaryTextTheme.bodyText2!,
                overflow: TextOverflow.ellipsis,
                child: widget.accountEmail!,
              ),
            ),
          ),
        if (widget.onTap != null)
          LayoutId(
            id: _AccountDetailsLayout.dropdownIcon,
            child: Semantics(
              container: true,
              button: true,
              onTap: widget.onTap,
              child: SizedBox(
                height: _kAccountDetailsHeight,
                width: _kAccountDetailsHeight,
                child: Center(
                  child: Transform.rotate(
                    angle: _animation.value * math.pi,
                    child: Icon(
                      Icons.arrow_drop_down,
                      color: widget.arrowColor,
                      semanticLabel: widget.isOpen
                          ? localizations.hideAccountsLabel
                          : localizations.showAccountsLabel,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );

    if (widget.onTap != null) {
      accountDetails = InkWell(
        onTap: widget.onTap,
        child: accountDetails,
        excludeFromSemantics: true,
      );
    }

    return SizedBox(
      height: _kAccountDetailsHeight,
      child: accountDetails,
    );
  }
}


const double _kAccountDetailsHeight = 56.0;

class _AccountDetailsLayout extends MultiChildLayoutDelegate {

  _AccountDetailsLayout({ required this.textDirection });

  static const String accountName = 'accountName';
  static const String accountEmail = 'accountEmail';
  static const String dropdownIcon = 'dropdownIcon';

  final TextDirection textDirection;

  @override
  void performLayout(Size size) {
    Size? iconSize;
    if (hasChild(dropdownIcon)) {
      // place the dropdown icon in bottom right (LTR) or bottom left (RTL)
      iconSize = layoutChild(dropdownIcon, BoxConstraints.loose(size));
      positionChild(dropdownIcon, _offsetForIcon(size, iconSize));
    }

    final String? bottomLine = hasChild(accountEmail) ? accountEmail : (hasChild(accountName) ? accountName : null);

    if (bottomLine != null) {
      final Size constraintSize = iconSize == null ? size : Size(size.width - iconSize.width, size.height);
      iconSize ??= const Size(_kAccountDetailsHeight, _kAccountDetailsHeight);

      // place bottom line center at same height as icon center
      final Size bottomLineSize = layoutChild(bottomLine, BoxConstraints.loose(constraintSize));
      final Offset bottomLineOffset = _offsetForBottomLine(size, iconSize, bottomLineSize);
      positionChild(bottomLine, bottomLineOffset);

      // place account name above account email
      if (bottomLine == accountEmail && hasChild(accountName)) {
        final Size nameSize = layoutChild(accountName, BoxConstraints.loose(constraintSize));
        positionChild(accountName, _offsetForName(size, nameSize, bottomLineOffset));
      }
    }
  }

  @override
  bool shouldRelayout(MultiChildLayoutDelegate oldDelegate) => true;

  Offset _offsetForIcon(Size size, Size iconSize) {
    switch (textDirection) {
      case TextDirection.ltr:
        return Offset(size.width - iconSize.width, size.height - iconSize.height);
      case TextDirection.rtl:
        return Offset(0.0, size.height - iconSize.height);
    }
  }

  Offset _offsetForBottomLine(Size size, Size iconSize, Size bottomLineSize) {
    final double y = size.height - 0.5 * iconSize.height - 0.5 * bottomLineSize.height;
    switch (textDirection) {
      case TextDirection.ltr:
        return Offset(0.0, y);
      case TextDirection.rtl:
        return Offset(size.width - bottomLineSize.width, y);
    }
  }

  Offset _offsetForName(Size size, Size nameSize, Offset bottomLineOffset) {
    final double y = bottomLineOffset.dy - nameSize.height;
    switch (textDirection) {
      case TextDirection.ltr:
        return Offset(0.0, y);
      case TextDirection.rtl:
        return Offset(size.width - nameSize.width, y);
    }
  }
}



class _AccountPictures extends StatelessWidget {
  const _AccountPictures({
    Key? key,
    this.currentAccountPicture,
    this.otherAccountsPictures,
    this.currentAccountPictureSize,
    this.otherAccountsPicturesSize,
  }) : super(key: key);

  final Widget? currentAccountPicture;
  final List<Widget>? otherAccountsPictures;
  final Size? currentAccountPictureSize;
  final Size? otherAccountsPicturesSize;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        PositionedDirectional(
          top: 0.0,
          end: 0.0,
          child: Row(
            children: (otherAccountsPictures ?? <Widget>[]).take(3).map<Widget>((Widget picture) {
              return Padding(
                padding: const EdgeInsetsDirectional.only(start: 8.0),
                child: Semantics(
                  container: true,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                    child: SizedBox.fromSize(
                      size: otherAccountsPicturesSize,
                      child: picture,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Positioned(
          top: 0.0,
          child: Semantics(
            explicitChildNodes: true,
            child: SizedBox.fromSize(
              size: currentAccountPictureSize,
              child: currentAccountPicture,
            ),
          ),
        ),
      ],
    );
  }
}