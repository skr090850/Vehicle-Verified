import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<User?>? _authSubscription;

  String _userName = "User";
  List<Map<String, dynamic>> _vehicles = [];

  @override
  void initState() {
    super.initState();
    _authSubscription = _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const AuthSelectorScreen()),
                (Route<dynamic> route) => false,
          );
        }
      } else {
        _fetchUserData();
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
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

  Future<void> _handleDocumentUpload(
      String selectedDocType, Map<String, dynamic> vehicle) async {
    if (!mounted) return;
    Navigator.of(context).pop();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final querySnapshot = await _firestore
          .collection('vehicles')
          .doc(vehicle['id'])
          .collection('documents')
          .where('documentType', isEqualTo: selectedDocType)
          .limit(1)
          .get();

      if (mounted) Navigator.of(context).pop();

      if (querySnapshot.docs.isNotEmpty) {
        final existingDocId = querySnapshot.docs.first.id;
        final bool? shouldReplace = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Replace Document?'),
              content: Text(
                  "A document for '$selectedDocType' already exists. Do you want to replace it?"),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Replace'),
                ),
              ],
            );
          },
        );

        if (shouldReplace == true && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditDocumentScreen(
                documentType: selectedDocType,
                vehicleId: vehicle['id'],
                documentId: existingDocId,
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditDocumentScreen(
                documentType: selectedDocType,
                vehicleId: vehicle['id'],
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error checking document: $e")),
        );
      }
    }
  }

  // --- START: CORRECTED NOTIFICATION LOGIC ---
  Stream<int> _getPendingConfirmationsCountStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(0);

    return _firestore
        .collectionGroup('serviceHistory')
        .where('status', isEqualTo: 'Booked')
        .snapshots()
        .asyncMap((snapshot) async {
      int count = 0;
      for (var doc in snapshot.docs) {
        try {
          final vehicleRef = doc.reference.parent.parent;
          if (vehicleRef != null) {
            final vehicleDoc = await vehicleRef.get();
            if (vehicleDoc.exists && vehicleDoc.data()?['ownerID'] == user.uid) {
              final serviceDate = (doc.data()['serviceDate'] as Timestamp?)?.toDate();
              if (serviceDate != null && serviceDate.isBefore(DateTime.now())) {
                count++;
              }
            }
          }
        } catch (e) {
          // Handle potential errors, e.g., permission issues
          print("Error checking notification: $e");
        }
      }
      return count;
    });
  }

  void _showNotificationsDialog() {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const ServiceHistoryScreen()));
  }
  // --- END: CORRECTED NOTIFICATION LOGIC ---

  void _showUploadDocumentSheet(
      BuildContext context, Map<String, dynamic> vehicle) {
    final List<String> documentTypes = [
      'Registration Certificate (RC)',
      'Insurance Policy',
      'Pollution Under Control (PUC)',
      'Owner Manual',
      'Other Document'
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Document to Upload',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                itemCount: documentTypes.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(documentTypes[index]),
                    leading: const Icon(Icons.article_outlined),
                    onTap: () {
                      _handleDocumentUpload(documentTypes[index], vehicle);
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

  Widget _buildVehicleStatusWidget(Map<String, dynamic> vehicle) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('vehicles')
          .doc(vehicle['id'])
          .collection('documents')
          .snapshots(),
      builder: (context, docSnapshot) {
        if (docSnapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 10,
            width: 10,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }

        final documents = docSnapshot.data?.docs ?? [];
        MaterialColor statusColor = Colors.grey;
        String statusText = 'Documents Pending';

        if (documents.isEmpty) {
          statusText = 'Documents Missing';
          statusColor = Colors.red;
        } else {
          bool allVerified = true;
          String expiringSoonDoc = '';
          String expiredDoc = '';

          for (var doc in documents) {
            final data = doc.data() as Map<String, dynamic>;
            final Timestamp? expiryTimestamp = data['expiryDate'];
            if (expiryTimestamp != null) {
              final expiryDate = expiryTimestamp.toDate();
              if (expiryDate.isBefore(DateTime.now())) {
                allVerified = false;
                expiredDoc = data['documentType'] ?? 'Document';
                break;
              }
              if (expiryDate
                  .isBefore(DateTime.now().add(const Duration(days: 30)))) {
                allVerified = false;
                expiringSoonDoc = data['documentType'] ?? 'Document';
              }
            }
          }

          if (expiredDoc.isNotEmpty) {
            statusText = '$expiredDoc Expired';
            statusColor = Colors.red;
          } else if (expiringSoonDoc.isNotEmpty) {
            statusText = '$expiringSoonDoc Expiring';
            statusColor = Colors.orange;
          } else if (allVerified) {
            var docTypes =
            documents.map((d) => (d.data() as Map)['documentType']).toSet();
            if (docTypes.contains('Insurance Policy') &&
                docTypes.contains('Pollution Under Control (PUC)')) {
              statusText = 'All Documents Verified';
              statusColor = Colors.green;
            } else {
              statusText = 'Essential Docs Missing';
              statusColor = Colors.orange;
            }
          } else {
            statusText = 'Documents Pending';
            statusColor = Colors.blue;
          }
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            statusText,
            style: TextStyle(
              color: statusColor.shade800,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('vehicles')
          .where('ownerID', isEqualTo: user.uid)
          .snapshots(),
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
            ),
          )
              : null,
        );
      },
    );
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
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddVehicleScreen()));
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
          StreamBuilder<int>(
            stream: _getPendingConfirmationsCountStream(),
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              final hasNotifications = count > 0;

              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none,
                        color: Colors.white),
                    onPressed: () {
                      if (hasNotifications) {
                        _showNotificationsDialog();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("No pending notifications."),
                              duration: Duration(seconds: 2)),
                        );
                      }
                    },
                  ),
                  if (hasNotifications)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userName,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${_vehicles.length} vehicle${_vehicles.length == 1 ? '' : 's'} registered',
                  style: TextStyle(color: Colors.white.withOpacity(0.8)),
                ),
              ],
            ),
          ),
          const CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage('assets/image/avatar.png'),
          )
        ],
      ),
    );
  }

  // --- START: UPDATED VEHICLE TAB CONTENT ---
  Widget _buildVehicleTabContent(Map<String, dynamic> vehicle) {
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
                    height: 80,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.directions_car, size: 80)),
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
                      _buildVehicleStatusWidget(vehicle),
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
                        builder: (context) =>
                            GenerateQrCodeScreen(vehicle: vehicle)));
              }),
              _buildActionChip('Documents', Icons.folder_copy_outlined, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ViewAllDocumentsScreen(vehicle: vehicle),
                  ),
                );
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
          // Dynamic sections added here
          _buildUrgentAlertsSection(vehicle['id']),
          const SizedBox(height: 32),
          _buildRecentServicesSection(vehicle['id']),
        ],
      ),
    );
  }
  // --- END: UPDATED VEHICLE TAB CONTENT ---

  // --- START: NEW DYNAMIC SECTIONS ---
  Widget _buildUrgentAlertsSection(String vehicleId) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('vehicles')
          .doc(vehicleId)
          .collection('documents')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final now = DateTime.now();
        final alerts = <Map<String, String>>[];

        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final expiryTimestamp = data['expiryDate'] as Timestamp?;
          if (expiryTimestamp != null) {
            final expiryDate = expiryTimestamp.toDate();
            final docType = data['documentType'] ?? 'Document';

            if (expiryDate.isBefore(now)) {
              alerts.add({
                'type': '$docType Expired',
                'expiry': 'Expired on ${DateFormat.yMMMd().format(expiryDate)}',
                'level': 'expired',
              });
            } else if (expiryDate
                .isBefore(now.add(const Duration(days: 30)))) {
              alerts.add({
                'type': '$docType Expiring Soon',
                'expiry':
                'Expires on ${DateFormat.yMMMd().format(expiryDate)}',
                'level': 'expiring',
              });
            }
          }
        }

        if (alerts.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Urgent Alerts'),
            const SizedBox(height: 12),
            ...alerts.map((alert) => _buildAlertCard(alert)).toList(),
          ],
        );
      },
    );
  }

  Widget _buildRecentServicesSection(String vehicleId) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('vehicles')
          .doc(vehicleId)
          .collection('serviceHistory')
          .orderBy('serviceDate', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final services = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Recent Services'),
            const SizedBox(height: 12),
            ...services.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final serviceDate = (data['serviceDate'] as Timestamp).toDate();
              return _buildServiceHistoryCard({
                'name': data['serviceType'] ?? 'Service',
                'date': DateFormat.yMMMd().format(serviceDate),
              });
            }).toList(),
          ],
        );
      },
    );
  }
  // --- END: NEW DYNAMIC SECTIONS ---

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
    final bool isExpired = alert['level'] == 'expired';
    return Card(
      elevation: 2,
      shadowColor: (isExpired ? Colors.red : Colors.orange).withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(Icons.warning_amber_rounded,
            color: isExpired ? Colors.red : Colors.orange),
        title: Text(alert['type']!,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle:
        Text(alert['expiry']!, style: TextStyle(color: Colors.grey.shade600)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Navigate to documents screen or specific document
        },
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
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ServiceHistoryScreen()));
        },
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
