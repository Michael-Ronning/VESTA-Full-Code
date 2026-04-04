import 'package:flutter/material.dart';
import 'dart:async';
import 'package:projectmercury/resources/firestore_methods.dart';
import 'package:projectmercury/resources/locator.dart';

enum _DigitSpanPhase {
  forwardReady,
  forwardShowing,
  forwardEntry,
  backwardReady,
  backwardShowing,
  backwardEntry,
}

enum _MemoryPhase {
  firstIntro,
  firstShowing,
  firstRecallPrompt,
  secondIntro,
  secondShowing,
  postSecondReady,
  finalReminder,
}

class InteractiveMoCAExamWidget extends StatefulWidget {
  const InteractiveMoCAExamWidget({super.key});
  static const routeName = '/moca';

  @override
  State<InteractiveMoCAExamWidget> createState() => _InteractiveMoCAExamWidgetState();
}

class _InteractiveMoCAExamWidgetState extends State<InteractiveMoCAExamWidget> {
  static const int _sectionCount = 9;
  static const int _mocaMaxScore = 22;
  static const int _normalCutoff = 19;
  static const String _mocaVersion = 'moca22';
  static const String _expectedOrientationPlace = 'NIL';
  static const String _expectedOrientationCity = 'Denton';

  int _currentSection = 0;
  int _totalScore = 0;
  bool _examComplete = false;
  bool _isSavingResult = false;
  String? _saveError;

  static const memWords = ['FACE', 'VELVET', 'CHURCH', 'DAISY', 'RED'];
  
  final List<int> fwdDigits = [2, 1, 8, 5, 4];
  List<int> fwdInput = [];
  bool fwdOk = false;
  
  final List<int> bwdDigits = [7, 4, 2];
  List<int> bwdInput = [];
  bool bwdOk = false;
  bool bwdChecked = false;

  _DigitSpanPhase _digitSpanPhase = _DigitSpanPhase.forwardReady;
  Timer? _digitSpanTimer;
  int? _digitBeingShown;
  int _digitDisplayIndex = 0;
  
  final String vigLetters = 'FBACMNAJKLBAFAKDEAJAMOFAB';
  int vigIdx = 0;
  int vigErrs = 0;
  int vigMiss = 0;
  bool vigDone = false;
  bool vigStarted = false;
  bool _vigTapRegisteredForCurrentLetter = false;
  Timer? vigTimer;
  
  List<int> s7answers = [];
  final s7expected = [93, 86, 79, 72, 65];
  int s7pts = 0;
  final TextEditingController _s7Controller = TextEditingController();
  
  final sentences = [
    'I only know that John is the one to help today.',
    'The cat always hid under the couch when dogs were in the room.'
  ];
  int sentencePts = 0;

  Timer? memoryTimer;
  _MemoryPhase _memoryPhase = _MemoryPhase.firstIntro;
  int memoryWordIndex = -1;
  bool memoryShowingGap = false;
  
  List<String> fluencyList = [];
  int timeLeft = 60;
  Timer? fluencyTmr;
  bool fluencyActive = false;
  
  final List<String> _abstractionPrompts = [
    'Banana - Orange',
    'Train - Bicycle',
    'Watch - Ruler',
  ];
  List<String> abstractInputs = ['', '', ''];
  int _abstractionStep = 0;
  bool _showAbstractionExampleInstruction = false;
  final TextEditingController _abstractionController = TextEditingController();
  int abstractPts = 0;
  
  List<String> recallInputs = [];
  final TextEditingController _recallController = TextEditingController();
  int recallPts = 0;
  
  final Map<String, String> orientation = {
    'date': '',
    'month': '',
    'year': '',
    'day': '',
    'place': '',
    'city': '',
  };
  int orientPts = 0;

  @override
  void dispose() {
    vigTimer?.cancel();
    fluencyTmr?.cancel();
    memoryTimer?.cancel();
    _digitSpanTimer?.cancel();
    _s7Controller.dispose();
    _abstractionController.dispose();
    _recallController.dispose();
    super.dispose();
  }

