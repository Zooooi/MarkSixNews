import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marksix/main/extensions/context_theme.dart';
import 'package:marksix/main/models/values/response.dart';
import 'package:url_launcher/url_launcher.dart';

/// 1. 元件解析器抽象介面 (Strategy Pattern)
abstract class WidgetParser {
  /// 對應 JSON 中的 "type"，例如 "Column", "Card", "RichText"
  String get widgetType;

  /// 解析並構建 Flutter Widget
  Widget build(Map<String, dynamic> attributes, Map<String, dynamic>? node, DynamicUiBuilder builder);
}

/// 2. 動態 UI 解析器核心類別 (Dynamic UI Builder)
class DynamicUiBuilder {
  final BuildContext context;
  final Map<String, WidgetParser> _parsers = {};

  DynamicUiBuilder(this.context) {
    // 註冊所有可用的元件解析器
    _register(ScaffoldParser());
    _register(SingleChildScrollViewParser());
    _register(ColumnParser());
    _register(RowParser());
    _register(WrapParser());
    _register(SizedBoxParser());
    _register(ContainerParser());
    _register(ExpandedParser());
    _register(HeaderCardParser());
    _register(CardParser());
    _register(ListTileParser());
    _register(DividerParser());
    _register(ImageParser());
    _register(TextParser());
    _register(RichTextParser());
    _register(TagParser());
    _register(FeatureItemParser());
    _register(ButtonParser());
  }

  void _register(WidgetParser parser) {
    _parsers[parser.widgetType] = parser;
  }

  // ================= 核心遞迴與迴圈處理 =================

  /// 單一節點解析 (遞迴入口)
  Widget buildNode(Map<String, dynamic>? node) {
    if (node == null) return const SizedBox.shrink();

    final type = node['type'] as String?;
    final parser = _parsers[type];

    if (parser != null) {
      final attr = (node['attributes'] as Map<String, dynamic>?) ?? {};
      return parser.build(attr, node, this);
    }

    // 容錯機制：遇到未知的元件類型時輸出警告，不影響其他 UI 渲染
    debugPrint('DynamicUiBuilder Warning: Unknown widget type "$type"');
    return const SizedBox.shrink();
  }

  /// 迴圈走訪：將 JSON 的 "children" 陣列全數轉換為 List< Widget>
  List<Widget> buildChildren(Map<String, dynamic>? node) {
    if (node == null || node['children'] == null) return [];

    final rawList = node['children'] as List;
    final List<Widget> childrenWidgets = [];

    for (final item in rawList) {
      if (item is Map<String, dynamic>) {
        childrenWidgets.add(buildNode(item)); // 遞迴呼叫 buildNode
      }
    }

    return childrenWidgets;
  }

  // ================= Token 樣式解析工具 =================

  Color parseColor(String? token) {
    if (token == null) return Colors.transparent;
    final wc = context.widgetColors;
    final tc = context.textColors;
    switch (token) {
      // Widget Backgrounds & Borders (wc)
      case 'wc.primary':
        return wc.primary;
      case 'wc.secondary':
        return wc.secondary;
      case 'wc.buttonTip1':
        return wc.buttonTip1;
      case 'wc.buttonTip2':
        return wc.buttonTip2;
      case 'wc.cardColor':
        return wc.cardColor;
      case 'wc.divider':
        return wc.divider;
      case 'wc.activeColor':
        return wc.activeColor;
      case 'wc.borderColor1':
        return wc.borderColor1;
      case 'wc.borderColor2':
        return wc.borderColor2;
      case 'wc.borderColor3':
        return wc.borderColor3;
      // Text Colors (tc)
      case 'tc.primary':
        return tc.primary;
      case 'tc.secondary':
        return tc.secondary;
      case 'tc.third':
        return tc.third;
      case 'tc.helpInfo':
        return tc.helpInfo;

      default:
        if (token.startsWith('#')) {
          return Color(int.parse(token.replaceFirst('#', '0xFF')));
        }
        return Colors.transparent;
    }
  }

  TextStyle parseTextStyle(String? token, String? colorToken) {
    final tt = context.textTheme;
    TextStyle style;

    switch (token) {
      case 'tt.titleLarge':
        style = tt.titleLarge!;
        break;
      case 'tt.titleMedium':
        style = tt.titleMedium!;
        break;
      case 'tt.titleSmall':
        style = tt.titleSmall!;
        break;
      case 'tt.bodyLarge':
        style = tt.bodyLarge!;
        break;
      case 'tt.bodyMedium':
        style = tt.bodyMedium!;
        break;
      case 'tt.bodySmall':
        style = tt.bodySmall!;
        break;
      case 'tt.labelLarge':
        style = tt.labelLarge!;
        break;
      case 'tt.labelMedium':
        style = tt.labelMedium!;
        break;
      case 'tt.labelSmall':
        style = tt.labelSmall!;
        break;
      case 'tt.displayLarge':
        style = tt.displayLarge!;
        break;
      case 'tt.displayMedium':
        style = tt.displayMedium!;
        break;
      default:
        style = tt.displayMedium!;
    }
    if (colorToken != null) {
      style = style.copyWith(color: parseColor(colorToken));
    }
    return style;
  }

