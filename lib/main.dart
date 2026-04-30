import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'tasks_page.dart';
import 'habits_page.dart';
import 'profile_page.dart';
import 'trophy_room_page.dart';
import 'widgets.dart';
import 'repositories/task_repository.dart';
import 'repositories/habit_repository.dart';
import 'viewmodels/task_viewmodel.dart';
import 'viewmodels/habit_viewmodel.dart';
import 'services/notification_service.dart';
import 'providers/theme_provider.dart';
import 'services/backup_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final notificationService = NotificationService();
  await notificationService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TaskViewModel(
            repository: TaskRepository(),
            notificationService: notificationService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => HabitViewModel(repository: HabitRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        Provider(
          create: (_) => BackupService(),
        ),
      ],
      child: const MuslimDailyApp(),
    ),
  );
}

class MuslimDailyApp extends StatelessWidget {
  const MuslimDailyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DayPath',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFDCF6E3),
        textTheme: GoogleFonts.epilogueTextTheme(),
        primaryColor: const Color(0xFF1A1F2B),
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeProvider.accentColor,
          primary: themeProvider.accentColor,
        ),
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  bool _isProgrammaticChange = false;
  late final PageController _pageController;
  late final List<Widget> _pages;
  final GlobalKey<ProfilePageState> _profileKey = GlobalKey<ProfilePageState>();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _pages = [
      _HomeView(onNavigateToTab: _onNavTapped),
      TasksPage(onNavigateToTab: _onNavTapped),
      HabitsPage(onNavigateToTab: _onNavTapped),
      ProfilePage(onNavigateToTab: _onNavTapped, profileKey: _profileKey, key: _profileKey),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskViewModel>().loadTasks();
      context.read<HabitViewModel>().loadHabits();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTapped(int index) {
    if (index == _currentIndex) return;
    if (index == 4) {
      _profileKey.currentState?.refreshData();
    }
    _isProgrammaticChange = true;
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
    ).then((_) => _isProgrammaticChange = false);
  }

  void _onPageChanged(int index) {
    if (_isProgrammaticChange) return;
    if (index == 4) {
      _profileKey.currentState?.refreshData();
    }
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const ClampingScrollPhysics(),
        onPageChanged: _onPageChanged,
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTapped,
      ),
    );
  }
}

