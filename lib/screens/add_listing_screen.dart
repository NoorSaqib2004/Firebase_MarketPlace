import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test_demo_firebase/models/listing_model.dart';
import 'package:test_demo_firebase/services/listing_service.dart';
import 'package:test_demo_firebase/services/storage_service.dart';

class AddListingScreen extends StatefulWidget {
  const AddListingScreen({Key? key}) : super(key: key);

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _price = TextEditingController();
  final ListingService _listingService = ListingService();
  final StorageService _storage = StorageService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<File> _images = [];
  List<String> _existingImages = [];
  bool _saving = false;
  String _selectedCategory = 'Electronics';
  ListingModel? _editingListing;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is ListingModel && _editingListing == null) {
      _editingListing = args;
      _title.text = args.title;
      _description.text = args.description;
      _price.text = args.price.toString();
      _selectedCategory = args.category;
      _existingImages = List.from(args.images);
    }
  }

  static const List<String> categories = [
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

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _images.add(File(picked.path)));
    }
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a title')));
      return;
    }
    if (_price.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a price')));
      return;
    }

    setState(() => _saving = true);
    try {
      final isEditing = _editingListing != null;
      final id = isEditing
          ? _editingListing!.listingId
          : DateTime.now().millisecondsSinceEpoch.toString();

      // Upload new images if any
      List<String> urls = List.from(_existingImages);
      if (_images.isNotEmpty) {
        final newUrls = await _storage.uploadListingImages(id, _images);
        urls.addAll(newUrls);
      }

      final currentUser = _auth.currentUser;
      final userId = currentUser?.uid ?? 'unknown';
      final userName =
          currentUser?.displayName ?? currentUser?.email ?? 'Seller';
      final userEmail = currentUser?.email ?? '';

      final listing = ListingModel(
        listingId: id,
        title: _title.text.trim(),
        description: _description.text.trim(),
        price: double.tryParse(_price.text.trim()) ?? 0.0,
        images: urls,
        category: _selectedCategory,
        ownerId: userId,
        sellerName: userName,
        sellerEmail: userEmail,
        createdAt: _editingListing?.createdAt,
        status: 'active',
      );

      if (isEditing) {
        await _listingService.updateListing(listing);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Listing updated successfully')),
          );
        }
      } else {
        await _listingService.createListing(listing);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _editingListing != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Listing' : 'Add Listing')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _price,
                decoration: const InputDecoration(
                  labelText: 'Price (RS)',
                  hintText: 'e.g., 5000',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
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
                  if (newValue != null) {
                    setState(() => _selectedCategory = newValue);
                  }
                },
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [
                  ..._images.map(
                    (f) => Stack(
                      children: [
                        Image.file(f, width: 72, height: 72, fit: BoxFit.cover),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _images.remove(f));
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.add_a_photo),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Listing'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _price.dispose();
    super.dispose();
  }
}
