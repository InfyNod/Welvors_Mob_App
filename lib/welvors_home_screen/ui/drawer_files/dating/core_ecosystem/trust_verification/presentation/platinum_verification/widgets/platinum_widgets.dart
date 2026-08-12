import '../../../export.dart';
import '../bloc/platinum_verification_bloc.dart';
import '../bloc/platinum_verification_event.dart';
import '../bloc/platinum_verification_state.dart';
import 'package:dotted_border/dotted_border.dart';
// --------------------------------------------------
// APP BAR
// --------------------------------------------------

class PlatinumAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? trailing;
  final bool? action;
  final VoidCallback? onBack;

  const PlatinumAppBar({
    super.key,
    required this.title,
    this.trailing,
    this.action,
    this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.white,

      // leading: IconButton(
      //   onPressed: onBack ?? () => Navigator.maybePop(context),
      //   icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 24),
      // ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
        child: InkWell(
          onTap: onBack ?? () => Navigator.maybePop(context),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black87,
              size: 16,
            ),
          ),
        ),
      ),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Mycolor.text,
        ),
      ),
      centerTitle: true,
      actions: [
        if (action == true &&
            title != "Criminal Background Check" &&
            trailing != null)
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Mycolor.pinkLight,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              trailing!,
              style: const TextStyle(
                color: Mycolor.pink,
                fontWeight: FontWeight.w800,
                fontSize: 10,
              ),
            ),
          )
        else
          const SizedBox(width: 52),
      ],
    );
  }
}

// --------------------------------------------------
// HERO CARD
// --------------------------------------------------

class PlatinumHeroCard extends StatelessWidget {
  const PlatinumHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Mycolor.color1d1833, Mycolor.color292342],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.shield_outlined, color: Colors.white, size: 30),
              _Pill(text: '👑 PLATINUM'),
            ],
          ),

          hSized10,

          Text(
            'Unlock Platinum Trust',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),

          SizedBox(height: 8),

          Text(
            'One-time fee · Lifetime badge · Maximum credibility',
            style: TextStyle(color: Color(0xFFB7B0C1), fontSize: 12),
          ),

          hSized10,

          Text(
            '₹500',
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w800,
            ),
          ),

          Text(
            'One-time payment · No subscription',
            style: TextStyle(
              color: Color(0xFFB7B0C1),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 22),

          _Bullet(text: 'Criminal Background Check (Court records)'),

          _Bullet(text: 'Emergency Contact Registration'),

          _Bullet(text: 'Income Verification (Bracket only)'),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;

  const _Pill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Mycolor.yellow,
        gradient: const LinearGradient(
          colors: [Mycolor.colorfbd064, Mycolor.coloredb147],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          color: Color(0xFF5F4814),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;

  const _Bullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Icon(Icons.circle, size: 11, color: Mycolor.pink),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------
// BENEFITS
// --------------------------------------------------

class PlatinumBenefitsCard extends StatelessWidget {
  const PlatinumBenefitsCard({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      (
        '🤝',
        'Platinum badge on your profile',
        'Instantly visible to all potential matches — signals maximum seriousness',
      ),
      (
        '📈',
        '3× more matches from serious users',
        'Platinum users match significantly faster with quality profiles',
      ),
      (
        '🔒',
        'Exclusive Platinum-only features',
        'Access Forever Love Programme and Exclusively Dating features',
      ),
      (
        '♾️',
        'Lifetime verification — never expires',
        'Pay once, verified forever. No renewals, no hidden charges.',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            blurRadius: 22,
            offset: Offset(0, 8),
            color: Color(0x14000000),
          ),
        ],
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          final colors = [
            Mycolor.greenLight,
            const Color(0xFFE7EEFF),
            Mycolor.purpleLight,
            const Color(0xFFFDE5EF),
          ];

          return Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              border: index == items.length - 1
                  ? null
                  : const Border(bottom: BorderSide(color: Color(0xFFEFE8EA))),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 50,
                  width: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors[index],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(item.$1, style: const TextStyle(fontSize: 25)),
                ),

                const SizedBox(width: 18),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.$2,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Mycolor.text,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        item.$3,
                        style: const TextStyle(
                          fontSize: 11,
                          height: 1.35,
                          color: Mycolor.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// --------------------------------------------------
// PAYMENT TILE
// --------------------------------------------------

class PaymentTile extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const PaymentTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.only(
          left: 15,
          right: 15,
          top: 10,
          bottom: 10,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected ? Mycolor.pink : const Color(0xFFEDE5E7),
            width: selected ? 2.2 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Mycolor.white,
                borderRadius: BorderRadius.circular(17),
              ),
              child: Text(icon, style: const TextStyle(fontSize: 30)),
            ),

            const SizedBox(width: 18),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13, color: Mycolor.muted),
                  ),
                ],
              ),
            ),

            _RadioCircle(selected: selected),
          ],
        ),
      ),
    );
  }
}

