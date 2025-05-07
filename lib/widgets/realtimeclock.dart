import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RealtimeClock extends StatelessWidget {
  const RealtimeClock({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      stream: Stream.periodic(
        const Duration(seconds: 1),
        (_) => DateTime.now(),
      ),
      builder: (context, snapshot) {
        final time = snapshot.data ?? DateTime.now();
        final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
        final period = time.hour >= 12 ? 'PM' : 'AM';

        return Semantics(
          label: 'Realtime Clock',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}',
                style: GoogleFonts.robotoMono(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff4C2B08),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                period,
                style: GoogleFonts.robotoMono(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff4C2B08),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
