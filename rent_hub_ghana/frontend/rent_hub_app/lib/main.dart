import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/theme_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/onboarding/role_select_screen.dart';
import 'screens/properties/property_details_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/profile/safety_centre_screen.dart';
import 'screens/profile/help_support_screen.dart';
import 'screens/profile/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeService.init();
  runApp(const RentHubApp());
}

class RentHubApp extends StatelessWidget {
  const RentHubApp({super.key});
  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF7C4DFF);
    const ash = Color(0xFFB7B7B7);
    const darkSurface = Color(0xFF101318);
    const darkCard = Color(0xFF1A1F2E);

    final lightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Arial',
      scaffoldBackgroundColor: ash,
      canvasColor: ash,
      cardColor: const Color(0xFFE7E7E7),
      dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
      colorScheme: ColorScheme.fromSeed(
        seedColor: purple,
        brightness: Brightness.light,
      ).copyWith(
        primary: purple,
        secondary: const Color(0xFF9D7BFF),
        surface: ash,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: ash,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFFE7E7E7),
        indicatorColor: const Color(0xFF332E52),
        surfaceTintColor: purple,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFE7E7E7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );

    final darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Arial',
      scaffoldBackgroundColor: darkSurface,
      canvasColor: darkSurface,
      cardColor: darkCard,
      dialogTheme: const DialogThemeData(backgroundColor: darkCard),
      colorScheme: ColorScheme.fromSeed(
        seedColor: purple,
        brightness: Brightness.dark,
      ).copyWith(
        primary: purple,
        secondary: const Color(0xFF9D7BFF),
        surface: darkSurface,
        surfaceContainerHighest: const Color(0xFF242B3D),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkCard,
        indicatorColor: const Color(0xFF332E52),
        surfaceTintColor: purple,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeModeNotifier,
      builder: (context, mode, _) => MaterialApp(
        title: 'Rent Hub Ghana',
        debugShowCheckedModeBanner: false,
        themeMode: mode,
        theme: lightTheme,
        darkTheme: darkTheme,
        home: const RoleSelectScreen(),
      ),
    );
  }
}

class Property {
  const Property({
    this.id,
    required this.title,
    required this.area,
    required this.price,
    required this.type,
    required this.image,
    required this.tag,
    required this.beds,
    required this.baths,
    this.furnished = false,
    this.ownerPhone = '',
    this.isAvailable = true,
  });
  final int? id;
  final String title, area, price, type, image, tag;
  final int beds, baths;
  final bool furnished;
  final String ownerPhone;
  final bool isAvailable;

  factory Property.fromJson(Map<String, dynamic> json) => Property(
    id: json['id'] as int?,
    title: json['title'] as String? ?? 'Untitled home',
    area: '${json['area'] ?? ''}, ${json['city'] ?? ''}',
    price: 'GH₵ ${json['price'] ?? '0'}',
    type: json['property_type'] as String? ?? 'Home',
    image: json['image_url'] as String? ?? '',
    tag: (json['is_available'] == false) ? 'Unavailable' : (json['is_verified'] == true ? 'Verified' : 'Available'),
    beds: json['bedrooms'] as int? ?? 1,
    baths: json['bathrooms'] as int? ?? 1,
    furnished: json['furnished'] as bool? ?? false,
    ownerPhone: (json['owner_phone'] ?? '').toString().trim(),
    isAvailable: (json['is_available'] as bool?) ?? true,
  );

  Property copyWith({bool? isAvailable, String? tag}) => Property(
    id: id,
    title: title,
    area: area,
    price: price,
    type: type,
    image: image,
    tag: tag ?? this.tag,
    beds: beds,
    baths: baths,
    furnished: furnished,
    ownerPhone: ownerPhone,
    isAvailable: isAvailable ?? this.isAvailable,
  );
}

class Shell extends StatefulWidget {
  const Shell({super.key, this.token});
  final String? token;
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int tab = 0;
  final favorites = <int>{};
  String query = '';

  @override
  void initState() {
    super.initState();
    _syncFavorites();
  }

  Future<void> _syncFavorites() async {
    if (widget.token == null) {
      if (mounted) {
        setState(() => favorites.clear());
      }
      return;
    }

    try {
      final items = await ApiService(token: widget.token).fetchFavorites();
      if (!mounted) return;
      setState(() {
        favorites
          ..clear()
          ..addAll(
            items.map((item) {
              final listing = item['listing'] as int?;
              if (listing != null) return listing;
              final detail = item['listing_detail'] as Map<String, dynamic>?;
              return (detail?['id'] as int?) ?? -1;
            }).where((id) => id > 0),
          );
      });
    } catch (_) {
      if (mounted) {
        setState(() => favorites.clear());
      }
    }
  }

