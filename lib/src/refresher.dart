part of easyrefresh;

class EasyRefresh extends StatefulWidget {
  /// 子组件
  final Widget child;

  /// 刷新回调
  final FutureOr Function()? onRefresh;

  /// 加载回调
  final FutureOr Function()? onLoad;

  const EasyRefresh({
    Key? key,
    required this.child,
    this.onRefresh,
    this.onLoad,
  }) : super(key: key);

  @override
  _EasyRefreshState createState() => _EasyRefreshState();
}

class _EasyRefreshState extends State<EasyRefresh>
    with TickerProviderStateMixin {
  /// 滚动行为
  late ERScrollBehavior _scrollBehavior;

  /// 用户偏移通知器(记录是否为用户滚动)
  ValueNotifier<bool> _userOffsetNotifier = ValueNotifier<bool>(false);

  /// Header通知器
  late HeaderNotifier _headerNotifier;

  /// Footer通知器
  late FooterNotifier _footerNotifier;

  /// 更新中
  bool _refreshing = false;

  /// 加载中
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _headerNotifier = HeaderNotifier(
      triggerOffset: 70,
      clamping: true,
      userOffsetNotifier: _userOffsetNotifier,
      vsync: this,
    );
    _footerNotifier = FooterNotifier(
      triggerOffset: 70,
      clamping: false,
      userOffsetNotifier: _userOffsetNotifier,
      vsync: this,
    );
    _scrollBehavior = ERScrollBehavior(ERScrollPhysics(
      userOffsetNotifier: _userOffsetNotifier,
      headerNotifier: _headerNotifier,
      footerNotifier: _footerNotifier,
    ));
    // Future(() {
    //   PrimaryScrollController.of(context)!.addListener(() {
    //     print(PrimaryScrollController.of(context)!.position.pixels);
    //   });
    // });
    _headerNotifier.addListener(() {
      // 执行刷新任务
      if (_headerNotifier._mode == IndicatorMode.processing) {
        if (!_refreshing) {
          _refreshing = true;
          Future.sync(widget.onRefresh!).whenComplete(() {
            _refreshing = false;
            _headerNotifier.setMode(IndicatorMode.done);
          });
        }
      }
    });
    _footerNotifier.addListener(() {
      // 执行加载任务
      if (_footerNotifier._mode == IndicatorMode.processing) {
        if (!_loading) {
          _loading = true;
          Future.sync(widget.onLoad!).whenComplete(() {
            _loading = false;
            _footerNotifier.setMode(IndicatorMode.done);
          });
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _userOffsetNotifier.dispose();
  }

  /// 构建Header容器
  Widget _buildHeaderView() {
    return ValueListenableBuilder(
      valueListenable: _headerNotifier.listenable(),
      builder: (ctx, notifier, _) {
        if (_headerNotifier._axis == null ||
            _headerNotifier._axisDirection == null) {
          return SizedBox();
        }
        // 方向
        final axis = _headerNotifier._axis!;
        final axisDirection = _headerNotifier._axisDirection!;
        return Positioned(
          top: axis == Axis.vertical
              ? axisDirection == AxisDirection.down
                  ? 0
                  : null
              : 0,
          bottom: axis == Axis.vertical
              ? axisDirection == AxisDirection.up
                  ? 0
                  : null
              : 0,
          left: axis == Axis.horizontal
              ? axisDirection == AxisDirection.right
                  ? 0
                  : null
              : 0,
          right: axis == Axis.horizontal
              ? axisDirection == AxisDirection.left
                  ? 0
                  : null
              : 0,
          child: Container(
            color: Colors.blue,
            width: axis == Axis.vertical
                ? double.infinity
                : _headerNotifier._offset,
            height: axis == Axis.vertical
                ? _headerNotifier._offset
                : double.infinity,
          ),
        );
      },
    );
  }

  /// 构建Footer容器
  Widget _buildFooterView() {
    return ValueListenableBuilder(
      valueListenable: _footerNotifier.listenable(),
      builder: (ctx, notifier, _) {
        if (_headerNotifier._axis == null ||
            _headerNotifier._axisDirection == null) {
          return SizedBox();
        }
        // 方向
        final axis = _headerNotifier._axis!;
        final axisDirection = _headerNotifier._axisDirection!;
        return Positioned(
          top: axis == Axis.vertical
              ? axisDirection == AxisDirection.up
                  ? 0
                  : null
              : 0,
          bottom: axis == Axis.vertical
              ? axisDirection == AxisDirection.down
                  ? 0
                  : null
              : 0,
          left: axis == Axis.horizontal
              ? axisDirection == AxisDirection.left
                  ? 0
                  : null
              : 0,
          right: axis == Axis.horizontal
              ? axisDirection == AxisDirection.right
                  ? 0
                  : null
              : 0,
          child: Container(
            color: Colors.blue,
            width: axis == Axis.vertical
                ? double.infinity
                : _footerNotifier._offset,
            height: axis == Axis.vertical
                ? _footerNotifier._offset
                : double.infinity,
          ),
        );
      },
    );
  }

  /// 构建子组件
  Widget _buildChild() {
    Widget child = ScrollConfiguration(
      behavior: _scrollBehavior,
      child: widget.child,
    );
    return child;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildChild(),
        _buildHeaderView(),
        _buildFooterView(),
      ],
    );
  }
}
