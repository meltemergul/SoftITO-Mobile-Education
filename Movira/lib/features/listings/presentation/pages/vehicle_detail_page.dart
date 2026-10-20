import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/vehicle_listing_entity.dart';
import '../../domain/repositories/vehicle_listing_repository.dart';
import '../controllers/vehicle_detail_controller.dart';
import '../controllers/vehicle_detail_state.dart';

class VehicleDetailPage extends StatefulWidget {
  final String listingId;
  final VehicleListingEntity? initialListing;

  const VehicleDetailPage({
    super.key,
    this.listingId = 'listing_001',
    this.initialListing,
  });

  @override
  State<VehicleDetailPage> createState() => _VehicleDetailPageState();
}

class _VehicleDetailPageState extends State<VehicleDetailPage> {
  late final VehicleDetailController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VehicleDetailController(initialListing: widget.initialListing);
    if (widget.initialListing == null) {
      _controller.loadListing(widget.listingId);
    }
  }

  @override
  void didUpdateWidget(covariant VehicleDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialListing != null && widget.initialListing != oldWidget.initialListing) {
      _controller.setInitialListing(widget.initialListing!);
    } else if (widget.listingId != oldWidget.listingId) {
      _controller.loadListing(widget.listingId);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Movira Araç Detayı',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: globalThemeNotifier,
            builder: (context, currentMode, _) {
              final isDark = currentMode == ThemeMode.dark;
              return IconButton(
                tooltip: isDark ? 'Açık Temaya Geç' : 'Koyu Temaya Geç',
                icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
                onPressed: () {
                  globalThemeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
                },
              );
            },
          ),
          ValueListenableBuilder<VehicleDetailState>(
            valueListenable: _controller,
            builder: (context, state, _) {
              final isFav = state is VehicleDetailSuccess && state.isFavorite;
              return IconButton(
                tooltip: isFav ? 'Favorilerden Çıkar' : 'Favorilere Ekle',
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? theme.colorScheme.primary : null,
                ),
                onPressed: state is VehicleDetailSuccess ? _controller.toggleFavorite : null,
              );
            },
          ),
          PopupMenuButton<String>(
            tooltip: 'Durum Test Menüsü',
            icon: const Icon(Icons.tune_outlined),
            onSelected: (value) {
              switch (value) {
                case 'success':
                  _controller.loadListing('listing_001');
                  break;
                case 'loading':
                  _controller.value = const VehicleDetailLoading();
                  break;
                case 'empty':
                  _controller.loadListing('empty_trigger');
                  break;
                case 'error':
                  _controller.loadListing('error_trigger');
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'success', child: Text('✅ Başarılı Durumu (Success)')),
              const PopupMenuItem(value: 'loading', child: Text('⏳ Yükleniyor (Loading)')),
              const PopupMenuItem(value: 'empty', child: Text('📭 Boş Durum (Empty)')),
              const PopupMenuItem(value: 'error', child: Text('⚠️ Hata Durumu (Error)')),
            ],
          ),
        ],
      ),
      body: ValueListenableBuilder<VehicleDetailState>(
        valueListenable: _controller,
        builder: (context, state, _) {
          return switch (state) {
            VehicleDetailInitial() => const Center(child: Text('İlan yüklenmeye hazır.')),
            VehicleDetailLoading() => _buildLoadingState(context),
            VehicleDetailEmpty(message: final msg) => _buildEmptyState(context, msg),
            VehicleDetailError(message: final msg, canRetry: final retryable) =>
              _buildErrorState(context, msg, retryable),
            VehicleDetailSuccess() => _buildSuccessContent(context, state),
          };
        },
      ),
      bottomNavigationBar: ValueListenableBuilder<VehicleDetailState>(
        valueListenable: _controller,
        builder: (context, state, _) {
          if (state is! VehicleDetailSuccess) return const SizedBox.shrink();
          return _buildPersistentBottomBar(context, state);
        },
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Araç ve ilan bilgileri yükleniyor...',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.directions_car_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'İlan Bulunamadı',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => _controller.loadListing('listing_001'),
              icon: const Icon(Icons.refresh),
              label: const Text('Varsayılan İlanı Yükle'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message, bool canRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_off_rounded, size: 60, color: Colors.red),
            ),
            const SizedBox(height: 20),
            Text(
              'Bir Sorun Oluştu',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 24),
            if (canRetry)
              ElevatedButton.icon(
                onPressed: _controller.retry,
                icon: const Icon(Icons.replay_outlined),
                label: const Text('Yeniden Dene'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessContent(BuildContext context, VehicleDetailSuccess state) {
    final listing = state.listing;
    final vehicle = listing.vehicle;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPhotoGallery(context, state),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              vehicle.vehicleClass.label,
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            listing.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        listing.pickupLocation,
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.star_rounded, size: 20, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 4),
                    Text(
                      '${listing.ratingAverage.toStringAsFixed(1)} (${listing.reviewCount})',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ],
                ),
                const Divider(height: 32),
                Text(
                  'Temel Özellikler',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildFeatureChip(context, Icons.speed_outlined, vehicle.transmission.label),
                    const SizedBox(width: 8),
                    _buildFeatureChip(context, Icons.local_gas_station_outlined, vehicle.fuel.label),
                    const SizedBox(width: 8),
                    _buildFeatureChip(context, Icons.airline_seat_recline_normal_outlined, '${vehicle.seatCount} Koltuk'),
                  ],
                ),
                const SizedBox(height: 20),
                _buildDateSelectionCard(context, state),
                const SizedBox(height: 20),
                _buildHostInfoCard(context, listing),
                const SizedBox(height: 20),
                Text(
                  'Araç Donanımı',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: vehicle.features.map((feature) {
                    return Chip(
                      avatar: const Icon(Icons.check_circle_outline, size: 16),
                      label: Text(feature, style: const TextStyle(fontSize: 12)),
                      visualDensity: VisualDensity.compact,
                      side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
                      backgroundColor: theme.colorScheme.surface,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Text(
                  'İlan Açıklaması',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  listing.description,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGallery(BuildContext context, VehicleDetailSuccess state) {
    final vehicle = state.listing.vehicle;
    final photos = vehicle.photoUrls;
    final selectedIndex = state.selectedPhotoIndex.clamp(0, photos.isNotEmpty ? photos.length - 1 : 0);
    final theme = Theme.of(context);

    if (photos.isEmpty) {
      return Container(
        height: 220,
        color: Colors.black12,
        child: const Center(child: Icon(Icons.directions_car, size: 60, color: Colors.grey)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Container(
                width: double.infinity,
                color: Colors.black12,
                child: Image.network(
                  photos[selectedIndex],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade200,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.directions_car, size: 48, color: theme.colorScheme.primary),
                          const SizedBox(height: 8),
                          Text(
                            '${vehicle.brand} ${vehicle.model}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Marka & Model Rozeti
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified, color: Colors.amber, size: 14),
                    const SizedBox(width: 5),
                    Text(
                      '${vehicle.brand} • ${vehicle.year}',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            // Fotoğraf Sayacı
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.photo_library_outlined, color: Colors.white, size: 14),
                    const SizedBox(width: 5),
                    Text(
                      '${selectedIndex + 1} / ${photos.length} Fotoğraf',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        // Aracın tüm gerçek fotoğrafları için alt küçük resim şeridi
        if (photos.length > 1)
          Container(
            height: 72,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, idx) {
                final isSelected = idx == selectedIndex;
                return GestureDetector(
                  onTap: () => _controller.selectPhotoIndex(idx),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 78,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? theme.colorScheme.primary : theme.dividerColor.withValues(alpha: 0.4),
                        width: isSelected ? 2.5 : 1.0,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: theme.colorScheme.primary.withValues(alpha: 0.35),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        photos[idx],
                        fit: BoxFit.cover,
                        errorBuilder: (context, _, _) => Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image, size: 18, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildFeatureChip(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.4)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: theme.colorScheme.primary),
            const SizedBox(height: 6),
            Text(
              text,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelectionCard(BuildContext context, VehicleDetailSuccess state) {
    final theme = Theme.of(context);
    final startStr = '${state.startDate.day}.${state.startDate.month}.${state.startDate.year}';
    final endStr = '${state.endDate.day}.${state.endDate.month}.${state.endDate.year}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kiralama Tarihleri',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: () => _pickDateRange(context, state),
                icon: const Icon(Icons.calendar_month_outlined, size: 16),
                label: const Text('Değiştir', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Alış Tarihi', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 2),
                      Text(startStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.grey),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('İade Tarihi', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 2),
                      Text(endStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Toplam Süre: ${state.totalDays} Gün',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              Text(
                'Tahmini Tutar: ${state.calculatedTotalPrice.formatted}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHostInfoCard(BuildContext context, VehicleListingEntity listing) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
            foregroundColor: theme.colorScheme.primary,
            child: const Icon(Icons.person_outline),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listing.hostName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 4),
                    Text(
                      '${listing.hostRating.toStringAsFixed(1)} Araç Sahibi Puanı',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Araç sahibine soru sorma mesaj paneli açılıyor...')),
              );
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Text('Soru Sor', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildPersistentBottomBar(BuildContext context, VehicleDetailSuccess state) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.calculatedTotalPrice.formatted,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  '${state.totalDays} gün için toplam (${state.listing.dailyPrice.formatted}/gün)',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: state.isSubmittingOffer ? null : () => _showOfferDialog(context, state),
                child: state.isSubmittingOffer
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'Teklif Oluştur',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateRange(BuildContext context, VehicleDetailSuccess state) async {
    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      initialDateRange: DateTimeRange(start: state.startDate, end: state.endDate),
      helpText: 'Kiralama Tarih Aralığı Seçiniz',
      cancelText: 'Vazgeç',
      confirmText: 'Uygula',
    );

    if (pickedRange != null) {
      _controller.updateDateRange(pickedRange.start, pickedRange.end);
    }
  }

  void _showOfferDialog(BuildContext context, VehicleDetailSuccess state) {
    final messageController = TextEditingController(text: 'Merhaba, aracı belirtilen tarihlerde kiralamak istiyorum.');

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Kiralama Teklifi Gönder'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${state.listing.vehicle.fullName} için ${state.totalDays} günlük kiralama teklifi oluşturuyorsunuz.',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Toplam Teklif Tutarı:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      Text(
                        state.calculatedTotalPrice.formatted,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: messageController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Araç Sahibine Not / Mesaj',
                    hintText: 'Teslimat yeri veya özel isteklerinizi belirtebilirsiniz...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogCtx).pop();
                final result = await _controller.submitOffer(messageController.text);
                if (!context.mounted) return;

                switch (result) {
                  case Success(data: final offer):
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.green.shade700,
                        content: Text(
                          'Teklifiniz başarıyla iletildi! (Durum: ${offer.status.label}, Kiracı: ${offer.renterName})',
                        ),
                      ),
                    );
                  case Error(failure: final failure):
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.red.shade700,
                        content: Text(failure.message),
                      ),
                    );
                }
              },
              child: const Text('Onayla ve Gönder'),
            ),
          ],
        );
      },
    );
  }
}
