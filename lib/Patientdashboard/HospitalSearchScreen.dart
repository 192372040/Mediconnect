import 'package:flutter/material.dart';
import 'package:my_project/Patientdashboard/HospitalDetailScreen.dart';
import 'package:my_project/Patientdashboard/services/api_service.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class HospitalSearchScreen extends StatefulWidget {
  const HospitalSearchScreen({super.key});

  @override
  State<HospitalSearchScreen> createState() => _HospitalSearchScreenState();
}

class _HospitalSearchScreenState extends State<HospitalSearchScreen> {
  static const Color primary = Color(0xFF0F6E56);
  static const Color primaryBg = Color(0xFF2C2A2A);
  static const Color cardBg = Color(0xFF1A1A1A);
  static const Color borderColor = Color(0xFF3A3A3A);

  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Open now';
  GoogleMapController? mapController;

  Set<Marker> hospitalMarkers = {};
  Set<Polyline> polylines = {};

  List<LatLng> polylineCoordinates = [];
  List<dynamic> _hospitals = [];
  List<dynamic> _filteredHospitals = [];
  bool _isLoading = true;
  Position? currentPosition;
  Map<String, dynamic>? selectedHospital;

  bool isLocationLoading = false;

  @override
  void initState() {
    super.initState();
    fetchHospitals();
    getCurrentLocation();
  }

  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371;

