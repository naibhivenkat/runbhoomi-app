import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  LatLng selectedLocation = const LatLng(12.9716, 77.5946);
  GoogleMapController? mapController;

  String address = "Move map to select location";
  bool loadingAddress = false;

  /// 🔥 Prevent multiple API calls
  bool isFetchingAddress = false;

  /// ================= LOCATION =================
  Future<void> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        showMsg("Enable location services");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        showMsg("Permission permanently denied");
        return;
      }

      Position pos = await Geolocator.getCurrentPosition();

      LatLng current = LatLng(pos.latitude, pos.longitude);

      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(current, 16),
      );

      selectedLocation = current;

      await getAddress(current);
    } catch (e) {
      showMsg("Location error");
    }
  }

  /// ================= REVERSE GEOCODING =================
  Future<void> getAddress(LatLng position) async {
    if (isFetchingAddress) return; // prevent spam
    isFetchingAddress = true;

    if (!mounted) return;

    setState(() => loadingAddress = true);

    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (!mounted) return;

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        setState(() {
          address =
              "${place.locality ?? ""}, ${place.administrativeArea ?? ""}, ${place.country ?? ""}";
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        address = "Unable to fetch address";
      });
    }

    if (!mounted) return;

    setState(() => loadingAddress = false);

    isFetchingAddress = false;
  }

  /// ================= UI HELPERS =================
  void showMsg(String msg) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  /// ================= INIT =================
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getCurrentLocation();
    });
  }

  /// ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Location"),
      ),
      body: Stack(
        children: [
          /// MAP
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: selectedLocation,
              zoom: 14,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,

            onMapCreated: (controller) {
              mapController = controller;
            },

            onCameraMove: (position) {
              selectedLocation = position.target;
            },

            /// 🔥 FIX: Only call when user stops moving
            onCameraIdle: () {
              getAddress(selectedLocation);
            },
          ),

          /// PIN
          const Center(
            child: Icon(Icons.location_pin,
                size: 50, color: Colors.red),
          ),

          /// CURRENT LOCATION BUTTON
          Positioned(
            top: 20,
            right: 10,
            child: FloatingActionButton(
              mini: true,
              onPressed: getCurrentLocation,
              child: const Icon(Icons.my_location),
            ),
          ),

          /// ADDRESS BOX
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  loadingAddress
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          address,
                          textAlign: TextAlign.center,
                        ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, {
                          "address": address,
                          "lat": selectedLocation.latitude,
                          "lng": selectedLocation.longitude,
                        });
                      },
                      child: const Text("Confirm Location"),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  /// ================= CLEANUP =================
  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }
}