  Future<void> toggleFavorite(int listingId) async {
    if (widget.token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign in to save homes.')),
        );
      }
      return;
    }

    final service = ApiService(token: widget.token);
    final isSaved = favorites.contains(listingId);

    try {
      if (isSaved) {
        final savedItems = await service.fetchFavorites();
        final favoriteMatch = savedItems.firstWhere(
          (item) =>
              (item['listing'] as int?) == listingId ||
              (item['listing_detail'] as Map<String, dynamic>?)?['id'] == listingId,
          orElse: () => <String, dynamic>{},
        );

        final favoriteId = favoriteMatch['id'] as int?;
        if (favoriteId != null) {
          await service.removeFavorite(favoriteId);
        }
      } else {
        await service.saveFavorite(listingId);
      }

      await _syncFavorites();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(
        token: widget.token,
        query: query,
        onQuery: (value) => setState(() => query = value),
        favorites: favorites,
        onFavorite: toggleFavorite,
      ),
      FavoritesPage(
        token: widget.token,
        favorites: favorites,
        onFavorite: toggleFavorite,
      ),
      ProfilePage(token: widget.token),
    ];
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: tab, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (index) => setState(() => tab = index),
        backgroundColor: Theme.of(context).colorScheme.surface,
        indicatorColor: const Color(0xFF2B2347),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.token,
    required this.query,
    required this.onQuery,
    required this.favorites,
    required this.onFavorite,
  });
  final String? token;
  final String query;
  final ValueChanged<String> onQuery;
  final Set<int> favorites;
  final ValueChanged<int> onFavorite;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? propertyType;
  int? bedrooms;
  double? maxPrice;

  Future<void> openFilters() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      builder: (_) => FilterSheet(
        propertyType: propertyType,
        bedrooms: bedrooms,
        maxPrice: maxPrice,
      ),
    );
    if (result != null) {
      setState(() {
        propertyType = result['propertyType'] as String?;
        bedrooms = result['bedrooms'] as int?;
        maxPrice = result['maxPrice'] as double?;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Property>>(
      future: ApiService(token: widget.token).fetchListings(
        search: widget.query,
        propertyType: propertyType,
        bedrooms: bedrooms,
        maxPrice: maxPrice,
      ),
      builder: (context, snapshot) {
        final source = snapshot.data ?? <Property>[];
        final filtered = source
            .where(
              (p) => '${p.title} ${p.area} ${p.type}'.toLowerCase().contains(
                widget.query.toLowerCase(),
              ),
            )
            .toList();
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
              sliver: SliverToBoxAdapter(child: _Header()),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(22, 26, 22, 0),
              sliver: SliverToBoxAdapter(
                child: _Search(onQuery: widget.onQuery, onFilter: openFilters),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
              sliver: SliverToBoxAdapter(
                child: _FilterRow(onFilter: openFilters),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(22, 28, 22, 14),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Homes you may like',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${filtered.length} results',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, i) {
                  final original = filtered[i].id ?? i;
                  return PropertyCard(
                    property: filtered[i],
                    isFavorite: widget.favorites.contains(original),
                    onFavorite: () => widget.onFavorite(original),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PropertyDetailsScreen(
                          property: filtered[i],
                          isFavorite: widget.favorites.contains(original),
                          onFavorite: () => widget.onFavorite(original),
                          token: authService.token,
                        ),
                      ),
                    ),
                  );
                }, childCount: filtered.length),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 18)),
          ],
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good morning, ${authService.user?.displayName ?? 'there'}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Find your next home',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ],
      ),
      CircleAvatar(
        backgroundColor: const Color(0xFF2A2347),
        child: Text(
          authService.user?.displayName.isNotEmpty == true
              ? authService.user!.displayName.substring(0, 1).toUpperCase()
              : '?',
          style: const TextStyle(
            color: Color(0xFFBDA8FF),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  );
}

class _Search extends StatelessWidget {
  const _Search({required this.onQuery, required this.onFilter});
  final ValueChanged<String> onQuery;
  final VoidCallback onFilter;
  @override
  Widget build(BuildContext context) => TextField(
    onChanged: onQuery,
    decoration: InputDecoration(
      hintText: 'Search by area, city or landmark',
      prefixIcon: const Icon(Icons.search),
      suffixIcon: IconButton(onPressed: onFilter, icon: const Icon(Icons.tune)),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
    ),
  );
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.onFilter});
  final VoidCallback onFilter;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: ['Accra', 'Any price', 'Property type', '2+ beds'].map((
          label,
        ) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(label),
              avatar: Icon(
                label == 'Accra'
                    ? Icons.location_on_outlined
                    : Icons.keyboard_arrow_down,
                size: 17,
              ),
              onPressed: onFilter,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class PropertyCard extends StatelessWidget {
  const PropertyCard({
    super.key,
    required this.property,
    required this.isFavorite,
    required this.onFavorite,
    required this.onTap,
  });
  final Property property;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 18),
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.55,
                  child: Image.network(
                    property.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: const Color(0xFFEFE7FF),
                      child: const Icon(
                        Icons.home_work_outlined,
                        size: 56,
                        color: Color(0xFF5B3FD6),
                      ),
                    ),
                  ),
                ),
                Positioned(top: 12, left: 12, child: _Tag(property.tag)),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    onPressed: onFavorite,
                    style: IconButton.styleFrom(backgroundColor: Colors.white),
                    icon: Icon(
                      isFavorite ? Icons.bookmark : Icons.bookmark_border,
                      color: const Color(0xFF5B3FD6),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 13, 15, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    property.area,
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        property.price,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: Color(0xFF5B3FD6),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${property.beds} bed  •  ${property.baths} bath',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFF2A2143),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: Color(0xFFBDA8FF),
        fontWeight: FontWeight.bold,
        fontSize: 11,
      ),
    ),
  );
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({
    super.key,
    required this.token,
    required this.favorites,
    required this.onFavorite,
  });
  final String? token;
  final Set<int> favorites;
  final ValueChanged<int> onFavorite;
  @override
  Widget build(BuildContext context) {
    if (token == null) {
      return const Center(child: Text('Sign in to see your saved homes.'));
    }
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: ApiService(token: token).fetchFavorites(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Unable to load saved homes.'));
        }
        final saved = snapshot.data ?? [];
        if (saved.isEmpty) {
          return const Center(
            child: Text('Your saved homes will appear here.'),
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(22, 30, 22, 20),
          children: [
            Text(
              'Saved homes',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 18),
            ...saved.map((item) {
              final property = Property.fromJson(
                item['listing_detail'] as Map<String, dynamic>,
              );
              return PropertyCard(
                property: property,
                isFavorite: true,
                onFavorite: () => onFavorite(property.id ?? 0),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PropertyDetailsScreen(
                      property: property,
                      isFavorite: true,
                      onFavorite: () => onFavorite(property.id ?? 0),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

class DetailPage extends StatelessWidget {
  const DetailPage({
    super.key,
    required this.property,
    required this.isFavorite,
    required this.onFavorite,
  });
  final Property property;
  final bool isFavorite;
  final VoidCallback onFavorite;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home details'),
        actions: [
          IconButton(
            onPressed: onFavorite,
            icon: Icon(isFavorite ? Icons.bookmark : Icons.bookmark_border),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 30),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: AspectRatio(
              aspectRatio: 1.35,
              child: Image.network(property.image, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 22),
          _Tag(property.tag),
          const SizedBox(height: 14),
          Text(
            property.title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(property.area, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 22),
          Text(
            property.price,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF5B3FD6),
            ),
          ),
          const Text('per month', style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _Stat(Icons.bed_outlined, '${property.beds} Beds'),
              _Stat(Icons.bathtub_outlined, '${property.baths} Baths'),
              _Stat(
                Icons.chair_outlined,
                property.furnished ? 'Furnished' : 'Unfurnished',
              ),
            ],
          ),
          const SizedBox(height: 28),
          const Text(
            'About this home',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'A thoughtfully designed space in a well-connected neighbourhood. Enjoy bright rooms, quality finishes and the peace of a home that feels just right.',
            style: TextStyle(height: 1.5, color: Colors.black54),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: null,
              icon: Icon(Icons.chat_bubble_outline),
              label: Text('Contact agent'),
            ),
          ),
        ],
      ),
    );
  }

  /*
  @override
  Widget build(BuildContext context) => Scaffold(body: CustomScrollView(slivers: [SliverAppBar(expandedHeight: 330, pinned: true, backgroundColor: Colors.white, foregroundColor: const Color(0xFF14201C), actions: [IconButton(onPressed: onFavorite, icon: Icon(isFavorite ? Icons.bookmark : Icons.bookmark_border))], flexibleSpace: FlexibleSpaceBar(background: Image.network(property.image, fit: BoxFit.cover))), SliverPadding(padding: const EdgeInsets.fromLTRB(22, 24, 22, 30), sliver: SliverToBoxAdapter(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [_Tag(property.tag), const Spacer(), const Icon(Icons.star, color: Color(0xFFE2A72E), size: 18), const SizedBox(width: 4), const Text('4.9 (12 reviews)', style: TextStyle(fontWeight: FontWeight.bold))]), const SizedBox(height: 15), Text(property.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)), const SizedBox(height: 7), Row(children: [const Icon(Icons.location_on_outlined, size: 18, color: Colors.black54), const SizedBox(width: 5), Text(property.area, style: const TextStyle(color: Colors.black54))]), const SizedBox(height: 23), Text(property.price, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F766E))), const Text('per month', style: TextStyle(color: Colors.black54)), const SizedBox(height: 25), Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_Stat(Icons.bed_outlined, '${property.beds} Beds'), _Stat(Icons.bathtub_outlined, '${property.baths} Baths'), _Stat(Icons.chair_outlined, property.furnished ? 'Furnished' : 'Unfurnished')]), const SizedBox(height: 28), const Text('About this home', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)), const SizedBox(height: 8), const Text('A thoughtfully designed space in a well-connected neighbourhood. Enjoy bright rooms, quality finishes and the peace of a home that feels just right.', style: TextStyle(height: 1.5, color: Colors.black54)), const SizedBox(height: 28), SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Inquiry started. The agent will be in touch soon.'))), icon: const Icon(Icons.chat_bubble_outline), label: const Text('Contact agent'))])))]));
  */
}

class _Stat extends StatelessWidget {
  const _Stat(this.icon, this.text);
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Icon(icon, color: const Color(0xFF5B3FD6)),
      const SizedBox(height: 6),
      Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    ],
  );
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, this.token});
  final String? token;

  void signOut(BuildContext context) {
    authService.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const RoleSelectScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(22, 30, 22, 20),
    children: [
      Text(
        'Your profile',
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
      ),
      const SizedBox(height: 24),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const LoginScreen(role: 'renter'),
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary,
            side: BorderSide(color: Theme.of(context).colorScheme.primary),
          ),
          icon: Icon(Icons.login, color: Theme.of(context).colorScheme.primary),
          label: const Text('Sign in to your account'),
        ),
      ),
      const SizedBox(height: 18),
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                authService.user?.displayName.isNotEmpty == true
                    ? authService.user!.displayName
                          .substring(0, 1)
                          .toUpperCase()
                    : '?',
                style: TextStyle(
                  fontSize: 22,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  authService.user?.displayName ?? 'Account holder',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  '${authService.user?.role ?? 'renter'} account',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 26),
      _Menu(
        icon: Icons.notifications_none,
        title: 'Notifications',
        detail: 'New homes and saved searches',
        onTap: token == null
            ? null
            : () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NotificationsScreen(token: token!),
                ),
              ),
      ),
      _Menu(
        icon: Icons.shield_outlined,
        title: 'Safety centre',
        detail: 'Tips for a confident rental search',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const SafetyCentreScreen(),
          ),
        ),
      ),
      _Menu(
        icon: Icons.help_outline,
        title: 'Help & support',
        detail: 'We are here to help',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const HelpSupportScreen(),
          ),
        ),
      ),
      _Menu(
        icon: Icons.settings_outlined,
        title: 'Settings',
        detail: 'Account and app preferences',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SettingsScreen(authService: authService),
          ),
        ),
      ),
      const SizedBox(height: 18),
      OutlinedButton.icon(
        onPressed: () => signOut(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.primary,
          side: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
        icon: Icon(Icons.logout, color: Theme.of(context).colorScheme.primary),
        label: const Text('Sign out'),
      ),
    ],
  );
}

