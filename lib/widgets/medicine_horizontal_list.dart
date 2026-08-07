import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/medicine.dart';
import '../../cards/medicine/medicine_card.dart';

class MedicineHorizontalList extends StatelessWidget {
  final List<MedicineModel> medicines;

  const MedicineHorizontalList({
    super.key,
    required this.medicines,
  });

  @override
  Widget build(BuildContext context) {
    if (medicines.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 260, // Height bound for the MedicineCard
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: medicines.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: SizedBox(
              width: 160, // Fixed width for the horizontal cards
              child: MedicineCard(
                medicine: medicines[index],
                onTap: () {
                  context.push('/medicine-details/${medicines[index].medicineId}', extra: medicines[index]);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
