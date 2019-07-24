import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

//图文混编测试demo
class TextWithWidgetDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: "你好",
        children: [
          WidgetSpan(child: Icon(Icons.ac_unit)),
          WidgetSpan(child: FlatButton(onPressed: (){}, child: Text("点我"))),
          TextSpan(text: "这是什么啦啦啦"),
          TextSpan(
            text: "层级复杂的",
            children: [
              TextSpan(
                text: "点我",
                style: TextStyle(color: Colors.red, fontSize: 16),
                recognizer: TapGestureRecognizer()..onTap = (){
                  print("点击事件");
                }
              )
            ],
          ),
        ],
        style: Theme.of(context).textTheme.display1,
      ),
    );
  }
}

//图文混编排版测试
class LayoutDemo extends MultiChildRenderObjectWidget{
  LayoutDemo({
    Key key,
    List<Widget> children,
  }): super(key: key , children: children);

  @override
  RenderLayout createRenderObject(BuildContext context) {
    return RenderLayout();
  }
}

class PageParentData extends ContainerBoxParentData<RenderBox> {}

class RenderLayout extends RenderBox with ContainerRenderObjectMixin<RenderBox, PageParentData>,RenderBoxContainerDefaultsMixin<RenderBox, PageParentData>{
  double textWidth = 100;
  double textFontSize = 12.0;
  ui.Paragraph paragraph;
  List<TextBox> _inlinePlaceholderBoxes;

  RenderLayout({List<RenderBox> children}){
    ui.ParagraphBuilder paragraphBuilder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        textAlign: TextAlign.start,
        fontSize: textFontSize,
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: "...", //超出用...代替
      ),
    )
      ..pushStyle(
        ui.TextStyle(
            color: Colors.black87, textBaseline: ui.TextBaseline.alphabetic),
      )
      ..addText("前面部分")
      ..addPlaceholder(50, 50, ui.PlaceholderAlignment.middle)
      ..addText("中间部分")
      ..addPlaceholder(50, 20, ui.PlaceholderAlignment.bottom)
      ..addText("尾巴");

    paragraph = paragraphBuilder.build()
      ..layout(ui.ParagraphConstraints(width: 300));

    //获得空白占位的盒子位置列表，即addPlaceholder部分(源码中使用的是textPainter.layout ，内部会调用这个)
    _inlinePlaceholderBoxes = paragraph.getBoxesForPlaceholders();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! PageParentData)
      child.parentData = PageParentData();
  }


  @override
  void performLayout() {
    size = Size(300,300);
    double widthOffset = 0.0;
    double heightOffset = 0.0;
    RenderBox child = firstChild;
    int index = 0;
    while(child != null){
      print("index = $index    ${_inlinePlaceholderBoxes[index].left}");
      widthOffset = _inlinePlaceholderBoxes[index].left;
      heightOffset = _inlinePlaceholderBoxes[index].top;
      final PageParentData childParentData = child.parentData;
      child.layout(constraints.heightConstraints(), parentUsesSize: true);
      childParentData.offset = Offset(widthOffset, heightOffset);
      index++;
      child = childParentData.nextSibling;
    }
  }

  //当hitTestChildren返回false时就会调用该方法
  //hitTestSelf返回true代表自己能处理本事件，调用自己的handleEvent方法，否则不处理事件
  @override
  bool hitTestSelf(Offset position) => true;

  @override
  bool hitTestChildren(BoxHitTestResult result, { Offset position }) {
    RenderBox child = firstChild;
    while (child != null) {
      final PageParentData textParentData = child.parentData;
      //配套对应，将触摸反馈点也进行平移
      final Matrix4 transform = Matrix4.translationValues(textParentData.offset.dx, textParentData.offset.dy, 0.0)
        ..scale(1.0, 1.0, 1.0);
      final bool isHit = result.addWithPaintTransform(
        transform: transform,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          return child.hitTest(result, position: transformed);
        },
      );
      //如果点击事件发生在平移的widget控件上，则其自己处理事件，不调用自己的handleEvent
      if (isHit) {
        return true;
      }
      child = childAfter(child);
    }
    //默认情况下自己处理事件，调用自己的handleEvent
    return false;
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    if (event is! PointerDownEvent)
      return;
    //默认的文本处理方式，当textSpan中设置了recognizer，即捕获事件
    //找到对应位置的span，然后让其捕获事件，span?.recognizer?.addPointer(event);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    var canvas = context.canvas;
    double scale = 1.0;
    //绘制文字
    canvas.drawParagraph(paragraph, offset);

    RenderBox child = firstChild;
    while(child != null){
      final PageParentData childParentData = child.parentData;
      //位移控件，即将控件平移offset + childParentData.offset距离
      context.pushTransform(
        true,
        offset + childParentData.offset,
        Matrix4.diagonal3Values(scale, scale, scale),
            (PaintingContext context, Offset offset) {
          context.paintChild(
            child,
            offset,
          );
        },
      );
      child = childParentData.nextSibling;
    }
  }
}


//文字长度计算测试，textPainter
class TextPainterTestDemo extends StatelessWidget {
  final TextSpan text;

  @override
  Widget build(BuildContext context) {
    test(context);
    return Container();
  }

  test(BuildContext context){
    double width = context.size.width;
    TextPainter textPainter = TextPainter(text: text,textDirection: TextDirection.ltr);
    //一行排版最大为父类宽度，最小则为默认的0
    textPainter.layout(maxWidth: width);

    Offset offset = Offset(100, 10);
    final TextPosition position = textPainter.getPositionForOffset(offset);

    //获取占满这个区域的String的最后一个字符的index(第几个就返回几)
    // 例如"hello" , 如果区域划分o上，则返回5
    int end = position.offset;
    print("区域占位的字符是第$end个");

    //取的此点上的textSpan
    final TextSpan span = textPainter.text.getSpanForPosition(position);

    //获取占位区的坐标盒子,前提要将textPainter的builder设置addPlaceholder
    //TextBox box = textPainter.inlinePlaceholderBoxes[0];
  }

  TextPainterTestDemo(this.text);
}