  void _calcScore() {
    var score = 0;

    if (fwdOk) score++;
    if (bwdOk) score++;
    if (_vigilanceCombinedErrors <= 2) score++;
    score += s7pts;
    score += sentencePts;
    if (fluencyList.length >= 11) score++;
    score += abstractPts;
    score += recallPts;
    score += orientPts;
    
    _totalScore = score;
  }

  Future<void> _goNext() async {
    if (_currentSection < _sectionCount - 1) {
      setState(() {
        _currentSection++;
      });
      return;
    }

    if (_isSavingResult) {
      return;
    }

    setState(() {
      _isSavingResult = true;
      _saveError = null;
      _calcScore();
    });

    try {
      await locator.get<FirestoreMethods>().submitMocaResult(
        totalScore: _totalScore,
        sectionScores: _buildSectionScores(),
        mocaVersion: _mocaVersion,
        mocaMaxScore: _mocaMaxScore,
        normalCutoff: _normalCutoff,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _examComplete = true;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _saveError = 'Failed to save MoCA result. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSavingResult = false;
        });
      }
    }
  }

  Map<String, int> _buildSectionScores() {
    return {
      'digitFwd': fwdOk ? 1 : 0,
      'digitBwd': bwdOk ? 1 : 0,
      'vigilance': _vigilanceCombinedErrors <= 2 ? 1 : 0,
      'serial7': s7pts,
      'sentence': sentencePts,
      'fluency': fluencyList.length >= 11 ? 1 : 0,
      'abstract': abstractPts,
      'recall': recallPts,
      'orientation': orientPts,
    };
  }

  int get _vigilanceCombinedErrors => vigErrs + vigMiss;

  void _goBack() {
    if (_currentSection > 0) {
      setState(() => _currentSection--);
    }
  }

  Widget _largeBtn(String txt, VoidCallback onTap,
      {Color? bg, bool active = true, IconData? ico}) {
    return SizedBox(
      width: double.infinity,
      height: 70,
      child: ElevatedButton(
        onPressed: active ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg ?? Colors.blue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[300],
          textStyle:
              const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: active ? 4 : 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (ico != null) ...[
              Icon(ico, size: 28),
              const SizedBox(width: 12),
            ],
            Text(txt),
          ],
        ),
      ),
    );
  }

  void _startMemoryPresentation() {
    _startMemoryPresentationForPass(secondPass: false);
  }

  void _startMemoryPresentationForPass({required bool secondPass}) {
    memoryTimer?.cancel();
    setState(() {
      _memoryPhase = secondPass ? _MemoryPhase.secondShowing : _MemoryPhase.firstShowing;
      memoryWordIndex = 0;
      memoryShowingGap = false;
    });

    memoryTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (!memoryShowingGap) {
          memoryShowingGap = true;
        } else if (memoryWordIndex < memWords.length - 1) {
          memoryWordIndex++;
          memoryShowingGap = false;
        } else {
          _memoryPhase = secondPass ? _MemoryPhase.postSecondReady : _MemoryPhase.firstRecallPrompt;
          memoryWordIndex = -1;
          memoryShowingGap = false;
          timer.cancel();
        }
      });
    });
  }

  Widget _memorySection() {
    return Column(
      children: [
        const Text(
          'Memory Test',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (_memoryPhase == _MemoryPhase.firstIntro) ...[
          const Text(
            'This is a memory test. You are going to see a list of words that you will have to remember now and later on. When the list is through, say as many words as you can remember out loud. It doesn\'t matter in what order you say them.',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _largeBtn('I\'m Ready', _startMemoryPresentation, ico: Icons.play_arrow),
        ] else if ((_memoryPhase == _MemoryPhase.firstShowing || _memoryPhase == _MemoryPhase.secondShowing) &&
            memoryWordIndex >= 0 &&
            memoryWordIndex < memWords.length) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue, width: 2),
            ),
            child: Text(
              memoryShowingGap ? '' : memWords[memoryWordIndex],
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            memoryShowingGap
                ? 'Pause'
                : '${_memoryPhase == _MemoryPhase.secondShowing ? 'Second list' : 'First list'}: Word ${memoryWordIndex + 1} of ${memWords.length}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ] else if (_memoryPhase == _MemoryPhase.firstRecallPrompt) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: const Text(
              'Say as many remembered words as you can out loud now.',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          _largeBtn(
            'Continue',
            () {
              setState(() {
                _memoryPhase = _MemoryPhase.secondIntro;
              });
            },
            bg: Colors.blue,
            ico: Icons.arrow_forward,
          ),
        ] else if (_memoryPhase == _MemoryPhase.secondIntro) ...[
          const Text(
            'You are going to see the same list of words a second time. Try to remember as many of the words as you can, including the words you remembered the first time. When the list is through, say as many words as you can remember.',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _largeBtn(
            'Show Words Again',
            () => _startMemoryPresentationForPass(secondPass: true),
            ico: Icons.play_arrow,
          ),
        ] else if (_memoryPhase == _MemoryPhase.postSecondReady) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: const Text(
              'Please say the remembered words out loud now.',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          _largeBtn(
            'I\'m Ready to Continue',
            () {
              setState(() {
                _memoryPhase = _MemoryPhase.finalReminder;
              });
            },
            bg: Colors.blue,
            ico: Icons.arrow_forward,
          ),
        ] else if (_memoryPhase == _MemoryPhase.finalReminder) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue, width: 2),
            ),
            child: const Text(
              'You will be asked to recall those words again at the end of the test.',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          _largeBtn(
            'Continue to Next Section',
            () => _goNext(),
            bg: Colors.green,
            ico: Icons.arrow_forward,
          ),
        ],
      ],
    );
  }

  Widget _digitSpanSection() {
    return Column(
      children: [
        const Text(
          'Digit Span Test',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        if (_digitSpanPhase == _DigitSpanPhase.forwardReady)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: const Text(
              'You are going to see a sequence of numbers. Once the numbers are through, select the number sequence in the same order as it appeared. Repeat the numbers exactly as they appeared, in the same order.',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
        if (_digitSpanPhase == _DigitSpanPhase.backwardReady)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: const Text(
              'Now you are going to see another sequence of numbers, but this time, when the numbers are through, select the number sequence in the backwards order.',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
        if (_digitSpanPhase == _DigitSpanPhase.forwardReady ||
            _digitSpanPhase == _DigitSpanPhase.backwardReady ||
            _digitSpanPhase == _DigitSpanPhase.forwardShowing ||
            _digitSpanPhase == _DigitSpanPhase.backwardShowing) ...[
          const SizedBox(height: 20),
          _buildDigitPresentationCard(),
          const SizedBox(height: 20),
        ],
        if (_digitSpanPhase == _DigitSpanPhase.forwardReady) ...[
          _largeBtn(
            'Ready for Forward Digit Span',
            _startForwardDigitSpan,
            ico: Icons.play_arrow,
          ),
        ],
        if (_digitSpanPhase == _DigitSpanPhase.forwardEntry) ...[
          _buildDigitEntryPanel(
            title: 'Forward Entry',
            subtitle: 'Repeat the sequence in the same order.',
            input: fwdInput,
            inputColor: Colors.blue,
            onDigit: (digit) => setState(() => fwdInput.add(digit)),
            onBackspace: () {
              if (fwdInput.isNotEmpty) {
                setState(() => fwdInput.removeLast());
              }
            },
            onClear: () => setState(() => fwdInput.clear()),
            onCheck: () {
              setState(() {
                fwdOk = fwdInput.length == fwdDigits.length &&
                    List.generate(fwdInput.length, (i) => fwdInput[i] == fwdDigits[i]).every((e) => e);
                _digitSpanPhase = _DigitSpanPhase.backwardReady;
              });
            },
          ),
        ],
        if (_digitSpanPhase == _DigitSpanPhase.backwardReady) ...[
          _largeBtn(
            'Ready for Backward Digit Span',
            _startBackwardDigitSpan,
            ico: Icons.play_arrow,
          ),
        ],
        if (_digitSpanPhase == _DigitSpanPhase.backwardEntry) ...[
          _buildDigitEntryPanel(
            title: 'Backward Entry',
            subtitle: 'Repeat the sequence in reverse order.',
            input: bwdInput,
            inputColor: Colors.purple,
            onDigit: (digit) => setState(() => bwdInput.add(digit)),
            onBackspace: () {
              if (bwdInput.isNotEmpty) {
                setState(() => bwdInput.removeLast());
              }
            },
            onClear: () => setState(() => bwdInput.clear()),
            onCheck: () {
              final reversed = bwdDigits.reversed.toList();
              setState(() {
                bwdChecked = true;
                bwdOk = bwdInput.length == reversed.length &&
                    List.generate(bwdInput.length, (i) => bwdInput[i] == reversed[i]).every((e) => e);
              });
            },
          ),
        ],
      ],
    );
  }

  Widget _buildDigitPresentationCard() {
    final isShowing = _digitSpanPhase == _DigitSpanPhase.forwardShowing ||
        _digitSpanPhase == _DigitSpanPhase.backwardShowing;
    final isForward = _digitSpanPhase == _DigitSpanPhase.forwardShowing;
    final bgColor = isForward ? Colors.blue[50] : Colors.purple[50];
    final borderColor = isForward ? Colors.blue : Colors.purple;
    final modeText = isForward ? 'Forward Sequence' : 'Backward Sequence';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Column(
        children: [
          Text(
            isShowing ? modeText : 'Sequence Display',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: borderColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isShowing && _digitBeingShown != null ? '$_digitBeingShown' : '-',
            style: const TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isShowing
                ? 'Digit ${_digitDisplayIndex + 1} shown'
                : 'Press Ready to begin this section.',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildDigitEntryPanel({
    required String title,
    required String subtitle,
    required List<int> input,
    required Color inputColor,
    required ValueChanged<int> onDigit,
    required VoidCallback onBackspace,
    required VoidCallback onClear,
    required VoidCallback onCheck,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 17),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: inputColor, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Your input: ${input.join(' ')}',
            style: const TextStyle(fontSize: 20),
          ),
        ),
        const SizedBox(height: 10),
        _buildPhoneKeypad(
          keyColor: inputColor,
          onDigit: onDigit,
          onBackspace: onBackspace,
          onClear: onClear,
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: onCheck,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Check'),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneKeypad({
    required Color keyColor,
    required ValueChanged<int> onDigit,
    required VoidCallback onBackspace,
    required VoidCallback onClear,
  }) {
    const keys = [1, 2, 3, 4, 5, 6, 7, 8, 9, -1, 0, -2];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: keys.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.95,
      ),
      itemBuilder: (context, index) {
        final key = keys[index];
        if (key == -1) {
          return ElevatedButton(
            onPressed: onBackspace,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: EdgeInsets.zero,
            ),
            child: const Icon(Icons.backspace, size: 20),
          );
        }

        if (key == -2) {
          return ElevatedButton(
            onPressed: onClear,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text(
              'Clear',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          );
        }

        return ElevatedButton(
          onPressed: () => onDigit(key),
          style: ElevatedButton.styleFrom(
            backgroundColor: keyColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(
            '$key',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }

  void _startForwardDigitSpan() {
    setState(() {
      fwdInput.clear();
      fwdOk = false;
      _digitSpanPhase = _DigitSpanPhase.forwardShowing;
    });
    _startDigitPresentation(sequence: fwdDigits, isForward: true);
  }

  void _startBackwardDigitSpan() {
    setState(() {
      bwdInput.clear();
      bwdOk = false;
      bwdChecked = false;
      _digitSpanPhase = _DigitSpanPhase.backwardShowing;
    });
    _startDigitPresentation(sequence: bwdDigits, isForward: false);
  }

  bool _canAdvanceFromCurrentSection() {
    if (_currentSection == 0) {
      return _memoryPhase == _MemoryPhase.finalReminder;
    }
    if (_currentSection == 1) {
      return bwdChecked;
    }
    return true;
  }

  void _startDigitPresentation({required List<int> sequence, required bool isForward}) {
    _digitSpanTimer?.cancel();

    setState(() {
      _digitDisplayIndex = 0;
      _digitBeingShown = sequence.first;
    });

    _digitSpanTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _digitDisplayIndex++;
        if (_digitDisplayIndex < sequence.length) {
          _digitBeingShown = sequence[_digitDisplayIndex];
        } else {
          _digitBeingShown = null;
          timer.cancel();
          _digitSpanPhase = isForward ? _DigitSpanPhase.forwardEntry : _DigitSpanPhase.backwardEntry;
        }
      });
    });
  }

  Widget _vigilanceSection() {
    return Column(
      children: [
        const Text(
          'Attention Test',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          'Tap the button whenever you see the letter A. If you see a different letter, do not tap the button. Press the \'Start Test\' button to start.',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        if (!vigDone) ...[
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue, width: 3),
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                child: Text(
                  vigStarted && vigIdx < vigLetters.length ? vigLetters[vigIdx] : '-',
                  key: ValueKey('vig_${vigStarted ? vigIdx : -1}'),
                  style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _largeBtn(vigStarted ? 'Tap if Letter is "A"' : 'Start Test', () {
            if (!vigStarted) {
              _startVigilance();
            } else {
              _handleVigilanceTap();
            }
          }),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                Text(
                  'Test Complete!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'You can continue when ready.',
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _startVigilance() {
    vigTimer?.cancel();
    setState(() {
      vigStarted = true;
      vigDone = false;
      vigIdx = 0;
      vigErrs = 0;
      vigMiss = 0;
      _vigTapRegisteredForCurrentLetter = false;
    });

    vigTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }

      setState(() {
        if (vigIdx >= vigLetters.length) {
          vigDone = true;
          vigStarted = false;
          t.cancel();
          return;
        }

        if (vigLetters[vigIdx] == 'A' && !_vigTapRegisteredForCurrentLetter) {
          vigMiss++;
        }

        vigIdx++;
        _vigTapRegisteredForCurrentLetter = false;

        if (vigIdx >= vigLetters.length) {
          vigDone = true;
          vigStarted = false;
          t.cancel();
        }
      });
    });
  }

  void _handleVigilanceTap() {
    if (!vigStarted || vigDone || vigIdx >= vigLetters.length) {
      return;
    }

    if (_vigTapRegisteredForCurrentLetter) {
      return;
    }

    setState(() {
      if (vigLetters[vigIdx] != 'A') {
        vigErrs++;
      }
      _vigTapRegisteredForCurrentLetter = true;
    });
  }

  Widget _serial7Section() {
    final currentStep = s7answers.length.clamp(0, s7expected.length);
    final int? currentBase = currentStep == 0
        ? 100
        : (currentStep <= s7answers.length ? s7answers[currentStep - 1] : null);

    return Column(
      children: [
        const Text(
          'Serial 7s',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          'Please count by subtracting 7 100, and then keep subtracting seven from your answer until you are prompted to stop.',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Step ${currentStep + 1 > s7expected.length ? s7expected.length : currentStep + 1} of ${s7expected.length}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        if (currentStep < s7expected.length && currentBase != null) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  '$currentBase - 7 =',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                ),
              ),
              SizedBox(
                width: 140,
                child: TextField(
                  controller: _s7Controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Answer',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: const TextStyle(fontSize: 24),
                  onSubmitted: (_) => _submitSerial7Answer(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _largeBtn('Enter Answer', _submitSerial7Answer, bg: Colors.blue),
        ] else ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: const Text(
              'Serial 7 sequence complete.',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ],
        const SizedBox(height: 16),
        if (s7answers.isNotEmpty) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Recorded responses:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.blue[800]),
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(s7answers.length, (i) {
            final base = i == 0 ? 100 : s7answers[i - 1];
            return Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '$base - 7 = ${s7answers[i]}',
                  style: const TextStyle(fontSize: 19),
                ),
              ),
            );
          }),
          const SizedBox(height: 10),
          _largeBtn(
            'Undo Last Answer',
            () {
              setState(() {
                if (s7answers.isNotEmpty) {
                  s7answers.removeLast();
                  _calcSerial7();
                }
                _s7Controller.clear();
              });
            },
            bg: Colors.orange,
            active: s7answers.isNotEmpty,
          ),
        ],
      ],
    );
  }

  void _submitSerial7Answer() {
    final entered = int.tryParse(_s7Controller.text.trim());
    if (entered == null) {
      return;
    }

    if (s7answers.length >= s7expected.length) {
      return;
    }

    setState(() {
      s7answers.add(entered);
      _calcSerial7();
      _s7Controller.clear();
    });
  }

  void _calcSerial7() {
    var correct = 0;
    for (var i = 0; i < s7answers.length && i < s7expected.length; i++) {
      final base = i == 0 ? 100 : s7answers[i - 1];
      final expectedFromCurrentExpression = base - 7;
      if (s7answers[i] == expectedFromCurrentExpression) {
        correct++;
      }
    }

    if (correct == 0) {
      s7pts = 0;
    } else if (correct == 1) {
      s7pts = 1;
    } else if (correct <= 3) {
      s7pts = 2;
    } else {
      s7pts = 3;
    }
  }

  Widget _sentenceSection() {
    return Column(
      children: [
        const Text(
          'Sentence Repetition',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          'Listen and repeat these sentences exactly:',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 24),
        ...List.generate(sentences.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    sentences[i],
                    style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => setState(() {
                        if (sentencePts & (1 << i) == 0) sentencePts |= (1 << i);
                      }),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: sentencePts & (1 << i) != 0 ? Colors.green : Colors.grey[300],
                        fixedSize: const Size(120, 50),
                      ),
                      child: const Text('Correct', style: TextStyle(fontSize: 16)),
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() {
                        if (sentencePts & (1 << i) != 0) sentencePts &= ~(1 << i);
                      }),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: sentencePts & (1 << i) == 0 ? Colors.red : Colors.grey[300],
                        fixedSize: const Size(120, 50),
                      ),
                      child: const Text('Incorrect', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _fluencySection() {
    return Column(
      children: [
        const Text(
          'Verbal Fluency',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          'Name as many words as you can that start with "F"',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        if (!fluencyActive) ...[
          _largeBtn('Start 60 Second Timer', () {
            setState(() {
              fluencyActive = true;
              timeLeft = 60;
            });
            fluencyTmr = Timer.periodic(const Duration(seconds: 1), (t) {
              setState(() {
                if (timeLeft > 0) {
                  timeLeft--;
                } else {
                  fluencyActive = false;
                  t.cancel();
                }
              });
            });
          }),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Time: $timeLeft seconds',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ),
        ],
        const SizedBox(height: 24),
        TextField(
          decoration: InputDecoration(
            labelText: 'Enter each word (press Enter)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.white,
          ),
          style: const TextStyle(fontSize: 20),
          onSubmitted: (w) {
            if (w.isNotEmpty && fluencyActive) {
              setState(() => fluencyList.add(w));
            }
          },
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Words: ${fluencyList.length}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: fluencyList.map((w) => Chip(label: Text(w))).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _abstractionSection() {
    final isComplete = _abstractionStep >= _abstractionPrompts.length;

    return Column(
      children: [
        const Text(
          'Abstraction',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          'What do these pairs have in common?',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 24),
        if (_showAbstractionExampleInstruction) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue, width: 2),
            ),
            child: const Text(
              'An orange and a banana are alike because they are both fruit. Let\'s try another one.',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          _largeBtn(
            'Continue',
            () {
              setState(() {
                _showAbstractionExampleInstruction = false;
                _abstractionStep = 1;
                _abstractionController.clear();
              });
            },
            bg: Colors.blue,
          ),
        ] else if (!isComplete) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Prompt ${_abstractionStep + 1} of ${_abstractionPrompts.length}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _abstractionPrompts[_abstractionStep],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _abstractionController,
            decoration: InputDecoration(
              labelText: 'What they have in common',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              filled: true,
              fillColor: Colors.white,
            ),
            style: const TextStyle(fontSize: 20),
            onSubmitted: (_) => _submitAbstractionAnswer(),
          ),
          const SizedBox(height: 16),
          _largeBtn('Enter Answer', _submitAbstractionAnswer, bg: Colors.blue),
        ] else ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: const Text(
              'Abstraction prompts complete. Continue when ready.',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }

  void _submitAbstractionAnswer() {
    if (_showAbstractionExampleInstruction || _abstractionStep >= _abstractionPrompts.length) {
      return;
    }

    final response = _abstractionController.text.trim();
    if (response.isEmpty) {
      return;
    }

    setState(() {
      abstractInputs[_abstractionStep] = response;
      _abstractionController.clear();

      if (_abstractionStep == 0) {
        // First prompt is an example and is not scored.
        _showAbstractionExampleInstruction = true;
      } else {
        _abstractionStep++;
      }

      _scoreAbstraction();
    });
  }

  void _scoreAbstraction() {
    var pts = 0;

    final vehicleAnswer = abstractInputs[1].toLowerCase();
    if (vehicleAnswer.contains('transport') ||
        vehicleAnswer.contains('vehicle') ||
        vehicleAnswer.contains('travel')) {
      pts++;
    }

    final watchRulerAnswer = abstractInputs[2].toLowerCase();
    if (watchRulerAnswer.contains('measur')) {
      pts++;
    }
    abstractPts = pts;
  }

  Widget _recallSection() {
    return Column(
      children: [
        const Text(
          'Memory Recall',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          'Earlier, you saw a list of words that you were asked to remember. Type out as many of those words as you can remember now.',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _recallController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Type remembered words here',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.white,
          ),
          style: const TextStyle(fontSize: 20),
          onChanged: (v) {
            recallInputs = [v];
            _scoreRecall();
          },
        ),
      ],
    );
  }

  void _scoreRecall() {
    if (recallInputs.isEmpty) {
      recallPts = 0;
      return;
    }

    final raw = recallInputs.first.toUpperCase();
    final tokens = raw
        .split(RegExp(r'[^A-Z]+'))
        .where((w) => w.isNotEmpty)
        .toSet();

    var pts = 0;
    for (final word in memWords) {
      if (tokens.contains(word)) {
        pts++;
      }
    }
    setState(() => recallPts = pts);
  }

  Widget _orientationSection() {
    final fields = ['date', 'month', 'year', 'day', 'place', 'city'];
    final labels = ['Date', 'Month', 'Year', 'Day of week', 'Place', 'City'];
    
    return Column(
      children: [
        const Text(
          'Orientation',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          'Answer the following questions:',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 24),
        ...List.generate(fields.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TextField(
              decoration: InputDecoration(
                labelText: labels[i],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Colors.white,
              ),
              style: const TextStyle(fontSize: 20),
              onChanged: (v) {
                orientation[fields[i]] = v;
                _scoreOrientation();
              },
            ),
          );
        }),
      ],
    );
  }

  void _scoreOrientation() {
    final now = DateTime.now();
    var pts = 0;
    
    if (orientation['date']?.trim() == now.day.toString()) pts++;
    if (orientation['month']?.trim().toLowerCase() == _getMonthName(now.month).toLowerCase()) pts++;
    if (orientation['year']?.trim() == now.year.toString()) pts++;
    if (orientation['day']?.trim().toLowerCase() == _getDayName(now.weekday).toLowerCase()) pts++;
    if (orientation['place']?.trim().toUpperCase() == _expectedOrientationPlace.toUpperCase()) pts++;
    if (orientation['city']?.trim().toLowerCase() == _expectedOrientationCity.toLowerCase()) pts++;
    
    setState(() => orientPts = pts);
  }

  String _getMonthName(int m) {
    const months = ['', 'January', 'February', 'March', 'April', 'May', 'June',
                    'July', 'August', 'September', 'October', 'November', 'December'];
    return months[m];
  }

  String _getDayName(int d) {
    const days = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[d];
  }

  Widget _resultsSection() {
    return Column(
      children: [
        const Text(
          'MoCA-22 Test Results',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: _totalScore >= _normalCutoff ? Colors.green[100] : Colors.orange[100],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _totalScore >= _normalCutoff ? Colors.green : Colors.orange, width: 3),
          ),
          child: Column(
            children: [
              Text(
                'Total Score',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: _totalScore >= _normalCutoff ? Colors.green[900] : Colors.orange[900],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '$_totalScore / $_mocaMaxScore',
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: _totalScore >= _normalCutoff ? Colors.green[900] : Colors.orange[900],
                ),
              ),

              const SizedBox(height: 40),
                ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentSection = 0;
                    _examComplete = false;
                    // Reset all state variables here
                    _totalScore = 0;
                    fwdInput.clear();
                    fwdOk = false;
                    bwdInput.clear();
                    bwdOk = false;
                    bwdChecked = false;
                    _digitSpanTimer?.cancel();
                    _digitSpanPhase = _DigitSpanPhase.forwardReady;
                    _digitBeingShown = null;
                    _digitDisplayIndex = 0;
                    vigIdx = 0;
                    vigErrs = 0;
                    vigMiss = 0;
                    vigDone = false;
                    vigStarted = false;
                    _vigTapRegisteredForCurrentLetter = false;
                    vigTimer?.cancel();
                    memoryTimer?.cancel();
                    _memoryPhase = _MemoryPhase.firstIntro;
                    memoryWordIndex = -1;
                    memoryShowingGap = false;
                    s7answers.clear();
                    s7pts = 0;
                    _s7Controller.clear();
                    sentencePts = 0;
                    fluencyTmr?.cancel();
                    fluencyList.clear();
                    fluencyActive = false;
                    timeLeft = 60;
                    abstractInputs = ['', '', ''];
                    _abstractionStep = 0;
                    _showAbstractionExampleInstruction = false;
                    _abstractionController.clear();
                    abstractPts = 0;
                    recallInputs.clear();
                    _recallController.clear();
                    recallPts = 0;
                    orientation['date'] = '';
                    orientation['month'] = '';
                    orientation['year'] = '';
                    orientation['day'] = '';
                    orientation['place'] = '';
                    orientation['city'] = '';
                    orientPts = 0;
                  });
                },
                child: const Row(
                  children: [
                    Icon(Icons.refresh, color: Color.fromARGB(255, 97, 83, 224)),
                    SizedBox(width: 8),
                    Text('Start New Exam', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _scoreRow('Digits Forward', fwdOk ? 1 : 0, 1),
              _scoreRow('Digits Backward', bwdOk ? 1 : 0, 1),
              _scoreRow('Vigilance', _vigilanceCombinedErrors <= 2 ? 1 : 0, 1),
              _scoreRow('Serial 7s', s7pts, 3),
              _scoreRow('Sentence Repetition', sentencePts, 2),
              _scoreRow('Verbal Fluency', fluencyList.length >= 11 ? 1 : 0, 1),
              _scoreRow('Abstraction', abstractPts, 2),
              _scoreRow('Delayed Recall', recallPts, 5),
              _scoreRow('Orientation', orientPts, 6),
            ],
          ),
        ),
      ],
    );
  }

  Widget _scoreRow(String label, int score, int max) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text('$score / $max', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sections = [
      _memorySection(),
      _digitSpanSection(),
      _vigilanceSection(),
      _serial7Section(),
      _sentenceSection(),
      _fluencySection(),
      _abstractionSection(),
      _recallSection(),
      _orientationSection(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('MoCA-22 Cognitive Assessment'),
        backgroundColor: Colors.blue[700],
      ),
      body: _examComplete
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _resultsSection(),
            )
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue[50],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Section ${_currentSection + 1} of $_sectionCount',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${(((_currentSection + 1) / _sectionCount) * 100).toInt()}%',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: sections[_currentSection],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      if (_currentSection > 0)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _largeBtn('Back', _goBack, bg: Colors.grey[400], ico: Icons.arrow_back),
                          ),
                        ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: _currentSection > 0 ? 8 : 0),
                          child: _largeBtn(
                            _currentSection == _sectionCount - 1
                                ? (_isSavingResult ? 'Saving...' : 'Finish')
                                : 'Next',
                            () => _goNext(),
                            bg: Colors.green,
                            active: !_isSavingResult && _canAdvanceFromCurrentSection(),
                            ico: _currentSection == _sectionCount - 1 ? Icons.check : Icons.arrow_forward,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_saveError != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Text(
                      _saveError!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
    );
  }
}
