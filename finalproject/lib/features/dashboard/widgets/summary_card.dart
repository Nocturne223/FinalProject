import 'package:flutter/material.dart';
import '../../../helpers/responsive_typography_helper.dart';

class SummaryCard extends StatelessWidget {
  bool _isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1024;
  }

  final String title;
  final String value;
  final String percent;
  final Color color;
  final IconData icon;
  final String timeFilter;
  final Widget miniGraph;
  final ValueChanged<String?>? onTimeFilterChanged;
  final List<String>? timeFilterOptions;

  const SummaryCard({
    Key? key,
    required this.title,
    required this.value,
    required this.percent,
    required this.color,
    required this.icon,
    required this.timeFilter,
    required this.miniGraph,
    this.onTimeFilterChanged,
    this.timeFilterOptions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobileView = screenWidth < 600;
    final isSmallMobile = screenWidth < 400;
    final isMediumMobile =
        screenWidth >= 400 &&
        screenWidth < 450; // Extended to cover 414px phones
    final isLargeMobile =
        screenWidth >= 450 &&
        screenWidth < 600; // New category for larger phones
    final isLandscape = screenHeight < screenWidth;

    // Check if this card has filter functionality
    final hasFilter =
        timeFilter.isNotEmpty &&
        onTimeFilterChanged != null &&
        timeFilterOptions != null;

    // Hide mini-graphs for cards with filters to prevent overflow
    final shouldShowMiniGraph = !hasFilter && !isMobileView;

    final titleFontSize = getResponsiveFontSize(
      context,
      mobile: isSmallMobile
          ? 13 // Smaller for very small phones
          : isMediumMobile
          ? 14 // Smaller for 414px phones to prevent overflow
          : isLargeMobile
          ? 15 // Medium for larger phones
          : 16,
      tablet: 20,
      desktop: 24,
    );
    final valueFontSize = getResponsiveFontSize(
      context,
      mobile: isSmallMobile
          ? 15 // Smaller for very small phones
          : isMediumMobile
          ? 16 // Smaller for 414px phones to prevent overflow
          : isLargeMobile
          ? 18 // Medium for larger phones
          : 22,
      tablet: 28,
      desktop: 36,
    );
    final percentFontSize = getResponsiveFontSize(
      context,
      mobile: isSmallMobile
          ? 9 // Smaller for very small phones
          : isMediumMobile
          ? 10 // Smaller for 414px phones to prevent overflow
          : isLargeMobile
          ? 11 // Medium for larger phones
          : 12,
      tablet: 14,
      desktop: 18,
    );
    final dropdownFontSize = getResponsiveFontSize(
      context,
      mobile: isSmallMobile
          ? 9 // Smaller for very small phones
          : isMediumMobile
          ? 10 // Smaller for 414px phones to prevent overflow
          : isLargeMobile
          ? 11 // Medium for larger phones
          : 12,
      tablet: 12,
      desktop: 16,
    );

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.surfaceVariant,
          width: 1,
        ),
      ),
      margin: EdgeInsets.all(
        isSmallMobile
            ? 8
            : isMediumMobile
            ? 12
            : isLargeMobile
            ? 14
            : 16,
      ),
      child: Container(
        constraints: BoxConstraints(
          minWidth: isSmallMobile
              ? 120
              : isMediumMobile
              ? 150
              : isLargeMobile
              ? 170
              : 180,
          maxWidth: isSmallMobile
              ? 220
              : isMediumMobile
              ? 260
              : isLargeMobile
              ? 300
              : 320,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isSmallMobile
              ? 12
              : isMediumMobile
              ? 18
              : isLargeMobile
              ? 20
              : 24,
          vertical: isLandscape
              ? (isSmallMobile
                    ? 8
                    : isMediumMobile
                    ? 10
                    : isLargeMobile
                    ? 12
                    : 16) // Reduce vertical padding in landscape
              : (isSmallMobile
                    ? 12
                    : isMediumMobile
                    ? 16
                    : isLargeMobile
                    ? 18
                    : 24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                        maxLines: 2, // Allow 2 lines for longer titles
                      ),
                      SizedBox(
                        height: isLandscape
                            ? (isSmallMobile
                                  ? 6
                                  : isMediumMobile
                                  ? 7
                                  : isLargeMobile
                                  ? 8
                                  : 8)
                            : (isSmallMobile
                                  ? 8
                                  : isMediumMobile
                                  ? 10
                                  : isLargeMobile
                                  ? 12
                                  : 8),
                      ),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: valueFontSize,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 2, // Allow 2 lines for longer values
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.all(
                        isSmallMobile
                            ? 4
                            : isMediumMobile
                            ? 5
                            : isLargeMobile
                            ? 6
                            : 6,
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: isSmallMobile
                            ? 16 // Smaller for very small phones
                            : isMediumMobile
                            ? 18 // Smaller for 414px phones to prevent overflow
                            : isLargeMobile
                            ? 20 // Medium for larger phones
                            : 24,
                      ),
                    ),
                    if (hasFilter)
                      Padding(
                        padding: EdgeInsets.only(
                          top: isLandscape
                              ? (isSmallMobile
                                    ? 6.0
                                    : isMediumMobile
                                    ? 7.0
                                    : isLargeMobile
                                    ? 8.0
                                    : 8.0)
                              : (isSmallMobile
                                    ? 8.0
                                    : isMediumMobile
                                    ? 10.0
                                    : isLargeMobile
                                    ? 12.0
                                    : 8.0),
                        ),
                        child: (isMobileView || _isTablet(context))
                            ? PopupMenuButton<String>(
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  size: isSmallMobile
                                      ? 16 // Smaller for very small phones
                                      : isMediumMobile
                                      ? 18 // Smaller for 414px phones to prevent overflow
                                      : isLargeMobile
                                      ? 20 // Medium for larger phones
                                      : (_isTablet(context) ? 22 : 24),
                                  color: color,
                                ),
                                onSelected: onTimeFilterChanged,
                                itemBuilder: (context) => timeFilterOptions!
                                    .map(
                                      (filter) => PopupMenuItem<String>(
                                        value: filter,
                                        child: Text(
                                          filter,
                                          style: TextStyle(
                                            fontSize: dropdownFontSize,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              )
                            : SizedBox.shrink(),
                      ),
                  ],
                ),
              ],
            ),
            // Only show mini-graph if no filter and not mobile
            if (shouldShowMiniGraph) ...[
              SizedBox(
                height: isLandscape
                    ? (isSmallMobile
                          ? 8
                          : isMediumMobile
                          ? 9
                          : isLargeMobile
                          ? 10
                          : 12)
                    : (isSmallMobile
                          ? 12
                          : isMediumMobile
                          ? 14
                          : isLargeMobile
                          ? 16
                          : 16),
              ),
              miniGraph,
              SizedBox(
                height: isLandscape
                    ? (isSmallMobile
                          ? 12
                          : isMediumMobile
                          ? 14
                          : isLargeMobile
                          ? 16
                          : 16)
                    : (isSmallMobile
                          ? 16
                          : isMediumMobile
                          ? 18
                          : isLargeMobile
                          ? 20
                          : 16),
              ),
            ],
            // Show trend and filter dropdown in bottom row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Trend indicator
                if (percent.isNotEmpty)
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.trending_up,
                          color: color,
                          size: isSmallMobile
                              ? 16 // Smaller for very small phones
                              : isMediumMobile
                              ? 17 // Smaller for 414px phones to prevent overflow
                              : isLargeMobile
                              ? 18 // Medium for larger phones
                              : 18,
                        ),
                        SizedBox(
                          width: isLandscape
                              ? (isSmallMobile
                                    ? 4
                                    : isMediumMobile
                                    ? 5
                                    : isLargeMobile
                                    ? 6
                                    : 6)
                              : (isSmallMobile
                                    ? 6
                                    : isMediumMobile
                                    ? 7
                                    : isLargeMobile
                                    ? 8
                                    : 6),
                        ),
                        Flexible(
                          child: Text(
                            percent,
                            style: TextStyle(
                              fontSize: percentFontSize,
                              color: color,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (hasFilter && !(isMobileView || _isTablet(context)))
                  // If no percent but has filter, add spacer to push dropdown to right
                  const Spacer(),
                // Filter dropdown for desktop/tablet (when not mobile)
                if (hasFilter && !(isMobileView || _isTablet(context)))
                  Container(
                    constraints: BoxConstraints(maxWidth: 140),
                    child: DropdownButton<String>(
                      value: timeFilter,
                      items: timeFilterOptions!
                          .map(
                            (filter) => DropdownMenuItem(
                              value: filter,
                              child: Text(
                                filter,
                                style: TextStyle(fontSize: dropdownFontSize),
                                overflow: filter.length > 20
                                    ? TextOverflow.ellipsis
                                    : null,
                                maxLines: filter.length > 20 ? 1 : null,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: onTimeFilterChanged,
                      underline: const SizedBox(),
                      style: TextStyle(fontSize: dropdownFontSize),
                      isDense: true,
                      iconSize: 24,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MiniGraphPainter extends CustomPainter {
  final Color color;
  final List<double> points;
  MiniGraphPainter({required this.color, required this.points});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path();
    // Example: Draw a simple line graph (customize as needed)
    if (points.isNotEmpty) {
      final dx = size.width / (points.length - 1);
      path.moveTo(0, size.height - points[0] * size.height);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(i * dx, size.height - points[i] * size.height);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