    double dLat = (lat2 - lat1) * pi / 180;
    double dLon = (lon2 - lon1) * pi / 180;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  Future<void> getCurrentLocation() async {
    setState(() {
      isLocationLoading = true;
    });

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please enable location"),
          ),
        );
      }
      return;
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    currentPosition = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
    );

    debugPrint(currentPosition!.latitude.toString());
    debugPrint(currentPosition!.longitude.toString());
    // Move camera to current location
    if (mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(currentPosition!.latitude, currentPosition!.longitude),
          14,
        ),
      );
    }

    _hospitals.sort((a, b) {
      double distanceA = calculateDistance(
        currentPosition!.latitude,
        currentPosition!.longitude,
        a["latitude"],
        a["longitude"],
      );

      double distanceB = calculateDistance(
        currentPosition!.latitude,
        currentPosition!.longitude,
        b["latitude"],
        b["longitude"],
      );
      a["dynamic_distance"] = distanceA;
      b["dynamic_distance"] = distanceB;
      return distanceA.compareTo(distanceB);
    });

    setState(() {
      _filteredHospitals = _hospitals;
    });

    setState(() {
      isLocationLoading = false;
    });
  }

  Future<void> fetchNearbyHospitals() async {
    if (currentPosition == null) return;

    final url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
        "?location=${currentPosition!.latitude},${currentPosition!.longitude}"
        "&radius=10000"
        "&type=hospital"
        "&key=AIzaSyAm3CA2yR4Qp6ArIIBlrpLBALIXmDZGaWM";

    final response = await http.get(
      Uri.parse(url),
    );

    final data = jsonDecode(response.body);

    debugPrint("Google Places API Response: $data");

    if (data['status'] != 'OK') {
      debugPrint("API Error: ${data['status']}");
      return;
    }

    Set<Marker> markers = {...hospitalMarkers};

    for (var hospital in data["results"]) {
      final lat = hospital["geometry"]["location"]["lat"];

      final lng = hospital["geometry"]["location"]["lng"];

      markers.add(
        Marker(
          markerId: MarkerId(
            hospital["place_id"],
          ),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
            title: hospital["name"],
          ),
        ),
      );
    }

    setState(() {
      hospitalMarkers = markers;
    });
  }

  Future<void> openGoogleMaps(Map<String, dynamic> hospital) async {
    final Uri url = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(hospital["name"])}",
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } else {
      debugPrint("Could not launch Google Maps");
    }
  }

  Future<void> fetchHospitals() async {
    try {
      final dynamic hospitals = await ApiService.getHospitals();
      debugPrint('fetchHospitals result: $hospitals');

      final hospitalList = hospitals is List ? hospitals : <dynamic>[];
      if (hospitalList.isEmpty) {
        // If the backend returns an error map or unexpected payload, keep loading false.
        if (hospitals is Map && hospitals.containsKey('error')) {
          throw Exception(hospitals['error']);
        }
      }

      setState(() {
        _hospitals = hospitalList;
        _filteredHospitals = hospitalList;
        loadHospitalMarkers();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("ERROR: $e");

      setState(() {
        _isLoading = false;
      });
    }
  }

  void loadHospitalMarkers() {
    Set<Marker> markers = {};

    for (var hospital in _hospitals) {
      markers.add(
        Marker(
          markerId: MarkerId(
            hospital["id"].toString(),
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            selectedHospital != null &&
                    selectedHospital!["id"] == hospital["id"]
                ? BitmapDescriptor.hueBlue
                : hospital["online"] == 1
                    ? BitmapDescriptor.hueGreen
                    : BitmapDescriptor.hueRed,
          ),
          position: LatLng(
            hospital["latitude"],
            hospital["longitude"],
          ),
          infoWindow: InfoWindow(
            title: hospital["name"],
            snippet: hospital["online"] == 1
                ? "Booking Available"
                : "Not Available Online",
          ),
        ),
      );
    }

    setState(() {
      hospitalMarkers = markers;
    });
  }

  Future<void> startRouteNavigation() async {
    if (selectedHospital == null || currentPosition == null) return;

    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: "AIzaSyAm3CA2yR4Qp6ArIIBlrpLBALIXmDZGaWM",
      request: PolylineRequest(
        origin: PointLatLng(
          currentPosition!.latitude,
          currentPosition!.longitude,
        ),
        destination: PointLatLng(
          selectedHospital!["latitude"],
          selectedHospital!["longitude"],
        ),
        mode: TravelMode.driving,
      ),
    );
    polylineCoordinates.clear();

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        );
      }
    }

    setState(() {
      polylines.clear();

      polylines.add(
        Polyline(
          polylineId: const PolylineId("route"),
          points: polylineCoordinates,
          width: 5,
          color: Colors.blue,
        ),
      );
    });
  }

  void startNavigation(Map<String, dynamic> hospital) {
    setState(() {
      selectedHospital = hospital;

      loadHospitalMarkers();
    });

    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(
          hospital["latitude"],
          hospital["longitude"],
        ),
        15,
      ),
    );
  }

  void searchHospitals(String query) {
    final filtered = _hospitals.where((hospital) {
      final name = hospital["name"].toString().toLowerCase();

      return name.contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredHospitals = filtered;
    });
  }

  void applyFilter(String filter) {
    List<dynamic> filtered = [];

    if (filter == 'Open now') {
      filtered = _hospitals.where((hospital) {
        return hospital["status"].toString().toLowerCase().contains("open");
      }).toList();
    } else if (filter == 'Emergency') {
      filtered = _hospitals.where((hospital) {
        return hospital["emergency"] == 1;
      }).toList();
    } else if (filter == 'Online') {
      filtered = _hospitals.where((hospital) {
        return hospital["online"] == 1;
      }).toList();
    } else if (filter == 'Top Rated') {
      filtered = _hospitals.where((hospital) {
        return hospital["top_rated"] == 1;
      }).toList();
    } else if (filter == 'Not Available Online') {
      filtered = _hospitals.where((hospital) {
        return hospital["online"] == 0;
      }).toList();
    } else {
      filtered = _hospitals;
    }

    setState(() {
      _selectedFilter = filter;
      _filteredHospitals = filtered;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search hospital or clinic...',
                  hintStyle:
                      const TextStyle(color: Colors.white38, fontSize: 13),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: primary, size: 20),
                  filled: true,
                  fillColor: cardBg,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: borderColor, width: 0.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primary, width: 1.5),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  searchHospitals(value);
                },
              ),
            ),
            _buildFilterChips(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: primary,
                      ),
                    )
                  : _filteredHospitals.isEmpty
                      ? const Center(
                          child: Text(
                            'No hospitals found',
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                          itemCount: _filteredHospitals.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) => _buildHospitalCard(
                              _filteredHospitals[i], context),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: primaryBg,
        border: Border(bottom: BorderSide(color: borderColor, width: 0.5)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 1),
              ),
              child: const Icon(Icons.chevron_left_rounded,
                  color: primary, size: 22),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Find a hospital',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      'Open now',
      'Emergency',
      'Online',
      'Not Available Online',
      'Top Rated',
    ];

    return Container(
      height: 54,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final filter = filters[i];
          final selected = _selectedFilter == filter;
          return GestureDetector(
            onTap: () => applyFilter(filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: selected ? primary : cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? primary : borderColor,
                  width: 0.5,
                ),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  fontSize: 12,
                  color: selected ? Colors.white : Colors.white54,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHospitalCard(
      Map<String, dynamic> hospital, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (hospital["online"] == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HospitalDetailScreen(
                hospitalId: hospital["id"],
                hospitalName: hospital['name']!,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "This hospital is not available for online booking",
              ),
            ),
          );
        }
      },
      // onTap: () => Navigator.push(
      child: Opacity(
        opacity: hospital["online"] == 1 ? 1.0 : 0.82,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selectedHospital != null &&
                      selectedHospital!["id"] == hospital["id"]
                  ? Colors.blue
                  : hospital["online"] == 1
                      ? Colors.green.withValues(alpha: 0.4)
                      : Colors.red.withValues(alpha: 0.4),
              width: 0.8,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: const Color(0xFF1A2A22),
                    borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.local_hospital_rounded,
                    color: Color(0xFF1D9E75), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hospital['name']?.toString() ?? 'Unknown hospital',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                            hospital["dynamic_distance"] != null
                                ? "${hospital["dynamic_distance"].toStringAsFixed(1)} km"
                                : hospital['distance'],
                            style: const TextStyle(
                                fontSize: 11, color: Color(0xFF1D9E75))),
                        const Text(' · ',
                            style:
                                TextStyle(fontSize: 11, color: Colors.white38)),
                        Text(hospital['status']!,
                            style: const TextStyle(
                                fontSize: 11, color: Colors.white54)),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Color(0xFFEF9F27), size: 12),
                        const SizedBox(width: 3),
                        Text(hospital['rating']!,
                            style: const TextStyle(
                                fontSize: 11, color: Colors.white54)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                              color: const Color(0xFF1A2A22),
                              borderRadius: BorderRadius.circular(4)),
                          child: Text(hospital['type']!,
                              style: const TextStyle(
                                  fontSize: 9, color: Color(0xFF1D9E75))),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: hospital["online"] == 1
                                ? Colors.green.withValues(alpha: 0.15)
                                : Colors.grey.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            hospital["online"] == 1
                                ? "Available"
                                : "Unavailable",
                            style: TextStyle(
                              fontSize: 9,
                              color: hospital["online"] == 1
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: hospital["online"] == 1
                          ? Colors.green.withValues(alpha: 0.12)
                          : Colors.red.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      hospital["online"] == 1 ? "Book" : "View",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color:
                            hospital["online"] == 1 ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () {
                      openGoogleMaps(hospital);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "Directions",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
