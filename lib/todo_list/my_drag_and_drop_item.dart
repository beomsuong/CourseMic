import 'package:drag_and_drop_lists/drag_and_drop_interface.dart';
import 'package:flutter/widgets.dart';

import 'package:capston/todo_list/todo_node.dart';
import 'package:capston/todo_list/todo.dart';

class DragAndDropItem extends StatefulWidget implements DragAndDropInterface {
  /// The child widget of this item.
  final Widget child;

  /// Widget when draggable
  final Widget? feedbackWidget;

  /// Whether or not this item can be dragged.
  /// Set to true if it can be reordered.
  /// Set to false if it must remain fixed.
  final bool canDrag;

  bool bDelete;
  String? task;
  ToDo? toDo;
  void Function()? onTapButton;

  DragAndDropItem({
    super.key,
    required this.child,
    this.feedbackWidget,
    this.canDrag = true,
    this.bDelete = true,
    this.task,
    this.toDo,
    this.onTapButton,
  });

  @override
  State<DragAndDropItem> createState() => _DragAndDropItemState();
}

class _DragAndDropItemState extends State<DragAndDropItem> {
  @override
  Widget build(BuildContext context) {
    return ToDoNode(
      task: widget.task,
      toDo: widget.toDo,
      onTapButton: widget.onTapButton,
    );
  }
}