  double parseSpace(String? token, {double defaultVal = 0.0}) {
    switch (token) {
      case 'res.space_1':
        return res.space_1;
      case 'res.space_2':
        return res.space_2;
      case 'res.space_3':
        return res.space_3;
      case 'res.space_4':
        return res.space_4;
      default:
        return res.space_0;
    }
  }

  EdgeInsets parsePadding(String? token) {
    switch (token) {
      case 'res.padding_1':
        return EdgeInsets.all(res.padding_1);
      case 'res.padding_2':
        return EdgeInsets.all(res.padding_2);
      case 'res.padding_3':
        return EdgeInsets.all(res.padding_3);
      case 'res.padding_4':
        return EdgeInsets.all(res.padding_4);
      default:
        return EdgeInsets.zero;
    }
  }

  double parseRadius(String? token) {
    switch (token) {
      case 'res.radius_1':
        return res.radius_1;
      case 'res.radius_2':
        return res.radius_2;
      case 'res.radius_3':
        return res.radius_3;
      default:
        return 0.0;
    }
  }
}

// ================= 3. 各具體的 Widget 解析器實作 =================

class ScaffoldParser extends WidgetParser {
  @override
  String get widgetType => 'Scaffold';

  @override
  Widget build(Map<String, dynamic> attributes, Map<String, dynamic>? node, DynamicUiBuilder builder) {
    // 提取 body，並用 Expanded 包住 ScrollView
    return Expanded(child: builder.buildNode(node?['body'] ?? node?['child']));
  }
}

class SingleChildScrollViewParser extends WidgetParser {
  @override
  String get widgetType => 'SingleChildScrollView';

  @override
  Widget build(Map<String, dynamic> attributes, Map<String, dynamic>? node, DynamicUiBuilder builder) {
    return SingleChildScrollView(child: builder.buildNode(node?['child']));
  }
}

class ColumnParser extends WidgetParser {
  @override
  String get widgetType => 'Column';

  @override
  Widget build(Map<String, dynamic> attributes, Map<String, dynamic>? node, DynamicUiBuilder builder) {
    return Padding(
      padding: builder.parsePadding(attributes['padding']),
      child: Column(
        crossAxisAlignment: attributes['crossAxisAlignment'] == 'stretch'
            ? CrossAxisAlignment.stretch
            : (attributes['crossAxisAlignment'] == 'center' ? CrossAxisAlignment.center : CrossAxisAlignment.start),
        children: builder.buildChildren(node), // 迴圈走訪 children
      ),
    );
  }
}

class RowParser extends WidgetParser {
  @override
  String get widgetType => 'Row';

  @override
  Widget build(Map<String, dynamic> attributes, Map<String, dynamic>? node, DynamicUiBuilder builder) {
    return Row(
      crossAxisAlignment: attributes['crossAxisAlignment'] == 'center'
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: builder.buildChildren(node), // 迴圈走訪 children
    );
  }
}

class WrapParser extends WidgetParser {
  @override
  String get widgetType => 'Wrap';

  @override
  Widget build(Map<String, dynamic> attributes, Map<String, dynamic>? node, DynamicUiBuilder builder) {
    return Wrap(
      alignment: attributes['alignment'] == 'center' ? WrapAlignment.center : WrapAlignment.start,
      spacing: builder.parseSpace(attributes['spacing'], defaultVal: 8.0),
      runSpacing: builder.parseSpace(attributes['runSpacing'], defaultVal: 8.0),
      children: builder.buildChildren(node), // 迴圈走訪 children
    );
  }
}

class SizedBoxParser extends WidgetParser {
  @override
  String get widgetType => 'SizedBox';

  @override
  Widget build(Map<String, dynamic> attributes, Map<String, dynamic>? node, DynamicUiBuilder builder) {
    return SizedBox(height: builder.parseSpace(attributes['height']), width: builder.parseSpace(attributes['width']));
  }
}

class ContainerParser extends WidgetParser {
  @override
  String get widgetType => 'Container';

