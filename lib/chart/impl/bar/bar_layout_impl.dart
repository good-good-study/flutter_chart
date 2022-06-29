import 'package:flutter/material.dart';
import 'package:flutter_chart/chart/common/axis_delegate.dart';
import 'package:flutter_chart/chart/common/base_layout_config.dart';
import 'package:flutter_chart/chart/common/find.dart';
import 'package:flutter_chart/chart/common/gesture_delegate.dart';
import 'package:flutter_chart/chart/common/popup_spec.dart';
import 'package:flutter_chart/chart/model/chart_data_bar.dart';
import 'package:intl/intl.dart';

/// bar charts配置
class BarLayoutConfig extends BaseLayoutConfig<ChartDataBar> {
  BarLayoutConfig({
    required super.data,
    required super.size,
    super.axisCount,
    super.delegate,
    super.gestureDelegate,
    super.popupSpec,
    super.padding,
  });

  @override
  BarLayoutConfig copyWith({
    List<ChartDataBar>? data,
    Size? size,
    int? axisCount,
    AxisDelegate<ChartDataBar>? delegate,
    GestureDelegate? gestureDelegate,
    PopupSpec<ChartDataBar>? popupSpec,
    EdgeInsets? padding,
  }) {
    return BarLayoutConfig(
      data: data ?? this.data,
      size: size ?? this.size,
      axisCount: axisCount ?? this.axisCount,
      delegate: delegate ?? this.delegate,
      gestureDelegate: gestureDelegate ?? this.gestureDelegate,
      popupSpec: popupSpec ?? this.popupSpec,
      padding: padding ?? this.padding,
    );
  }

  /// x轴显示的刻度数量 0-24点
  /// 优先级比[AxisDelegate.xAxisFormatter]。
  @override
  String? xAxisValue(int index) {
    var hour = index;
    var now = DateTime.now();
    var date = DateTime(now.year, now.month, now.day, hour);
    return DateFormat('HH:mm').format(date);
  }

  /// 根据手势触摸坐标查找指定数据点位
  @override
  ChartTargetFind<ChartDataBar>? findTarget(Offset offset) {
    ChartTargetFind<ChartDataBar>? find;
    if (delegate == null) return null;
    // 两点之间的距离
    var itemWidth = delegate!.domainPointSpacing;
    // 选择点的最小匹配宽度
    var minSelectWidth = delegate!.minSelectWidth ?? itemWidth;
    // 当前拖拽的偏移量
    var dragX = (gestureDelegate!.offset).dx;

    /// y轴方向每段高度。
    var itemHeight = bounds.height / delegate!.hintLineNum;

    /// 1s时长对应的宽度，全程24小时，两个点之间的跨度为1小时。
    var dw = itemWidth / 3600; // 3600s为1小时

    /// bar高度
    var barHeight = 9;

    /// bubble 距离bar 右侧的距离
    var bubblePadding = 5;

    for (var index = 0; index < data.length; index++) {
      var model = data[index];
      if (!model.hasBubble) continue;

      var date = model.time;
      var hour = date.hour;
      var minute = date.minute;
      var seconds = date.second + minute * 60 + hour * 3600 + model.duration;

      var curr = Offset(
        bounds.left + dragX + seconds * dw - bubblePadding,
        bounds.top + (model.index + 1) * itemHeight - barHeight,
      );
      if ((curr - offset).dx.abs() <= minSelectWidth) {
        find = ChartTargetFind(model, curr);
        break;
      }
    }
    return find;
  }
}
