import 'package:flutter/material.dart';

List<Color> colors = [
  Colors.white,
  const Color(0xffF28B83),
  const Color(0xFFFCBC05),
  const Color(0xFFFFF476),
  const Color(0xFFCBFF90),
  const Color(0xFFA7FEEA),
  const Color(0xFFE6C9A9),
  const Color(0xFFE8EAEE),
  const Color(0xFFBBDEFB),
  const Color(0xFFD7AEFB),
];

class PriorityPicker extends StatefulWidget {
  final Function(int) onTap;
  final int selectedIndex;
  const PriorityPicker(
      {Key? key, required this.onTap, required this.selectedIndex})
      : super(key: key);
  @override
  State<PriorityPicker> createState() => _PriorityPickerState();
}

class _PriorityPickerState extends State<PriorityPicker> {
  int? selectedIndex;
  List<String> priorityText = ['Thấp', 'Vừa', 'Cao'];
  List<Color> priorityColor = [Colors.green, Colors.orange, Colors.red];

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (BuildContext context, int index) {
          final isSelected = selectedIndex == index;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            width: (width - 64) / 3,
            child: Material(
              color: isSelected
                  ? priorityColor[index].withOpacity(0.2)
                  : Theme.of(context).colorScheme.surface.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  if (!mounted) return;

                  setState(() {
                    selectedIndex = index;
                  });
                  widget.onTap(index);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      width: 2,
                      color: isSelected
                          ? priorityColor[index]
                          : Colors.transparent,
                    ),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: priorityColor[index],
                            size: 18,
                          ),
                        if (isSelected) const SizedBox(width: 4),
                        Text(
                          priorityText[index],
                          style: TextStyle(
                            color: isSelected
                                ? priorityColor[index]
                                : Theme.of(context).colorScheme.onSurface,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ColorPicker extends StatefulWidget {
  final Function(int) onTap;
  final int selectedIndex;
  const ColorPicker(
      {Key? key, required this.onTap, required this.selectedIndex})
      : super(key: key);
  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  int? selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          mainAxisSpacing: 8,
          mainAxisExtent: 50,
        ),
        itemCount: colors.length,
        itemBuilder: (BuildContext context, int index) {
          final isSelected = selectedIndex == index;
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final color =
              index == 0 && isDark ? Colors.grey[800]! : colors[index];

          return InkWell(
            onTap: () {
              if (!mounted) return;

              setState(() {
                selectedIndex = index;
              });
              widget.onTap(index);
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  width: 2,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.black.withOpacity(0.2),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Theme.of(context).shadowColor.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: isSelected
                  ? Center(
                      child: Icon(
                        Icons.check,
                        color: index == 0
                            ? Theme.of(context).colorScheme.primary
                            : Colors.black,
                      ),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}

// Helper function to get priority color - tái sử dụng trong nhiều file
Color getPriorityColor(int priority) {
  switch (priority) {
    case 1:
      return Colors.red;
    case 2:
      return Colors.orange;
    case 3:
      return Colors.green;
    default:
      return Colors.green;
  }
}

// Helper function to get priority text - tái sử dụng trong nhiều file
String getPriorityText(int priority) {
  switch (priority) {
    case 1:
      return 'Cao';
    case 2:
      return 'Vừa';
    case 3:
      return 'Thấp';
    default:
      return 'Thấp';
  }
}