class _RadioCircle extends StatelessWidget {
  final bool selected;

  const _RadioCircle({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 25,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? Mycolor.pink : const Color(0xFFEAE2E4),
          width: 2,
        ),
      ),
      child: selected
          ? Container(
              decoration: const BoxDecoration(
                color: Mycolor.pink,
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
  }
}

// --------------------------------------------------
// SECURITY
// --------------------------------------------------

class SecurityBox extends StatelessWidget {
  const SecurityBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Mycolor.greenLight,
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Row(
        children: [
          Icon(Icons.lock_outline, color: Mycolor.green),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              '100% secure payment · Encrypted · Your card details are never stored',
              style: TextStyle(
                color: Mycolor.green,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------
// BOTTOM BUTTON
// --------------------------------------------------// --------------------------------------------------
// BOTTOM BUTTON
// --------------------------------------------------
class BottomAction extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final String secondaryText;
  final VoidCallback onSecondary;
  final bool enabled;
  final List<Color>? color;
  final List<BoxShadow>? colorshdow;

  const BottomAction({
    super.key,
    required this.text,
    required this.onPressed,
    required this.secondaryText,
    required this.onSecondary,
    this.color,
    this.colorshdow,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: enabled ? onPressed : null,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: enabled ? 1 : 0.5,
            child: Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),

                // Selected = Dark Pink
                // Unselected = Light Pink
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: color ?? [Mycolor.pink, Mycolor.pink],
                ),

                boxShadow: enabled
                    ? colorshdow ??
                          [
                            BoxShadow(
                              color: Color(0x45D81B69),
                              blurRadius: 25,
                              offset: Offset(0, 12),
                            ),
                          ]
                    : [],
              ),

              alignment: Alignment.center,

              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),

        TextButton(
          onPressed: onSecondary,
          child: Text(
            secondaryText,
            style: const TextStyle(
              color: Mycolor.muted,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
// --------------------------------------------------
// INFO BOX
// --------------------------------------------------

enum InfoType { pink, green, purple }

class InfoBox extends StatelessWidget {
  final String icon;
  final String text;
  final InfoType type;

  const InfoBox({
    super.key,
    required this.icon,
    required this.text,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    Color background;
    Color foreground;

    switch (type) {
      case InfoType.pink:
        background = Mycolor.pinkLight;
        foreground = const Color(0xFFC61561);
        break;

      case InfoType.green:
        background = Mycolor.greenLight;
        foreground = Mycolor.green;
        break;

      case InfoType.purple:
        background = Mycolor.purpleLight;
        foreground = const Color(0xFF793FFF);
        break;
    }

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: TextStyle(fontSize: 20, color: foreground)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: foreground,
                fontSize: 12,
                height: 1.45,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StepIndicator extends StatelessWidget {
  final int current;

  const StepIndicator({super.key, required this.current});

  @override
  Widget build(BuildContext context) {
    const labels = ['BACKGROUND', 'INCOME', 'CONTACT'];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(5, (index) {
        // Connector Line
        if (index.isOdd) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 19, left: 7, right: 8),
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  color: index ~/ 2 < current
                      ? Mycolor.dark
                      : const Color(0xFFEDE5E7),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          );
        }

        final step = index ~/ 2;

        final active = step == current;
        final done = step < current;

        return Expanded(
          child: Column(
            children: [
              // Circle
              Container(
                width: 30,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active || done
                      ? Mycolor.dark
                      : const Color(0xFFF4ECEE),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${step + 1}',
                  style: TextStyle(
                    color: active || done ? Colors.white : Mycolor.muted,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(height: 7),

              // Label
              Text(
                labels[step],
                maxLines: 1,
                overflow: TextOverflow.visible,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: active || done ? Mycolor.text : Mycolor.muted,
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
// --------------------------------------------------
// LABEL
// --------------------------------------------------

class SectionLabel extends StatelessWidget {
  final String text;

  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          color: Mycolor.muted,
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: .5,
        ),
      ),
    );
  }
}

class FieldLabel extends StatelessWidget {
  final String text;

  const FieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return SectionLabel(text);
  }
}

// --------------------------------------------------
// TEXT FIELD
// --------------------------------------------------

class TextFieldBox extends StatelessWidget {
  final String value;
  final String? hint;
  final TextInputType? keyboardType;
  final ValueChanged<String> onChanged;

  const TextFieldBox({
    super.key,
    required this.value,
    this.hint,
    this.keyboardType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Mycolor.text,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Mycolor.muted, fontSize: 18),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFEDE5E7)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFEDE5E7)),
        ),
      ),
    );
  }
}

// --------------------------------------------------
// VERIFIED DETAILS
// --------------------------------------------------

class VerifiedDetailsCard extends StatelessWidget {
  const VerifiedDetailsCard({super.key});

  @override
  Widget build(BuildContext context) {
    const data = [
      ('Full legal name', 'Tanishka Sharma'),
      ('Aadhaar (verified)', '•••• •••• 4821'),
      ('Date of birth', '14 May 1998'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            blurRadius: 20,
            offset: Offset(0, 8),
            color: Color(0x12000000),
          ),
        ],
      ),
      child: Column(
        children: data.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              border: index == data.length - 1
                  ? null
                  : const Border(bottom: BorderSide(color: Color(0xFFEDE5E7))),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Mycolor.greenLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Mycolor.green,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 18),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.$1,
                        style: const TextStyle(
                          color: Mycolor.muted,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.$2,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// --------------------------------------------------
// CONSENT
// --------------------------------------------------

class ConsentBox extends StatelessWidget {
  final bool checked;
  final String text;
  final ValueChanged<bool> onChanged;

  const ConsentBox({
    super.key,
    required this.checked,
    required this.text,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onChanged(!checked);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: checked ? const Color(0xFFFFE5F0) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: checked ? Mycolor.pink : Mycolor.color0xFFE5DFE2,
            width: checked ? 2 : 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(
                  color: checked ? Mycolor.pink : Mycolor.color0xFFE5DFE2,
                  width: checked ? 2 : 2,
                ),
                color: checked ? Mycolor.pink : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: checked
                  ? const Icon(Icons.check, color: Colors.white)
                  : null,
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 12, height: 1.35),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------
// CHOICE CHIP
// --------------------------------------------------

class ChoiceChipButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const ChoiceChipButton({
    super.key,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: selected ? Mycolor.pink : const Color(0xFFEDE5E7),
            width: selected ? 2 : 1.5,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Mycolor.pink : const Color(0xFF625B64),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------
// UPLOAD
// --------------------------------------------------
class UploadProofBox extends StatelessWidget {
  const UploadProofBox({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlatinumVerificationBloc, PlatinumVerificationState>(
      buildWhen: (previous, current) =>
          previous.incomeProofFile != current.incomeProofFile ||
          previous.incomeProofFileName != current.incomeProofFileName ||
          previous.status != current.status,
      builder: (context, state) {
        final file = state.incomeProofFile;
        final hasFile = file != null;

        return GestureDetector(
          onTap: state.status == PlatinumStatus.submitting
              ? null
              : () {
                  context.read<PlatinumVerificationBloc>().add(
                    PickIncomeProofFile(),
                  );
                },
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Mycolor.pinkLight,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: hasFile
                    ? Mycolor.pink.withOpacity(.45)
                    : Mycolor.pink.withOpacity(.45),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --------------------------------------------------
                // LOADING
                // --------------------------------------------------
                if (state.status == PlatinumStatus.submitting)
                  const SizedBox(
                    width: 35,
                    height: 35,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Mycolor.pink,
                    ),
                  )
                // --------------------------------------------------
                // FILE SELECTED
                // --------------------------------------------------
                else if (hasFile)
                  const Icon(
                    Icons.check_circle_outline,
                    color: Mycolor.green,
                    size: 40,
                  )
                // --------------------------------------------------
                // NO FILE
                // --------------------------------------------------
                else
                  const Icon(
                    Icons.badge_outlined,
                    color: Mycolor.pink,
                    size: 40,
                  ),

                const SizedBox(height: 20),

                // --------------------------------------------------
                // FILE NAME
                // --------------------------------------------------
                if (hasFile)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Text(
                      state.incomeProofFileName ?? '',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFC61561),
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  )
                else
                  const Text(
                    'Tap to upload salary slip / Form-16 / ITR',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFC61561),
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                const SizedBox(height: 7),

                // --------------------------------------------------
                // SUB TEXT
                // --------------------------------------------------
                Text(
                  hasFile ? 'Tap to change file' : 'JPG, PNG or PDF · Max 5MB',
                  style: const TextStyle(color: Mycolor.muted, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// --------------------------------------------------
// RADIO CHOICE
// --------------------------------------------------

class RadioChoice extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const RadioChoice({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: selected ? Mycolor.pinkLight : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Mycolor.pink : const Color(0xFFEDE5E7),
            width: selected ? 2 : 1.5,
          ),
        ),
        child: Row(
          children: [
            _RadioCircle(selected: selected),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------
// TRUST SCORE
// --------------------------------------------------

class TrustScoreCard extends StatelessWidget {
  const TrustScoreCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 30, 28, 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Mycolor.dark2, Mycolor.dark]),
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Column(
        children: [
          Text(
            'YOUR NEW TRUST SCORE',
            style: TextStyle(
              color: Color(0xFFC5BFCB),
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),

          SizedBox(height: 6),

          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '100',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(
                  text: '/100',
                  style: TextStyle(
                    color: Color(0xFFAAA2B2),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 8),

          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            child: LinearProgressIndicator(
              value: 1,
              minHeight: 10,
              backgroundColor: Color(0x445A526F),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF39B45)),
            ),
          ),

          SizedBox(height: 16),

          Text(
            'Maximum trust achieved · Platinum Member 👑',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------
// STATUS CARD
// --------------------------------------------------

class VerificationStatusCard extends StatelessWidget {
  const VerificationStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    const rows = [
      ('Criminal Background Check', 'Submitted · Under review', 'Reviewing'),
      ('Emergency Contact', 'Submitted · Under review', 'Reviewing'),
      ('Income Verification', 'Registered · OTP sent to contact', '✓ Done'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            blurRadius: 20,
            offset: Offset(0, 8),
            color: Color(0x12000000),
          ),
        ],
      ),
      child: Column(
        children: rows.map((row) {
          final done = row.$3.contains('Done');

          return Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFEDE5E7))),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Mycolor.greenLight,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Mycolor.green,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 18),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        row.$1,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        row.$2,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Mycolor.muted,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: done ? Mycolor.greenLight : const Color(0xFFFFF0D0),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    row.$3,
                    style: TextStyle(
                      color: done ? Mycolor.green : const Color(0xFFA66C00),
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
