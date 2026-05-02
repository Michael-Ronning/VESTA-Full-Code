class ResultsContent extends StatelessWidget {
  final VestaAssessmentResult result;

  const ResultsContent({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1A1A2E),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // move ALL your _build methods content here
        ],
      ),
    );
  }
}