class _Menu extends StatelessWidget {
  const _Menu({
    required this.icon,
    required this.title,
    required this.detail,
    this.onTap,
  });
  final IconData icon;
  final String title, detail;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(vertical: 7),
    leading: CircleAvatar(
      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
      child: Icon(icon, color: Theme.of(context).colorScheme.primary),
    ),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    subtitle: Text(detail),
    trailing: Icon(
      Icons.chevron_right,
      color: Theme.of(context).colorScheme.primary,
    ),
  );
}

class FilterSheet extends StatefulWidget {
  const FilterSheet({
    super.key,
    this.propertyType,
    this.bedrooms,
    this.maxPrice,
  });
  final String? propertyType;
  final int? bedrooms;
  final double? maxPrice;
  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late String? propertyType = widget.propertyType;
  late int? bedrooms = widget.bedrooms;
  late double? maxPrice = widget.maxPrice;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Refine your search',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Property type',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: ['apartment', 'house', 'studio', 'townhouse']
                .map(
                  (value) => ChoiceChip(
                    label: Text(value[0].toUpperCase() + value.substring(1)),
                    selected: propertyType == value,
                    onSelected: (selected) =>
                        setState(() => propertyType = selected ? value : null),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 18),
          const Text('Bedrooms', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [null, 1, 2, 3]
                .map(
                  (value) => ChoiceChip(
                    label: Text(value == null ? 'Any' : '$value+'),
                    selected: bedrooms == value,
                    onSelected: (selected) =>
                        setState(() => bedrooms = selected ? value : null),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 18),
          TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Maximum monthly rent',
              prefixText: 'GH₵ ',
            ),
            onChanged: (value) => maxPrice = double.tryParse(value),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context, {
                'propertyType': propertyType,
                'bedrooms': bedrooms,
                'maxPrice': maxPrice,
              }),
              child: const Text('Show homes'),
            ),
          ),
        ],
      ),
    ),
  );
}
