
import 'package:flutter/material.dart';

import '../models/urun.dart';
import 'stok_rozeti.dart';

class UrunKarti extends StatelessWidget {
  final Urun urun;
  final VoidCallback onFavoriTiklandi;
  final VoidCallback onDetayTiklandi;

  const UrunKarti({
    super.key,
    required this.urun,
    required this.onFavoriTiklandi,
    required this.onDetayTiklandi,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onDetayTiklandi,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child:Image.network(
  urun.resimUrl,
  height: 90,
  width: 90,
  fit: BoxFit.cover,

  loadingBuilder: (context, child, progress) {
    if (progress == null) {
      return child;
    }

    return Container(
      width: 90,
      height: 90,
      color: Colors.grey.shade300,
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      ),
    );
  },

  errorBuilder: (context, error, stackTrace) {
    return Container(
      width: 90,
      height: 90,
      color: Colors.grey.shade300,
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.grey,
        ),
      ),
    );
  },
),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${urun.kategori.ikon} ${urun.kategori.baslik}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        StokRozeti(
                          stok: urun.stokAdedi,
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Text(
                      urun.baslik,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      urun.aciklama,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      '${urun.fiyat.toStringAsFixed(2)} ₺',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                icon: Icon(
                  urun.favoriMi
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: urun.favoriMi
                      ? Colors.red
                      : Colors.grey,
                ),
                onPressed: onFavoriTiklandi,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
