class Concert {
  final String artistName;
  final String venue;
  final String date;
  final String imagePath;
  final double ticketPrice;
  final bool isTrending;

  Concert({
    required this.artistName,
    required this.venue,
    required this.date,
    required this.imagePath,
    required this.ticketPrice,
    this.isTrending = false,
  });
}