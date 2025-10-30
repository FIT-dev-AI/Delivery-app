import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/services/nominatim_service.dart';
import '../../core/constants/app_colors.dart';

class PlaceSearchScreen extends StatefulWidget {
  final String title;

  const PlaceSearchScreen({super.key, required this.title});

  @override
  State<PlaceSearchScreen> createState() => _PlaceSearchScreenState();
}

class _PlaceSearchScreenState extends State<PlaceSearchScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _focus = FocusNode();

  Timer? _timer;
  final Duration _debounce = const Duration(milliseconds: 350);

  bool _loading = false;
  List<Map<String, dynamic>> _results = [];

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() {})); // cập nhật suffixIcon
  }

  @override
  void dispose() {
    _timer?.cancel();
    _searchCtrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  double? _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  void _onChanged(String value) {
    _timer?.cancel();
    _timer = Timer(_debounce, () => _performSearch(value));
  }

  Future<void> _performSearch(String raw) async {
    final query = raw.trim();
    if (query.isEmpty) {
      if (mounted) setState(() => _results = []);
      return;
    }

    setState(() => _loading = true);
    try {
      // Dự án của bạn đang dùng searchPlaces
      final res = await NominatimService.searchPlaces(query);

      if (!mounted) return;
      // Không ép cấu trúc ở đây; chỉ gọn khi render. Normalize khi chọn item.
      setState(() => _results = List<Map<String, dynamic>>.from(res));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tìm kiếm: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _selectPlace(Map<String, dynamic> place) {
    // Ưu tiên format thân thiện từ service nếu có
    final Map<String, dynamic>? addressMap =
        place['address'] is Map<String, dynamic> ? place['address'] : null;
    final formatted = NominatimService.formatAddress(addressMap);

    final displayName = (place['display_name'] ?? '').toString();

    final lat = _toDouble(place['lat']);
    final lon = _toDouble(place['lon'] ?? place['lng']); // Nominatim → lon

    // formatted is non-nullable String from NominatimService.formatAddress
    final address = (formatted.isNotEmpty ? formatted : displayName).toString();

    final result = <String, dynamic>{
      'address': address,
      'display_name': displayName,
      'lat': lat,
      'lng': lon, // ⚠️ Chuẩn hoá: dùng 'lng' để đồng bộ với CreateOrderScreen
    };

    debugPrint('📍 Selected place (normalized): $result');
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.white,
        foregroundColor: textDark,
        centerTitle: true,
        elevation: 0.5,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchCtrl,
                focusNode: _focus,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onChanged: _onChanged,
                onSubmitted: _performSearch,
                decoration: InputDecoration(
                  hintText: 'Tìm địa chỉ...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchCtrl.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchCtrl.clear();
                            _focus.requestFocus();
                            setState(() => _results = []);
                          },
                        ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryOrange),
                  ),
                ),
              ),
            ),

            if (_loading) const LinearProgressIndicator(minHeight: 2),

            // Results
            Expanded(
              child: _loading
                  ? const SizedBox.shrink()
                  : _results.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 56, color: Colors.grey[400]),
                              const SizedBox(height: 12),
                              Text('Nhập địa chỉ để tìm kiếm',
                                  style: TextStyle(color: Colors.grey[600])),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: _results.length,
                          separatorBuilder: (_, __) =>
                              Divider(height: 1, color: Colors.grey[200]),
                          itemBuilder: (context, index) {
                            final place = _results[index];

                            final Map<String, dynamic>? addr =
                                place['address'] is Map<String, dynamic>
                                    ? place['address']
                                    : null;

                            final formatted = NominatimService.formatAddress(addr);
                            // formatted is non-nullable String
                            final title = (formatted.isNotEmpty)
                                ? formatted
                                : (place['display_name'] ?? '').toString();

                            return ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: primaryOrange,
                                child: Icon(Icons.location_on, color: Colors.white),
                              ),
                              title: Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                (place['display_name'] ?? '').toString(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                              onTap: () => _selectPlace(place),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