  @override
  Widget build(Map<String, dynamic> attributes, Map<String, dynamic>? node, DynamicUiBuilder builder) {
    return Container(
      width: (attributes['width'] as num?)?.toDouble(),
      height: (attributes['height'] as num?)?.toDouble(),
      padding: builder.parsePadding(attributes['padding']),
      margin: builder.parsePadding(attributes['margin']),
      decoration: BoxDecoration(
        color: builder.parseColor(attributes['color']),
        borderRadius: BorderRadius.circular(builder.parseRadius(attributes['borderRadius'])),
        border: attributes['borderColor'] != null
            ? Border.all(color: builder.parseColor(attributes['borderColor']))
            : null,
      ),
      child: builder.buildNode(node?['child']),
    );
  }
}

class ExpandedParser extends WidgetParser {
  @override
  String get widgetType => 'Expanded';

  @override
  Widget build(Map<String, dynamic> attributes, Map<String, dynamic>? node, DynamicUiBuilder builder) {
    return Expanded(flex: attributes['flex'] as int? ?? 1, child: builder.buildNode(node?['child']));
  }
}

class HeaderCardParser extends WidgetParser {
  @override
  String get widgetType => 'HeaderCard';

  @override
  Widget build(Map<String, dynamic> attributes, Map<String, dynamic>? node, DynamicUiBuilder builder) {
    return Container(
      padding: builder.parsePadding(attributes['padding']),
      decoration: BoxDecoration(
        color: builder.parseColor(attributes['background']),
        borderRadius: BorderRadius.circular(builder.parseRadius(attributes['borderRadius'])),
      ),
      child: Row(
        children: [
          if (attributes['logoUrl'] != null) ...[
            Image.network(
              attributes['logoUrl'],
              width: 36,
              height: 36,
              errorBuilder: (_, _, _) => const Icon(Icons.apps),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              attributes['title'] ?? '',
              style: builder.parseTextStyle(attributes['titleStyle'], attributes['titleColor']),
            ),
          ),
        ],
      ),
    );
  }
}

class CardParser extends WidgetParser {
  @override
  String get widgetType => 'Card';

  @override
  Widget build(Map<String, dynamic> attributes, Map<String, dynamic>? node, DynamicUiBuilder builder) {
    final bgColor = builder.parseColor(attributes['color']);
    final borderColor = builder.parseColor(attributes['borderColor']);
    final double borderWidth = (attributes['borderWidth'] as num?)?.toDouble() ?? 1.0;
    final double radius = builder.parseRadius(attributes['borderRadius']);

    return Material(
      color: bgColor,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(color: borderColor, width: borderWidth),
      ),
      child: Padding(
        padding: builder.parsePadding(attributes['padding']),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (attributes['title'] != null) ...[
              Text(
                attributes['title'],
                textAlign: attributes['titleAlignment'] == 'center' ? TextAlign.center : TextAlign.start,
                style: builder.parseTextStyle(attributes['titleStyle'], attributes['titleColor']),
              ),
              const SizedBox(height: 8),
            ],
            if (node != null && node['child'] != null) builder.buildNode(node['child']),
          ],
        ),
      ),
    );
  }
}

class ListTileParser extends WidgetParser {
  @override
  String get widgetType => 'ListTile';

  @override
  Widget build(Map<String, dynamic> attributes, Map<String, dynamic>? node, DynamicUiBuilder builder) {
    return ListTile(
      contentPadding: builder.parsePadding(attributes['padding']),
      leading: attributes['leadingIcon'] != null
          ? Text(attributes['leadingIcon'], style: const TextStyle(fontSize: 18))
          : null,
      title: Text(
        attributes['title'] ?? '',
        style: builder.parseTextStyle(attributes['titleStyle'], attributes['titleColor']),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (attributes['trailingText'] != null)
            Text(
              attributes['trailingText'],
              style: builder.parseTextStyle(attributes['trailingStyle'], attributes['trailingColor']),
            ),
          if (attributes['actionIcon'] == 'copy') ...[
            const SizedBox(width: 4),
            const Icon(Icons.copy, size: 14, color: Colors.grey),
          ],
        ],
      ),
      onTap: () {
        if (attributes['copyData'] != null) {
          Clipboard.setData(ClipboardData(text: attributes['copyData']));
          ScaffoldMessenger.of(builder.context).showSnackBar(const SnackBar(content: Text('Copyed to clipboard!')));
        } else if (attributes['linkUrl'] != null) {
          launchUrl(Uri.parse(attributes['linkUrl']), mode: LaunchMode.externalApplication);
        }
      },
    );
  }
}

class DividerParser extends WidgetParser {
  @override
  String get widgetType => 'Divider';

