import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vehicle_verified/owner_screens/dashboard/add_vehicle_screen.dart';
import 'package:vehicle_verified/owner_screens/dashboard/generate_qr_code_screen.dart';
import 'package:vehicle_verified/owner_screens/services/service_history_screen.dart';
import 'package:vehicle_verified/owner_screens/dashboard/vehicle_details_screen.dart';
import 'package:vehicle_verified/owner_screens/dashboard/view_doc_screen.dart';
import 'package:vehicle_verified/themes/color.dart';
import 'package:vehicle_verified/auth_screens/auth_selector_screen.dart';
import 'package:vehicle_verified/owner_screens/dashboard/add_edit_document_screen.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  // Firebase instances (Firebase version ke liye zaroori)
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // State variables
  String _userName = "User";
  List<Map<String, dynamic>> _vehicles = [];

  // --- START: MANUAL MOCK DATA FOR UI TESTING ---
  // Firebase se data fetch karne ke liye isey comment kar dein
  final String _mockUserName = "Suraj Kumar";
  // final List<Map<String, dynamic>> _mockVehicles = [
  //   {
  //     'id': 'mock_vehicle_1',
  //     'make': 'Honda',
  //     'model': 'Activa 6G',
  //     'registrationNumber': 'BR01AB1234',
  //     'image': 'assets/image/scooter.png',
  //     'status': 'All Documents Verified',
  //     'health': 'Good',
  //     'alerts': [
  //       {'type': 'Insurance Policy', 'expiry': 'Expires in 25 days'}
  //     ],
  //     'services': [
  //       {'name': 'General Service', 'date': '12 May 2024'}
  //     ]
  //   },
  //   {
  //     'id': 'mock_vehicle_2',
  //     'make': 'Maruti Suzuki',
  //     'model': 'Swift VXI',
  //     'registrationNumber': 'DL05CD5678',
  //     'image': 'assets/image/car_sedan.png',
  //     'status': 'PUC Expired',
  //     'health': 'Needs Attention',
  //     'alerts': [
  //       {'type': 'Pollution (PUC)', 'expiry': 'Expired 2 days ago'}
  //     ],
  //     'services': [
  //       {'name': 'AC Repair', 'date': '22 Jun 2024'}
  //     ]
  //   },
  //   {
  //     'id': 'mock_vehicle_2',
  //     'make': 'Maruti Suzuki',
  //     'model': 'Swift VXI',
  //     'registrationNumber': 'DL05CD5678',
  //     'image': 'assets/image/car_sedan.png',
  //     'status': 'PUC Expired',
  //     'health': 'Needs Attention',
  //     'alerts': [
  //       {'type': 'Pollution (PUC)', 'expiry': 'Expired 2 days ago'}
  //     ],
  //     'services': [
  //       {'name': 'AC Repair', 'date': '22 Jun 2024'}
  //     ]
  //   }
  // ];
  // --- END: MANUAL MOCK DATA ---

  // ---START : For fetch data from Firebase---

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists && mounted) {
        setState(() {
          _userName = userDoc.get('name') ?? "User";
        });
      }
    }
  }

  void _showUploadDocumentSheet(BuildContext context, Map<String, dynamic> vehicle) {
    final List<String> documentTypes = [
      'Registration Certificate (RC)',
      'Insurance Policy',
      'Pollution Under Control (PUC)',
      'Owner Manual',
      'Other Document'
    ];

    showModalBottomSheet(
      context: context,
      // Bottom sheet ke corners ko gol karne ke liye
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Content ke hisaab se height lega
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                'Select Document to Upload',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Documents ki list
              ListView.builder(
                shrinkWrap: true,
                itemCount: documentTypes.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(documentTypes[index]),
                    leading: const Icon(Icons.article_outlined),
                    onTap: () {
                      // Bottom sheet ko band karein
                      Navigator.of(context).pop();

                      // Upload screen par navigate karein
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddEditDocumentScreen(
                            documentType: documentTypes[index],
                            vehicleId: vehicle['id'],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showFeaturesBottomSheet(BuildContext context) {
    // ... (existing code remains the same)
  }

  @override
  Widget build(BuildContext context) {
    // --- START: MANUAL DATA USAGE ---
    // _userName = _mockUserName;
    // _vehicles = _mockVehicles;
    // final bool hasVehicles = _vehicles.isNotEmpty;
    //
    // return Scaffold(
    //   backgroundColor: AppColors.backgroundColorOwner,
    //   appBar: _buildAppBar(hasVehicles),
    //   body: hasVehicles
    //       ? DefaultTabController(
    //     length: _vehicles.length,
    //     child: _buildMainDashboard(),
    //   )
    //       : _buildInteractiveEmptyState(),
    //   floatingActionButton: hasVehicles
    //       ? Padding(
    //     padding: const EdgeInsets.only(bottom: 90.0),
    //     child: FloatingActionButton(
    //       onPressed: () {
    //         Navigator.push(
    //             context,
    //             MaterialPageRoute(
    //                 builder: (context) => const AddVehicleScreen()));
    //       },
    //       backgroundColor: AppColors.primaryColorOwner,
    //       child: const Icon(Icons.add, color: Colors.white),
    //       // label: const Text("", style: TextStyle(color: Colors.white)),
    //     ),
    //   )
    //       : null,
    // );
    // --- END: MANUAL DATA USAGE ---


    // --- START: FIREBASE DATA USAGE ---
    User? user = _auth.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text("User not logged in.")));
    }

    return StreamBuilder<QuerySnapshot>(
      stream:
      _firestore.collection('vehicles').where('ownerID', isEqualTo: user.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
              appBar: _buildAppBar(false),
              body: const Center(child: CircularProgressIndicator()));
        }

        final bool hasVehicles =
            snapshot.hasData && snapshot.data!.docs.isNotEmpty;

        if (hasVehicles) {
          _vehicles = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return data;
          }).toList();
        }

        return Scaffold(
          backgroundColor: AppColors.backgroundColorOwner,
          appBar: _buildAppBar(hasVehicles),
          body: hasVehicles
              ? DefaultTabController(
                  length: _vehicles.length,
                  child: _buildMainDashboard(),
                )
              : _buildInteractiveEmptyState(),
          floatingActionButton: hasVehicles
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 90.0),
                  child: FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AddVehicleScreen()));
                    },
                    backgroundColor: AppColors.primaryColorOwner,
                    child: const Icon(Icons.add, color: Colors.white),
                    // label: const Text("Add Vehicle", style: TextStyle(color: Colors.white)),
                  ),
                )
              : null,
        );
      },
    );
    // --- END: FIREBASE DATA USAGE ---
  }

  Widget _buildMainDashboard() {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverToBoxAdapter(child: _buildUserCard()),
          SliverPersistentHeader(
            delegate: _SliverTabBarDelegate(
              TabBar(
                isScrollable: true,
                indicatorColor: AppColors.primaryColorOwner,
                labelColor: AppColors.primaryColorOwner,
                unselectedLabelColor: Colors.grey.shade600,
                tabs: _vehicles.map((v) => Tab(text: v['model'])).toList(),
              ),
            ),
            pinned: true,
          ),
        ];
      },
      body: TabBarView(
        children: _vehicles.map((vehicle) {
          return _buildVehicleTabContent(vehicle);
        }).toList(),
      ),
    );
  }

  Widget _buildInteractiveEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 120.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildUserCard(),
          const SizedBox(height: 32),
          Text(
            'Welcome to Your Digital Garage!',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Start by adding your first vehicle to manage all your documents and services in one place.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const AddVehicleScreen()));
            },
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Add Your First Vehicle',
                style: TextStyle(color: Colors.white, fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColorOwner,
              padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 40),
          _buildFeatureShowcaseCard(
              Icons.shield_outlined,
              'Secure Document Wallet',
              'Upload and store your RC, Insurance, and PUC certificates safely.'),
          const SizedBox(height: 20),
          _buildFeatureShowcaseCard(
              Icons.qr_code_scanner,
              'Instant QR Verification',
              'Generate a unique QR code for your vehicle for quick verification by officials.'),
          const SizedBox(height: 20),
          _buildFeatureShowcaseCard(
              Icons.notifications_active_outlined,
              'Expiry Reminders',
              'Get timely alerts before your important documents expire.'),
          const SizedBox(height: 20),
          _buildFeatureShowcaseCard(
              Icons.miscellaneous_services_outlined,
              'Service Management',
              'Book vehicle services and keep a complete history of all maintenance.'),
        ],
      ),
    );
  }

  Widget _buildFeatureShowcaseCard(
      IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ]),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primaryColorOwner.withOpacity(0.1),
            child: Icon(icon, color: AppColors.primaryColorOwner, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade700)),
              ],
            ),
          )
        ],
      ),
    );
  }

  AppBar _buildAppBar(bool hasVehicles) {
    final String firstName = _userName.split(' ').first;
    return AppBar(
      title: Text('$firstName\'s Digital Garage',
          style: const TextStyle(color: Colors.white)),
      backgroundColor: AppColors.primaryColorOwner,
      elevation: 0,
      actions: [
        if (hasVehicles)
          IconButton(
            icon: const Icon(Icons.widgets_outlined, color: Colors.white),
            tooltip: 'Quick Actions',
            onPressed: () => _showFeaturesBottomSheet(context),
          ),
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
          },
        ),
      ],
    );
  }

  Widget _buildUserCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [AppColors.primaryColorOwner, Colors.blueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _userName,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                '${_vehicles.length} vehicles registered',
                style: TextStyle(color: Colors.white.withOpacity(0.8)),
              ),
            ],
          ),
          const CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage('assets/image/avatar.png'),
          )
        ],
      ),
    );
  }

  Widget _buildVehicleTabContent(Map<String, dynamic> vehicle) {
    List<Map<String, String>> alerts =
    List<Map<String, String>>.from(vehicle['alerts'] ?? []);
    List<Map<String, String>> services =
    List<Map<String, String>>.from(vehicle['services'] ?? []);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 120.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2)
              ],
            ),
            child: Row(
              children: [
                Image.asset(vehicle['image'] ?? 'assets/image/car_sedan.png',
                    height: 80),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${vehicle['make']} ${vehicle['model']}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(vehicle['registrationNumber'] ?? 'N/A',
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 16)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (vehicle['status'] ?? '').contains('expiring')
                              ? Colors.orange.withOpacity(0.2)
                              : Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          vehicle['status'] ?? 'Status unknown',
                          style: TextStyle(
                            color: (vehicle['status'] ?? '')
                                .contains('expiring')
                                ? Colors.orange.shade800
                                : Colors.green.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.9,
            children: [
              _buildActionChip('View Details', Icons.article_outlined, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            VehicleDetailsScreen(vehicle: vehicle)));
              }),
              _buildActionChip('Get QR Code', Icons.qr_code_2, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GenerateQrCodeScreen(
                            vehicle: vehicle.cast<String, String>())));
              }),
              _buildActionChip('Documents', Icons.folder_copy_outlined, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ViewAllDocumentsScreen()));
              }),
              _buildActionChip('Upload Doc', Icons.upload_file_outlined, () {
                _showUploadDocumentSheet(context, vehicle);
              }),
              _buildActionChip('Service History', Icons.history, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ServiceHistoryScreen()));
              }),
              _buildActionChip(
                  'Vehicle Health', Icons.health_and_safety_outlined, () {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Vehicle Health'),
                      content: Text('Current Status: ${vehicle['health']}'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('OK'))
                      ],
                    ));
              }),
            ],
          ),
          const SizedBox(height: 32),
          if (alerts.isNotEmpty) ...[
            _buildSectionHeader('Urgent Alerts'),
            const SizedBox(height: 12),
            ...alerts.map((alert) => _buildAlertCard(alert)).toList(),
            const SizedBox(height: 32),
          ],
          if (services.isNotEmpty) ...[
            _buildSectionHeader('Recent Services'),
            const SizedBox(height: 12),
            ...services.map((service) => _buildServiceHistoryCard(service)).toList(),
          ]
        ],
      ),
    );
  }

  Widget _buildActionChip(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 2)
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primaryColorOwner, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildAlertCard(Map<String, String> alert) {
    return Card(
      elevation: 2,
      shadowColor: Colors.orange.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
        title: Text(alert['type']!,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle:
        Text(alert['expiry']!, style: TextStyle(color: Colors.grey.shade600)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }

  Widget _buildServiceHistoryCard(Map<String, String> service) {
    return Card(
      elevation: 2,
      shadowColor: Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading:
        const Icon(Icons.receipt_long, color: AppColors.primaryColorOwner),
        title: Text(service['name']!,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle:
        Text(service['date']!, style: TextStyle(color: Colors.grey.shade600)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }

  Widget _buildBottomSheetAction(
      String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey.shade200,
            child: Icon(icon, color: AppColors.primaryColorOwner, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate(this._tabBar);
  final TabBar _tabBar;
  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.backgroundColorOwner,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
