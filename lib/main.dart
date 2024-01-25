import 'package:flutter/material.dart';
import 'package:flutter_application_2/image_entity.dart';
import 'image_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ImagesListScreen(),
    );
  }
}

class ImagesListScreen extends StatefulWidget {
  const ImagesListScreen({super.key});

  @override
  State createState() => _ImagesListScreenState();
}

class _ImagesListScreenState extends State<ImagesListScreen> {
  final ImageService _imageService = ImageService();
  final ScrollController _scrollController = ScrollController();

  final _images = <ImageEntity>[];
  String? _continuationToken;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _fetchImages();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _fetchImages({String? continuationToken}) async {
    setState(() => _isLoadingMore = true);
    try {
      final result =
          await _imageService.fetchImages(continuationToken: continuationToken);
      setState(() {
        _images.addAll(result.$1);
        _continuationToken = result.$2;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }
      setState(() => _isLoadingMore = false);
    }
  }

  void _onScroll() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        _continuationToken != null &&
        !_isLoadingMore) {
      _fetchImages(continuationToken: _continuationToken);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Техническое задание'),
      ),
      body: GridView.builder(
        controller: _scrollController,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemCount: _images.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (BuildContext context, int index) {
          if (index >= _images.length) {
            return const Center(child: CircularProgressIndicator());
          } else {
            ImageEntity image = _images[index];
            ImageVariantEntity optimalVariant = _getOptimalVariant(
                image.variants, MediaQuery.of(context).size.width);
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImageScreen(image: image),
                  ),
                );
              },
              child: CachedNetworkImage(
                imageUrl: optimalVariant.url,
                fit: BoxFit.cover,
              ),
            );
          }
        },
      ),
    );
  }

  ImageVariantEntity _getOptimalVariant(
    List<ImageVariantEntity> variants,
    double displayWidth,
  ) {
    final widgetWidth = displayWidth / 3;
    final optimalVariant =
        variants.firstWhere((variant) => variant.width >= widgetWidth);
    return optimalVariant;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
}

class ImageScreen extends StatelessWidget {
  final ImageEntity image;

  const ImageScreen({Key? key, required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ImageVariantEntity optimalVariant =
        _getOptimalVariant(image.variants, MediaQuery.of(context).size.width);
    return Scaffold(
      appBar: AppBar(
        title: Text(image.id),
      ),
      body: InteractiveViewer(
        child: Center(
          child: CachedNetworkImage(
            imageUrl: optimalVariant.url,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  ImageVariantEntity _getOptimalVariant(
    List<ImageVariantEntity> variants,
    double displayWidth,
  ) {
    final widgetWidth = displayWidth;
    final optimalVariant =
        variants.firstWhere((variant) => variant.width >= widgetWidth);
    return optimalVariant;
  }
}