  @override
  Widget build(Map<String, dynamic> attributes, Map<String, dynamic>? node, DynamicUiBuilder builder) {
    return Divider(color: builder.parseColor(attributes['color']), height: 1);
  }
}

class ImageParser extends WidgetParser {
  @override
  String get widgetType => 'Image';

  @override
  Widget build(Map<String, dynamic> attributes, Map<String, dynamic>? node, DynamicUiBuilder builder) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(builder.parseRadius(attributes['borderRadius'])),
      child: Image.network(
        attributes['src'] ?? '',
        width: (attributes['width'] as num?)?.toDouble(),
        height: (attributes['height'] as num?)?.toDouble(),
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => const Icon(Icons.broken_image, size: 40),
      ),
    );
  }
}

class TextParser extends WidgetParser {
  @override
  String get widgetType => 'Text';

  @override
  Widget build(Map<String, dynamic> attributes, Map<String, dynamic>? node, DynamicUiBuilder builder) {
    return Text(
      attributes['text'] ?? '',
      textAlign: attributes['textAlign'] == 'center' ? TextAlign.center : TextAlign.start,
      style: builder.parseTextStyle(attributes['style'], attributes['color']),
    );
  }
}

class RichTextParser extends WidgetParser {
  @override
  String get widgetType => 'RichText';

  @override
  Widget build(Map<String, dynamic> attributes, Map<String, dynamic>? node, DynamicUiBuilder builder) {
    final spans = (attributes['spans'] as List? ?? []).map((s) {
      final sAttr = (s as Map<String, dynamic>)['attributes'] ?? {};
      return TextSpan(text: sAttr['text'] ?? '', style: builder.parseTextStyle(sAttr['style'], sAttr['color']));
    }).toList();

    return Text.rich(
      TextSpan(children: spans),
      textAlign: attributes['textAlign'] == 'center' ? TextAlign.center : TextAlign.start,
    );
  }
}

class TagParser extends WidgetParser {
  @override
  String get widgetType => 'Tag';

  @override
  Widget build(Map<String, dynamic> attributes, Map<String, dynamic>? node, DynamicUiBuilder builder) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: builder.parseColor(attributes['color']).withAlpha(150),
        borderRadius: BorderRadius.circular(builder.parseRadius(attributes['borderRadius'] ?? 'res.radius_1')),
      ),
      child: Text(attributes['text'] ?? '', style: builder.parseTextStyle(attributes['style'], attributes['color'])),
    );
  }
}

class FeatureItemParser extends WidgetParser {
  @override
  String get widgetType => 'FeatureItem';

  @override
  Widget build(Map<String, dynamic> attributes, Map<String, dynamic>? node, DynamicUiBuilder builder) {
    // 1. 解析背景與文字顏色
    final tagBgColor = builder.parseColor(attributes['tagColor']);

    // 如果有指定 tagTextColor 就用，否則預設使用白色 (或從 parseColor 解析)
    final tagTextColor = attributes['tagTextColor'] != null
        ? builder.parseColor(attributes['tagTextColor'])
        : Colors.white;

    final contentTextColor = builder.parseColor(attributes['contentColor']);

    // 2. 解析 TextStyle 並明確 overlay 顏色 (copyWith)
    final tagTextStyle = builder
        .parseTextStyle(attributes['tagStyle'], attributes['tagColor'])
        .copyWith(color: tagTextColor);

    final contentTextStyle = builder
        .parseTextStyle(attributes['contentStyle'], attributes['contentColor'])
        .copyWith(color: contentTextColor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: tagBgColor.withAlpha(150), borderRadius: BorderRadius.circular(4)),
          child: Text(attributes['tag'] ?? '', style: tagTextStyle),
        ),
        SizedBox(height: res.space_2),
        Text(attributes['content'] ?? '', style: contentTextStyle),
      ],
    );
  }
}

class ButtonParser extends WidgetParser {
  @override
  String get widgetType => 'Button';

  @override
  Widget build(Map<String, dynamic> attributes, Map<String, dynamic>? node, DynamicUiBuilder builder) {
    final action = attributes['action'] as String?;
    final param = attributes['actionParam'] as String?;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: builder.parseColor(attributes['backgroundColor'])),
      onPressed: () {
        if (action == 'openUrl' && param != null) {
          launchUrl(Uri.parse(param), mode: LaunchMode.externalApplication);
        } else if (action == 'copy' && param != null) {
          Clipboard.setData(ClipboardData(text: param));
          ScaffoldMessenger.of(builder.context).showSnackBar(const SnackBar(content: Text('已複製！')));
        }
      },
      child: builder.buildNode(node?['child']),
    );
  }
}
