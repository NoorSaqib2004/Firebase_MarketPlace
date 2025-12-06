import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_demo_firebase/models/listing_model.dart';
import 'package:test_demo_firebase/models/chat_model.dart';
import 'package:test_demo_firebase/services/listing_service.dart';
import 'package:test_demo_firebase/services/chat_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ListingService _service = ListingService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _selectedCategory = 'All';
  String _selectedPriceRange = 'All';
  int _selectedTabIndex = 0;

  static const List<String> categories = [
    'All',
    'Electronics',
    'Clothing',
    'Furniture',
    'Books',
    'Sports',
    'Toys',
    'Home & Garden',
    'Vehicle',
    'Other',
  ];

  static const List<String> priceRanges = [
    'All',
    'RS0-50,000',
    'RS50,000-100,000',
    'RS100,000-150,000',
    'RS150,000-200,000',
    'RS200,000-300,000',
    'RS300,000-500,000',
    'RS500,000+',
  ];

  bool _isPriceInRange(double price, String range) {
    if (range == 'All') return true;
    if (range == 'RS0-50,000') return price >= 0 && price <= 50000;
    if (range == 'RS50,000-100,000') return price > 50000 && price <= 100000;
    if (range == 'RS100,000-150,000') return price > 100000 && price <= 150000;
    if (range == 'RS150,000-200,000') return price > 150000 && price <= 200000;
    if (range == 'RS200,000-300,000') return price > 200000 && price <= 300000;
    if (range == 'RS300,000-500,000') return price > 300000 && price <= 500000;
    if (range == 'RS500,000+') return price > 500000;
    return true;
  }

  List<ListingModel> _filterListings(List<ListingModel> listings) {
    final currentUserId = _auth.currentUser?.uid ?? '';
    return listings.where((l) {
      final categoryMatch =
          _selectedCategory == 'All' || l.category == _selectedCategory;
      final priceMatch = _isPriceInRange(l.price, _selectedPriceRange);
      final notOwnListing = l.ownerId != currentUserId;
      return categoryMatch && priceMatch && notOwnListing;
    }).toList();
  }

  List<ListingModel> _getMyListings(List<ListingModel> listings) {
    final currentUserId = _auth.currentUser?.uid ?? '';
    return listings.where((l) => l.ownerId == currentUserId).toList();
  }

  Future<void> _deleteListing(ListingModel listing) async {
    try {
      await _service.deleteListing(listing.listingId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting listing: $e')));
      }
    }
  }

  Future<void> _editListing(ListingModel listing) async {
    final result = await Navigator.of(
      context,
    ).pushNamed('/add', arguments: listing);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Marketplace'), elevation: 0),
      body: StreamBuilder<List<ListingModel>>(
        stream: _service.fetchListings(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final listings = snapshot.data!;
          final filtered = _filterListings(listings);
          final myListings = _getMyListings(listings);

          return Column(
            children: [
              // Tab Navigation
              Container(
                color: Colors.grey.shade100,
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTabIndex = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: _selectedTabIndex == 0
                                    ? Colors.blue
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'Browse',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTabIndex = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: _selectedTabIndex == 1
                                    ? Colors.blue
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'My Listings',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTabIndex = 2),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: _selectedTabIndex == 2
                                    ? Colors.blue
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'Messages',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _selectedTabIndex == 0
                    ? _buildBrowseTab(filtered)
                    : _selectedTabIndex == 1
                    ? _buildMyListingsTab(myListings)
                    : _buildMessagesTab(),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _selectedTabIndex == 1
          ? FloatingActionButton(
              onPressed: () => Navigator.of(context).pushNamed('/add'),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildBrowseTab(List<ListingModel> filtered) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Category:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              DropdownButton<String>(
                value: _selectedCategory,
                isExpanded: true,
                items: categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null)
                    setState(() => _selectedCategory = newValue);
                },
              ),
              const SizedBox(height: 12),
              const Text(
                'Price Range:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              DropdownButton<String>(
                value: _selectedPriceRange,
                isExpanded: true,
                items: priceRanges.map((String range) {
                  return DropdownMenuItem<String>(
                    value: range,
                    child: Text(range),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null)
                    setState(() => _selectedPriceRange = newValue);
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('No listings match filters'))
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final l = filtered[index];
                    return ListTile(
                      leading: l.images.isNotEmpty
                          ? Image.network(
                              l.images.first,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                            )
                          : const SizedBox(width: 56, height: 56),
                      title: Text(l.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('RS${l.price.toStringAsFixed(0)}'),
                          Text(
                            l.sellerName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                            ),
                          ),
                          Text(
                            l.category,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      onTap: () => Navigator.of(
                        context,
                      ).pushNamed('/listing', arguments: l),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMyListingsTab(List<ListingModel> myListings) {
    return myListings.isEmpty
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text('No listings yet', style: TextStyle(color: Colors.grey)),
              ],
            ),
          )
        : ListView.builder(
            itemCount: myListings.length,
            itemBuilder: (context, index) {
              final l = myListings[index];
              return ListTile(
                leading: l.images.isNotEmpty
                    ? Image.network(
                        l.images.first,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      )
                    : const SizedBox(width: 56, height: 56),
                title: Text(l.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('RS${l.price.toStringAsFixed(0)}'),
                    Text(l.category, style: const TextStyle(fontSize: 12)),
                  ],
                ),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      onTap: () => _editListing(l),
                      child: const Text('Edit'),
                    ),
                    PopupMenuItem(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Listing'),
                            content: const Text(
                              'Are you sure you want to delete this listing?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _deleteListing(l);
                                },
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                ),
                onTap: () =>
                    Navigator.of(context).pushNamed('/listing', arguments: l),
              );
            },
          );
  }

  Widget _buildMessagesTab() {
    final currentUserId = _auth.currentUser?.uid ?? '';
    final _chatService = ChatService();

    return StreamBuilder<List<ChatModel>>(
      stream: _chatService.getUserChats(currentUserId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final chats = snapshot.data ?? [];
        if (chats.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No messages yet',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Contact sellers or wait for buyer messages',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index];

            return ListTile(
              title: Text('Chat - Listing ${chat.listingId}'),
              subtitle: Text(
                chat.lastMessage.isEmpty ? 'No messages yet' : chat.lastMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(
                chat.updatedAt?.toDate().toString().split(' ')[0] ?? '',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              onTap: () {
                Navigator.of(context).pushNamed('/chat', arguments: chat);
              },
            );
          },
        );
      },
    );
  }
}