class _HomeView extends StatefulWidget {
  final Function(int)? onNavigateToTab;
  const _HomeView({this.onNavigateToTab});

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  Map<String, String>? _prayerTimes;
  String _nextPrayerName = 'Loading...';
  String _countdown = '00:00:00';
  String _locationName = 'Searching location...';
  bool _isLoading = false;
  String? _errorMessage;
  final Map<String, bool> _mutedPrayers = {};

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchPrayerTimes();
    });
    _timer = Timer.periodic(const Duration(seconds: 1), _updateCountdown);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchPrayerTimes() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _locationName = 'Locating...';
    });
    try {
      Position position = await _getGeoLocationPosition().timeout(const Duration(seconds: 15));
      await _getAddressFromLatLong(position).timeout(const Duration(seconds: 10));

      final response = await http.get(Uri.parse(
          'https://api.aladhan.com/v1/timings?latitude=${position.latitude}&longitude=${position.longitude}&method=11'))
          .timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timings = data['data']['timings'];
        if (mounted) {
          setState(() {
            _prayerTimes = {
              'Fajr': timings['Fajr'],
              'Dhuhr': timings['Dhuhr'],
              'Asr': timings['Asr'],
              'Maghrib': timings['Maghrib'],
              'Isha': timings['Isha'],
            };
            _isLoading = false;
            _errorMessage = null;
          });
          _updateCountdown(null);
        }
      } else {
        throw HttpException('Server returned ${response.statusCode}');
      }
    } on SocketException {
      debugPrint('No internet connection');
      _handleFetchError('No internet connection. Please check your network.');
    } on TimeoutException {
      debugPrint('Connection timed out');
      _handleFetchError('Connection timed out. Please try again.');
    } catch (e) {
      debugPrint('Failed to load prayer times: $e');
      _handleFetchError('Failed to load prayer times. Trying fallback...');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleFetchError(String message) {
    if (_prayerTimes == null) {
      setState(() {
        _errorMessage = message;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
        );
      }
    }
    
    if (_prayerTimes == null) {
      _fetchPrayerTimesByCity('Jakarta');
    }
  }

  Future<void> _fetchPrayerTimesByCity(String city) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
       final response = await http.get(Uri.parse(
          'https://api.aladhan.com/v1/timingsByCity?city=$city&country=Indonesia&method=11'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timings = data["data"]["timings"];
        if (mounted) {
          setState(() {
            _locationName = "$city, Indonesia";
            _prayerTimes = {
              "Fajr": timings["Fajr"],
              "Dhuhr": timings["Dhuhr"],
              "Asr": timings["Asr"],
              "Maghrib": timings["Maghrib"],
              "Isha": timings["Isha"],
            };
            _isLoading = false;
            _errorMessage = null;
          });
          _updateCountdown(null);
        }
      } else {
        throw HttpException('Server returned ${response.statusCode}');
      }
    } on SocketException {
      if (mounted) setState(() => _errorMessage = 'No internet connection. Using offline fallback if possible.');
    } catch (e) {
      debugPrint("Failed to load fallback prayer times: $e");
      if (mounted && _prayerTimes == null) {
        setState(() => _errorMessage = 'Failed to load prayer times. Check your connection.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<Position> _getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            insetPadding: EdgeInsets.only(
              left: 24, right: 24, top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).viewPadding.bottom + 24,
            ),
            title: const Text('Layanan Lokasi Mati', style: TextStyle(fontWeight: FontWeight.bold)),
            content: const Text('Harap aktifkan GPS/layanan lokasi untuk mendeteksi waktu sholat yang akurat di daerah Anda.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      if (mounted) {
        bool? allow = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            insetPadding: EdgeInsets.only(
              left: 24, right: 24, top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).viewPadding.bottom + 24,
            ),
            title: const Text('Izin Lokasi', style: TextStyle(fontWeight: FontWeight.bold)),
            content: const Text('Izinkan aplikasi mengakses lokasi Anda untuk menampilkan waktu sholat?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.primary),
                child: const Text('Lanjutkan'),
              ),
            ],
          ),
        );

        if (allow != true) {
          return Future.error('Location permissions are denied by user in dialog');
        }
      }

      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            insetPadding: EdgeInsets.only(
              left: 24, right: 24, top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).viewPadding.bottom + 24,
            ),
            title: const Text('Izin Lokasi Ditolak Permanen', style: TextStyle(fontWeight: FontWeight.bold)),
            content: const Text('Anda telah menolak izin lokasi secara permanen. Silakan izinkan akses lokasi melalui Pengaturan perangkat Anda.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    Position? position = await Geolocator.getLastKnownPosition();
    if (position != null) return position;
    
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
    );
  }

  Future<void> _getAddressFromLatLong(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String city = place.subAdministrativeArea ?? place.locality ?? place.administrativeArea ?? '';
        if (city.isEmpty) city = 'Unknown City';
        String country = place.country ?? '';
        setState(() {
          _locationName = "$city${country.isNotEmpty ? ', $country' : ''}";
        });
        return;
      }
    } catch (e) {
      debugPrint("Geocoding failed: $e, trying fallback.");
    }
    
    try {
      final response = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}'),
        headers: {'User-Agent': 'MuslimDailyApp'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['address'] != null) {
          final address = data['address'];
          String city = address['city'] ?? address['town'] ?? address['village'] ?? address['county'] ?? address['state'] ?? 'Unknown City';
          String country = address['country'] ?? '';
          setState(() {
            _locationName = "$city${country.isNotEmpty ? ', $country' : ''}";
          });
          return;
        }
      }
    } catch (e) {
      debugPrint("Nominatim fallback failed: $e");
    }

    setState(() {
      _locationName = "${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)}";
    });
  }

  void _updateCountdown(Timer? timer) {
    if (_prayerTimes == null) return;

    final now = DateTime.now();
    DateTime? nextTime;
    String nextName = '';

    for (var entry in _prayerTimes!.entries) {
      final parts = entry.value.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      final prayerTime = DateTime(now.year, now.month, now.day, hour, minute);
      
      if (prayerTime.isAfter(now)) {
        nextTime = prayerTime;
        nextName = entry.key;
        break;
      }
    }

    if (nextTime == null) {
       final fajrParts = _prayerTimes!['Fajr']!.split(':');
       nextTime = DateTime(now.year, now.month, now.day + 1, int.parse(fajrParts[0]), int.parse(fajrParts[1]));
       nextName = 'Fajr';
    }

    final diff = nextTime.difference(now);
    
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(diff.inHours);
    final minutes = twoDigits(diff.inMinutes.remainder(60));
    final seconds = twoDigits(diff.inSeconds.remainder(60));

    setState(() {
      _nextPrayerName = nextName;
      _countdown = '$hours:$minutes:$seconds';
    });
  }

  String _getTime12Hour(String time24) {
    final parts = time24.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final ampm = hour >= 12 ? 'PM' : 'AM';
    int hour12 = hour % 12;
    if (hour12 == 0) hour12 = 12;
    final minStr = minute.toString().padLeft(2, '0');
    return '$hour12:$minStr $ampm';
  }

  void _showMenuModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              border: Border(
                top: BorderSide(color: Color(0xFF1A1F2B), width: 3.5),
                left: BorderSide(color: Color(0xFF1A1F2B), width: 3.5),
                right: BorderSide(color: Color(0xFF1A1F2B), width: 3.5),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.home, color: Color(0xFF1A1F2B)),
                  title: Text('HOME', style: GoogleFonts.epilogue(fontWeight: FontWeight.w800)),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onNavigateToTab?.call(0);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.task_alt, color: Color(0xFF1A1F2B)),
                  title: Text('TASKS', style: GoogleFonts.epilogue(fontWeight: FontWeight.w800)),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onNavigateToTab?.call(1);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.favorite_border, color: Color(0xFF1A1F2B)),
                  title: Text('HABITS', style: GoogleFonts.epilogue(fontWeight: FontWeight.w800)),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onNavigateToTab?.call(2);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.emoji_events_outlined, color: Color(0xFF1A1F2B)),
                  title: Text('TROPHIES', style: GoogleFonts.epilogue(fontWeight: FontWeight.w800)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TrophyRoomPage()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person_outline, color: Color(0xFF1A1F2B)),
                  title: Text('PROFILE', style: GoogleFonts.epilogue(fontWeight: FontWeight.w800)),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onNavigateToTab?.call(3);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const darkColor = Color(0xFF1A1F2B);
    final accentColor = Theme.of(context).colorScheme.primary;
    
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- APP BAR ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                NeuButton(
                  onTap: _showMenuModal,
                  color: Colors.white,
                  padding: const EdgeInsets.all(8),
                  child: Image.asset('icon/main_icon/3_Menubar.webp', width: 24, height: 24),
                ),

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/logo/daypath_icon.svg',
                      width: 28,
                      height: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'DAYPATH',
                      style: GoogleFonts.epilogue(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: darkColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                NeuButton(
                  onTap: () => widget.onNavigateToTab?.call(3),
                  color: const Color(0xFFFFBA24), // Yellow
                  padding: const EdgeInsets.all(8),
                  child: Image.asset('icon/main_icon/User.webp', width: 24, height: 24),
                ),

              ],
            ),
            const SizedBox(height: 30),

            // --- NEXT PRAYER CARD ---
            Stack(
              children: [
                NeuBox(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                  borderRadius: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_nextPrayerName in',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6C757D),
                        ),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _countdown,
                          style: GoogleFonts.outfit(
                            fontSize: 68,
                            fontWeight: FontWeight.w800,
                            color: darkColor,
                            height: 1.0,
                            letterSpacing: -2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Image.asset(
                            'icon/main_icon/Location.webp',
                            width: 24, 
                            height: 24,
                            errorBuilder: (_, _, _) => Icon(Icons.location_on_outlined, color: accentColor, size: 24),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(
                              _locationName,
                              style: GoogleFonts.epilogue(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: darkColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: NeuButton(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Reminder set for $_nextPrayerName!'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: accentColor,
                              ),
                            );
                          },
                          color: accentColor,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          borderRadius: 12,
                          child: const Center(
                            child: Text(
                              'SET REMINDER',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: accentColor,
                      border: const Border(
                        bottom: BorderSide(color: darkColor, width: 3.5),
                        left: BorderSide(color: darkColor, width: 3.5),
                      ),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'NEXT PRAYER',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // --- TODAY'S SCHEDULE ---
            Text(
              'TODAY\'S SCHEDULE',
              style: GoogleFonts.epilogue(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: darkColor,
              ),
            ),
            const SizedBox(height: 16),

            if (_isLoading && _prayerTimes == null)
              Padding(
                padding: const EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator(color: accentColor)),
              )
            else if (_errorMessage != null && _prayerTimes == null)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.wifi_off_rounded, size: 48, color: Color(0xFF6C757D)),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!, 
                      textAlign: TextAlign.center, 
                      style: GoogleFonts.epilogue(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6C757D),
                      ),
                    ),
                    const SizedBox(height: 24),
                    NeuButton(
                      onTap: _fetchPrayerTimes,
                      color: accentColor,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      child: const Text(
                        'RETRY', 
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  ScheduleItem(
                    title: 'Fajr',
                    time: _getTime12Hour(_prayerTimes!['Fajr']!),
                    iconAsset: 'icon/main_icon/Fajr.webp',
                    iconBgColor: const Color(0xFFFF649C),
                    isActive: _nextPrayerName == 'Fajr',
                    isMuted: _mutedPrayers['Fajr'] ?? false,
                    onNotificationTap: () => setState(() => _mutedPrayers['Fajr'] = !(_mutedPrayers['Fajr'] ?? false)),
                  ),
                  const SizedBox(height: 12),
                  ScheduleItem(
                    title: 'Dhuhr',
                    time: _getTime12Hour(_prayerTimes!['Dhuhr']!),
                    iconAsset: 'icon/main_icon/Dhuhr.webp',
                    iconBgColor: Colors.white,
                    isActive: _nextPrayerName == 'Dhuhr',
                    isMuted: _mutedPrayers['Dhuhr'] ?? false,
                    onNotificationTap: () => setState(() => _mutedPrayers['Dhuhr'] = !(_mutedPrayers['Dhuhr'] ?? false)),
                  ),
                  const SizedBox(height: 12),
                  ScheduleItem(
                    title: 'Asr',
                    time: _getTime12Hour(_prayerTimes!['Asr']!),
                    iconAsset: 'icon/main_icon/Asr.webp',
                    iconBgColor: const Color(0xFFCCE4FF),
                    isActive: _nextPrayerName == 'Asr',
                    isMuted: _mutedPrayers['Asr'] ?? false,
                    onNotificationTap: () => setState(() => _mutedPrayers['Asr'] = !(_mutedPrayers['Asr'] ?? false)),
                  ),
                  const SizedBox(height: 12),
                  ScheduleItem(
                    title: 'Maghrib',
                    time: _getTime12Hour(_prayerTimes!['Maghrib']!),
                    iconAsset: 'icon/main_icon/Maghrib.webp',
                    iconBgColor: darkColor,
                    isActive: _nextPrayerName == 'Maghrib',
                    isMuted: _mutedPrayers['Maghrib'] ?? false,
                    onNotificationTap: () => setState(() => _mutedPrayers['Maghrib'] = !(_mutedPrayers['Maghrib'] ?? false)),
                    iconColor: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  ScheduleItem(
                    title: 'Isha',
                    time: _getTime12Hour(_prayerTimes!['Isha']!),
                    iconAsset: 'icon/main_icon/Maghrib.webp', 
                    iconBgColor: const Color(0xFF1A1F2B),
                    isActive: _nextPrayerName == 'Isha',
                    isMuted: _mutedPrayers['Isha'] ?? false,
                    onNotificationTap: () => setState(() => _mutedPrayers['Isha'] = !(_mutedPrayers['Isha'] ?? false)),
                    iconColor: Colors.white,
                  ),
                ],
              ),
            const SizedBox(height: 100), 
          ],
        ),
      ),
    );
  }
}

