import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/whatsapp_launcher.dart';
import '../../../shared/widgets/animated_entry.dart';
import '../../../shared/widgets/premium_action_button.dart';
import '../../auth/application/auth_controller.dart';
import '../data/home_repository.dart';
import '../domain/home_content.dart';
import '../../pets/presentation/histories_page.dart';
import '../../pets/presentation/pets_page.dart';
import '../../profile/presentation/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({this.initialTab = 0, super.key});

  final int initialTab;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _index = widget.initialTab;

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) _index = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _LandingPage(onHistoryTap: () => setState(() => _index = 2)),
      const PetsPage(),
      const HistoriesPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: KeyedSubtree(key: ValueKey(_index), child: pages[_index]),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: MediaQuery.paddingOf(context).bottom + 14,
            child: _FloatingNavBar(
              selectedIndex: _index,
              onSelected: (value) => setState(() => _index = value),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItemData(
        label: 'Home',
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
      ),
      _NavItemData(
        label: 'Anabul',
        icon: Icons.pets_outlined,
        activeIcon: Icons.pets_rounded,
      ),
      _NavItemData(
        label: 'Riwayat',
        icon: Icons.history_outlined,
        activeIcon: Icons.history_rounded,
      ),
      _NavItemData(
        label: 'Profil',
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
      ),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: 72,
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.66)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withValues(alpha: 0.18),
                blurRadius: 30,
                offset: const Offset(0, 16),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 18,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _FloatingNavItem(
                    item: items[i],
                    selected: selectedIndex == i,
                    onTap: () => onSelected(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatingNavItem extends StatelessWidget {
  const _FloatingNavItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItemData item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      label: item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryDark],
                  )
                : null,
            color: selected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.22),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            scale: selected ? 1.04 : 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  selected ? item.activeIcon : item.icon,
                  color: selected ? Colors.white : AppColors.textSecondary,
                  size: selected ? 25 : 23,
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 180),
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  ),
                  child: Text(item.label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  const _NavItemData({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}

class _LandingPage extends ConsumerStatefulWidget {
  const _LandingPage({required this.onHistoryTap});

  final VoidCallback onHistoryTap;

  @override
  ConsumerState<_LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends ConsumerState<_LandingPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(homeContentProvider);
    }
  }

  Future<void> _refreshHome() {
    return ref.refresh(homeContentProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final member = ref.watch(authControllerProvider).asData?.value;
    final firstName = member?.fullname.trim().split(RegExp(r'\s+')).first;
    final greeting = firstName == null || firstName.isEmpty
        ? 'Halo, Pengguna Booboo'
        : 'Halo, $firstName';
    final content =
        ref.watch(homeContentProvider).asData?.value ?? HomeContent.fallback();
    final fallback = HomeContent.fallback();
    final services = content.services.isEmpty
        ? fallback.services
        : content.services;

    return SafeArea(
      child: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _refreshHome,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 124),
          children: [
            AnimatedEntry(
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Image.asset('assets/images/logo.v2.png'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Booboo Pet Care',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Tooltip(
                    message: 'Refresh Home',
                    child: IconButton.filledTonal(
                      onPressed: _refreshHome,
                      icon: const Icon(Icons.refresh_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.softPurple,
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Tooltip(
                    message: 'Bantuan',
                    child: IconButton.filledTonal(
                      onPressed: () => _openWhatsapp(context),
                      icon: const Icon(Icons.support_agent_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.softPurple,
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            AnimatedEntry(
              delay: const Duration(milliseconds: 80),
              child: Container(
                height: 226,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFFFFF), AppColors.lavender],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      blurRadius: 32,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.94, end: 1),
                        duration: const Duration(milliseconds: 900),
                        curve: Curves.easeOutBack,
                        builder: (context, value, child) =>
                            Transform.scale(scale: value, child: child),
                        child: Icon(
                          Icons.pets_rounded,
                          size: 122,
                          color: AppColors.primary.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.softPurple.withValues(alpha: 0.88),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            greeting,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'Pantau riwayat perawatan anabul.',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w900,
                                height: 1.14,
                              ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Semua kunjungan, diagnosa, dan catatan klinik masuk dalam satu aplikasi.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            height: 1.45,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            AnimatedEntry(
              delay: const Duration(milliseconds: 150),
              child: PremiumActionButton(
                label: 'Lihat Riwayat',
                icon: Icons.history_rounded,
                onPressed: widget.onHistoryTap,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Promo & Info',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            AnimatedEntry(
              delay: Duration(milliseconds: 210),
              child: _PromoInfoSlider(
                banners: content.banners,
                events: content.events,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Layanan Kami',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            _ServiceGrid(services: services),
          ],
        ),
      ),
    );
  }

  Future<void> _openWhatsapp(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final opened = await openBoobooWhatsapp(
      'Halo Booboo Pet Care, saya ingin bertanya tentang layanan dan riwayat perawatan anabul.',
    );
    if (!opened) {
      messenger.showSnackBar(
        const SnackBar(content: Text('WhatsApp tidak bisa dibuka')),
      );
    }
  }
}

class _PromoInfoSlider extends StatefulWidget {
  const _PromoInfoSlider({required this.banners, required this.events});

  final List<HomeBanner> banners;
  final List<HomeEvent> events;

  @override
  State<_PromoInfoSlider> createState() => _PromoInfoSliderState();
}

class _PromoInfoSliderState extends State<_PromoInfoSlider> {
  final _controller = PageController(viewportFraction: 0.92);
  var _index = 0;
  var _page = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_syncPage);
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_controller.hasClients) return;
      final next = (_index + 1) % _items.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.removeListener(_syncPage);
    _controller.dispose();
    super.dispose();
  }

  void _syncPage() {
    if (!mounted || !_controller.hasClients) return;
    final page = _controller.page ?? _index.toDouble();
    setState(() => _page = page);
  }

  List<_PromoData> get _items {
    final items = <_PromoData>[
      ...widget.banners.map(
        (banner) => _PromoData(
          badge: 'Promo',
          icon: Icons.local_offer_outlined,
          title: banner.name,
          body: 'Lihat promo terbaru dari Booboo Pet Care.',
          image: banner.image,
          color: AppColors.primary,
        ),
      ),
      ...widget.events.map(
        (event) => _PromoData(
          badge: 'Info',
          icon: Icons.event_outlined,
          title: event.name,
          body: event.description.isEmpty
              ? 'Informasi terbaru dari Booboo Pet Care.'
              : event.description,
          image: event.image,
          color: AppColors.mint,
        ),
      ),
    ];

    return items.isEmpty
        ? [
            const _PromoData(
              badge: 'Info',
              icon: Icons.medical_information_outlined,
              title: 'Riwayat Perawatan',
              body:
                  'Diagnosa, tindakan, dan catatan dokter tersimpan di aplikasi.',
              image: '',
              color: AppColors.mint,
            ),
          ]
        : items;
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    if (_index >= items.length) _index = 0;

    return Column(
      children: [
        SizedBox(
          height: 154,
          child: PageView.builder(
            controller: _controller,
            itemCount: items.length,
            onPageChanged: (value) => setState(() => _index = value),
            itemBuilder: (context, index) {
              final item = items[index];
              final distance = (_page - index).abs().clamp(0.0, 1.0);
              final scale = 1 - (distance * 0.045);
              final opacity = 1 - (distance * 0.28);
              return Padding(
                padding: EdgeInsets.only(
                  right: index == items.length - 1 ? 0 : 12,
                ),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 220),
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            item.color.withValues(alpha: 0.13),
                            AppColors.surface,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: item.color.withValues(alpha: 0.08),
                            blurRadius: 22,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.92, end: 1),
                              duration: const Duration(milliseconds: 650),
                              curve: Curves.easeOutBack,
                              builder: (context, value, child) =>
                                  Transform.scale(scale: value, child: child),
                              child: item.image.isEmpty
                                  ? Container(
                                      width: 76,
                                      height: 76,
                                      decoration: BoxDecoration(
                                        color: item.color.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(26),
                                      ),
                                      child: Icon(
                                        item.icon,
                                        size: 38,
                                        color: item.color.withValues(
                                          alpha: 0.72,
                                        ),
                                      ),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(26),
                                      child: CachedNetworkImage(
                                        imageUrl: item.image,
                                        width: 92,
                                        height: 92,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            Container(
                                              width: 92,
                                              height: 92,
                                              color: item.color.withValues(
                                                alpha: 0.1,
                                              ),
                                            ),
                                        errorWidget: (context, url, error) =>
                                            Container(
                                              width: 76,
                                              height: 76,
                                              color: item.color.withValues(
                                                alpha: 0.1,
                                              ),
                                              child: Icon(
                                                item.icon,
                                                size: 38,
                                                color: item.color.withValues(
                                                  alpha: 0.72,
                                                ),
                                              ),
                                            ),
                                      ),
                                    ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 260),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: item.color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  item.badge,
                                  style: TextStyle(
                                    color: item.color,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 6),
                              SizedBox(
                                width: MediaQuery.sizeOf(context).width * 0.5,
                                child: Text(
                                  item.body,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                        height: 1.35,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < items.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _index == i ? 18 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: _index == i ? AppColors.primary : AppColors.border,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _PromoData {
  const _PromoData({
    required this.badge,
    required this.icon,
    required this.title,
    required this.body,
    required this.image,
    required this.color,
  });

  final String badge;
  final IconData icon;
  final String title;
  final String body;
  final String image;
  final Color color;
}

class _ServiceGrid extends StatelessWidget {
  const _ServiceGrid({required this.services});

  final List<HomeService> services;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.05,
      ),
      itemBuilder: (context, index) {
        final service = services[index];
        return AnimatedEntry(
          delay: Duration(milliseconds: 55 * index),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.softPurple,
                        AppColors.mint.withValues(alpha: 0.16),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(service.iconData, color: AppColors.primary),
                ),
                const SizedBox(height: 10),
                Text(
                  service.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  service.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
