import 'package:flutter/material.dart';
import 'package:tap_on_scroll/tap_on_scroll.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'tap_on_scroll Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;
  int _tappedIndex = -1;

  // Keep track of pinned header taps
  int _pinnedHeaderTaps = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('tap_on_scroll Demo'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'List Example'),
            Tab(text: 'Grid Example'),
            Tab(text: 'Pinned Header'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildListExample(),
          _buildGridExample(),
          _buildPinnedHeaderExample(),
        ],
      ),
    );
  }

  Widget _buildListExample() {
    return TapInterceptor(
      child: ListView.builder(
        controller: _scrollController,
        itemCount: 50,
        itemBuilder: (context, index) {
          return TappableArea(
            onTap: () => _handleItemTap(index),
            child: ListTile(
              title: Text('List Item $index'),
              subtitle: Text('Tap me while scrolling!'),
              trailing: Icon(
                _tappedIndex == index
                    ? Icons.check_circle
                    : Icons.circle_outlined,
                color: _tappedIndex == index ? Colors.green : Colors.grey,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGridExample() {
    final ScrollController gridScrollController = ScrollController();

    return TapInterceptor(
      child: GridView.builder(
        controller: gridScrollController,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.5,
        ),
        padding: const EdgeInsets.all(16),
        itemCount: 40,
        itemBuilder: (context, index) {
          return TappableArea(
            onTap: () => _handleItemTap(index),
            child: Card(
              elevation: 3,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color:
                      _tappedIndex == index
                          ? Colors.blue.withOpacity(0.2)
                          : Colors.white,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Grid Item $index',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap while scrolling!',
                      style: TextStyle(color: Colors.grey[700], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // New method for the pinned header example
  Widget _buildPinnedHeaderExample() {
    final ScrollController pinnedController = ScrollController();

    return TapInterceptor(
      child: CustomScrollView(
        controller: pinnedController,
        slivers: [
          // Pinned SliverAppBar with TappableArea
          SliverAppBar(
            pinned: true,
            expandedHeight: 150.0,
            flexibleSpace: FlexibleSpaceBar(
              title: TappableArea(
                onTap: _handlePinnedHeaderTap,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Pinned Header'),
                    const SizedBox(width: 8),
                    if (_pinnedHeaderTaps > 0)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$_pinnedHeaderTaps',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              background: Image.network(
                'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg',
                fit: BoxFit.cover,
              ),
            ),
            // CRUCIAL USE CASE: Action buttons that remain tappable during scroll
            actions: [
              TappableArea(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Search button tapped during scroll!'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed:
                      () {}, // Native onPressed may not work reliably during scroll
                ),
              ),
              TappableArea(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Favorite button tapped during scroll!'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: IconButton(
                  icon: const Icon(Icons.favorite),
                  onPressed:
                      () {}, // Native onPressed may not work reliably during scroll
                ),
              ),
              TappableArea(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Menu button tapped during scroll!'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed:
                      () {}, // Native onPressed may not work reliably during scroll
                ),
              ),
            ],
          ),

          // Section header
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverHeaderDelegate(
              minHeight: 60,
              maxHeight: 60,
              child: TappableArea(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Tapped on section header while scrolling!',
                      ),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: Container(
                  color: Colors.teal,
                  child: const Center(
                    child: Text(
                      'Section Header (Tappable while scrolling)',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // List of items
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return TappableArea(
                onTap: () => _handleItemTap(index),
                child: ListTile(
                  title: Text('Sliver Item $index'),
                  subtitle: const Text(
                    'Try tapping the pinned headers while scrolling!',
                  ),
                  trailing: Icon(
                    _tappedIndex == index
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    color: _tappedIndex == index ? Colors.green : Colors.grey,
                  ),
                ),
              );
            }, childCount: 50),
          ),
        ],
      ),
    );
  }

  void _handleItemTap(int index) {
    setState(() {
      _tappedIndex = index;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Item $index tapped successfully!'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _handlePinnedHeaderTap() {
    setState(() {
      _pinnedHeaderTaps++;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pinned header tapped $_pinnedHeaderTaps times!'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

// Custom delegate for the pinned section header
class _SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  _SliverHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