class ScheduleItem extends StatelessWidget {
  final String title;
  final String time;
  final String iconAsset;
  final Color iconBgColor;
  final bool isActive;
  final bool isMuted;
  final Color? iconColor;
  final VoidCallback? onNotificationTap;

  const ScheduleItem({
    super.key,
    required this.title,
    required this.time,
    required this.iconAsset,
    required this.iconBgColor,
    required this.isActive,
    required this.isMuted,
    this.iconColor,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    const darkColor = Color(0xFF1A1F2B);
    return NeuBox(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      backgroundColor: isActive ? const Color(0xFFFFBA24) : Colors.white,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: darkColor, width: 2),
            ),
            child: Image.asset(
              iconAsset,
              width: 20,
              height: 20,
              color: iconColor,
              errorBuilder: (_, _, _) => const Icon(Icons.wb_sunny_outlined, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: darkColor,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isActive ? darkColor : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onNotificationTap,
            child: Icon(
              isMuted ? Icons.notifications_off_outlined : Icons.notifications_active_outlined,
              color: isMuted ? Colors.grey[400] : darkColor,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomBottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav> {
  int _pressedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.primary;
    
    return SafeArea(
      child: Container(
        height: 84,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: NeuBox(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final tabWidth = constraints.maxWidth / 4;

              return Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.fastOutSlowIn,
                    left: widget.currentIndex * tabWidth,
                    top: 0,
                    bottom: 0,
                    width: tabWidth,
                    child: Center(
                      child: AnimatedScale(
                        scale: _pressedIndex == widget.currentIndex ? 0.90 : 1.0,
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeOut,
                        child: Container(
                          width: tabWidth - 12,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: accentColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF1A1F2B), width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1A1F2B),
                                offset: _pressedIndex == widget.currentIndex ? const Offset(0, 0) : const Offset(3, 3),
                                blurRadius: 0,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: _buildNavItem(0, 'HOME', 'icon/main_icon/Home_navbar.webp', Icons.home_filled)),
                      Expanded(child: _buildNavItem(1, 'TASKS', 'icon/main_icon/Task_navbar.webp', Icons.task_alt)),
                      Expanded(child: _buildNavItem(2, 'HABITS', 'icon/main_icon/Habits_navbar.webp', Icons.favorite)),
                      Expanded(child: _buildNavItem(3, 'PROFILE', 'icon/main_icon/Profile_navbar.webp', Icons.person)),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label, String iconAsset, IconData fallbackIcon) {
    final isActive = widget.currentIndex == index;
    final isPressed = _pressedIndex == index;
    final contentColor = isActive ? Colors.white : Colors.grey[500]!;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        setState(() => _pressedIndex = index);
        widget.onTap(index);
      },
      onTapUp: (_) => setState(() => _pressedIndex = -1),
      onTapCancel: () => setState(() => _pressedIndex = -1),
      child: Center(
        child: AnimatedScale(
          scale: isPressed ? 0.85 : (isActive ? 1.05 : 1.0),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child),
                ),
                child: Image.asset(
                  iconAsset,
                  key: ValueKey<bool>(isActive),
                  width: isActive ? 24 : 22,
                  height: isActive ? 24 : 22,
                  color: contentColor,
                  errorBuilder: (_, _, _) => Icon(fallbackIcon, size: isActive ? 24 : 22, color: contentColor),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: GoogleFonts.epilogue(
                  fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
                  fontSize: isActive ? 10 : 9,
                  color: contentColor,
                  letterSpacing: 0.3,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NeuButton extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final VoidCallback onTap;
  final double borderRadius;

  const NeuButton({
    super.key,
    required this.child,
    required this.onTap,
    this.padding = const EdgeInsets.all(12),
    this.color = Colors.white,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: NeuBox(
        padding: padding,
        backgroundColor: color,
        borderRadius: borderRadius,
        child: child,
      ),
    );
  }
}
