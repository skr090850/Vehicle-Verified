import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // --- MOCK DATA ---
  final String _userName = "Suraj Kumar";
  final List<Map<String, dynamic>> _vehicles = [
    {
      'id': 'doc_id_honda_activa_123',
      'make': 'Honda',
      'model': 'Activa',
      'number': 'DL01AB1234',
      'image': 'assets/image/scooter.png',
      'status': 'All documents valid',
      'expiry': 'Next expiry in 8 months',
      'health': 'Good', // New field
      'alerts': [],
      'services': [
        {'name': 'General Service', 'date': '15 Jun 2024'},
        {'name': 'Oil Change', 'date': '18 Dec 2023'},
      ]
    },
    {
      'id': 'doc_id_maruti_swift_456',
      'make': 'Maruti Suzuki',
      'model': 'Swift',
      'number': 'BR01CD5678',
      'image': 'assets/image/car_sedan.png',
      'status': 'Insurance expiring soon',
      'expiry': 'Expires in 15 days',
      'health': 'Needs Checkup', // New field
      'alerts': [
        {'type': 'Insurance Policy', 'expiry': 'Expires in 15 days'},
      ],
      'services': [
        {'name': 'AC Gas Refill', 'date': '02 Apr 2024'},
        {'name': 'Insurance Renewed', 'date': '20 Jan 2024'},
      ]
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _vehicles.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // New function to show document upload options
  void _showUploadDocumentDialog(BuildContext context, Map<String, dynamic> vehicle) {
    final List<String> documentTypes = [
      'Registration Certificate (RC)',
      'Insurance Policy',
      'Pollution Under Control (PUC)',
      "Owner's Manual",
      'Other'
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Upload document for ${vehicle['model']}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ...documentTypes.map((type) => ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(type),
                  onTap: () {
                    Navigator.of(context).pop(); // Close the bottom sheet
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddEditDocumentScreen(documentType: type),
                      ),
                    );
                  },
                )).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColorOwner,
      appBar: _buildAppBar(),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: FloatingActionButton(
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AddVehicleScreen()));
          },
          backgroundColor: AppColors.primaryColorOwner,
          child: const Icon(Icons.add, color: Colors.white),
          tooltip: 'Add Vehicle',
        ),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(child: _buildUserCard()),
            SliverPersistentHeader(
              delegate: _SliverTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: AppColors.primaryColorOwner,
                  labelColor: AppColors.primaryColorOwner,
                  unselectedLabelColor: Colors.grey.shade600,
                  tabs: _vehicles
                      .map((v) => Tab(text: v['model']))
                      .toList(),
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: _vehicles.map((vehicle) {
            return _buildVehicleTabContent(vehicle);
          }).toList(),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    // Extracting the first name for a more personal touch
    final String firstName = _userName.split(' ').first;
    return AppBar(
      title: Text('$firstName\'s Digital Garage', style: const TextStyle(color: Colors.white)),
      backgroundColor: AppColors.primaryColorOwner,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline, color: Colors.white),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AddVehicleScreen()));
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: AppColors.textPrimary),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            // Navigate to the initial screen and clear the navigation stack.
            // Navigator.of(context).pushAndRemoveUntil(
            //   MaterialPageRoute(builder: (context) => const AuthSelectorScreen()),
            //       (Route<dynamic> route) => false,
            // );
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
    List<Map<String, String>> alerts = List<Map<String, String>>.from(vehicle['alerts'] ?? []);
    List<Map<String, String>> services = List<Map<String, String>>.from(vehicle['services'] ?? []);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
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
                Image.asset(vehicle['image'], height: 80),
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
                      Text(vehicle['number'],
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 16)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: vehicle['status']!.contains('expiring')
                              ? Colors.orange.withOpacity(0.2)
                              : Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          vehicle['status']!,
                          style: TextStyle(
                            color: vehicle['status']!.contains('expiring')
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
            childAspectRatio: 0.9, // Adjusted for better text wrapping
            children: [
              _buildActionChip('View Details', Icons.article_outlined, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => VehicleDetailsScreen(vehicle: vehicle)));
              }),
              _buildActionChip('Get QR Code', Icons.qr_code_2, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => GenerateQrCodeScreen(vehicle: vehicle.cast<String, String>())));
              }),
              _buildActionChip('Documents', Icons.folder_copy_outlined, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ViewAllDocumentsScreen()));
              }),
              _buildActionChip('Upload Doc', Icons.upload_file_outlined, () {
                _showUploadDocumentDialog(context, vehicle);
              }),
              _buildActionChip('Service History', Icons.history, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ServiceHistoryScreen()));
              }),
              _buildActionChip('Vehicle Health', Icons.health_and_safety_outlined, () {
                // Show a simple dialog for vehicle health
                showDialog(context: context, builder: (context) => AlertDialog(
                  title: const Text('Vehicle Health'),
                  content: Text('Current Status: ${vehicle['health']}'),
                  actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
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
        title: Text(alert['type']!, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(alert['expiry']!, style: TextStyle(color: Colors.grey.shade600)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () { /* Navigate to document details */ },
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
        leading: const Icon(Icons.receipt_long, color: AppColors.primaryColorOwner),
        title: Text(service['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(service['date']!, style: TextStyle(color: Colors.grey.shade600)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () { /* Navigate to service history details */ },
      ),
    );
  }
}

// Helper class to make the TabBar stick to the top while scrolling
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
