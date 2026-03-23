import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:projectmercury/resources/firestore_methods.dart';
import 'package:projectmercury/resources/locator.dart';

class InteractiveMoCAExamWidget extends StatefulWidget {
  const InteractiveMoCAExamWidget({super.key});
  static const routeName = '/moca';

  @override
  State<InteractiveMoCAExamWidget> createState() => _InteractiveMoCAExamWidgetState();
}

class _InteractiveMoCAExamWidgetState extends State<InteractiveMoCAExamWidget> {
  int _currentSection = 0;
  int _totalScore = 0;
  bool _examComplete = false;
  bool _isSavingResult = false;
  String? _saveError;
  
  final List<String> trailSeq = ['1', 'A', '2', 'B', '3', 'C', '4', 'D', '5', 'E'];
  List<String> completedTrails = [];
  bool trailsPassed = false;
  
  List<Offset> cubePoints = [];
  bool cubePassed = false;
  
  List<Offset> clockPoints = [];
  int clockPts = 0;
  
  int namingPts = 0;
  final animals = ['Lion', 'Rhinoceros', 'Camel'];
  List<String> animalInputs = ['', '', ''];
  
  static const memWords = ['FACE', 'VELVET', 'CHURCH', 'DAISY', 'RED'];
  
  final List<int> fwdDigits = [2, 1, 8, 5, 4];
  List<int> fwdInput = [];
  bool fwdOk = false;
  
  final List<int> bwdDigits = [7, 4, 2];
  List<int> bwdInput = [];
  bool bwdOk = false;
  
  final String vigLetters = 'FBACMNAAAJKLBAFAKDEAAAJAMOFAAB';
  int vigIdx = 0;
  int vigErrs = 0;
  int vigMiss = 0;
  bool vigDone = false;
  Timer? vigTimer;
  
  List<int> s7answers = [];
  final s7expected = [93, 86, 79, 72, 65];
  int s7pts = 0;
  
  final sentences = [
    'I only know that John is the one to help today.',
    'The cat always hid under the couch when dogs were in the room.'
  ];
  int sentencePts = 0;

  Timer? memoryTimer;
  bool memoryStarted = false;
  bool memoryComplete = false;
  int memoryWordIndex = -1;
  bool memoryShowingGap = false;
  
  List<String> fluencyList = [];
  int timeLeft = 60;
  Timer? fluencyTmr;
  bool fluencyActive = false;
  
  final abstractPairs = ['Banana - Orange', 'Train - Bicycle'];
  List<String> abstractInputs = ['', ''];
  int abstractPts = 0;
  
  List<String> recallInputs = [];
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
    super.dispose();
  }

  void _calcScore() {
    var score = 0;
    
    if (trailsPassed) score++;
    if (cubePassed) score++;
    score += clockPts;
    score += namingPts;
    if (fwdOk) score++;
    if (bwdOk) score++;
    if (vigErrs <= 2) score++;
    score += s7pts;
    score += sentencePts;
    if (fluencyList.length >= 11) score++;
    score += abstractPts;
    score += recallPts;
    score += orientPts;
    
    _totalScore = score;
  }

  Future<void> _goNext() async {
    if (_currentSection < 12) {
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
      'trail': trailsPassed ? 1 : 0,
      'cube': cubePassed ? 1 : 0,
      'clock': clockPts,
      'naming': namingPts,
      'digitFwd': fwdOk ? 1 : 0,
      'digitBwd': bwdOk ? 1 : 0,
      'vigilance': vigErrs <= 2 ? 1 : 0,
      'serial7': s7pts,
      'sentence': sentencePts,
      'fluency': fluencyList.length >= 11 ? 1 : 0,
      'abstract': abstractPts,
      'recall': recallPts,
      'orientation': orientPts,
    };
  }

  void _goBack() {
    if (_currentSection > 0) {
      setState(() => _currentSection--);
    }
  }

  Widget _largeBtn(String txt, VoidCallback onTap, {Color? bg, bool active = true, IconData? ico}) {
    return SizedBox(
      width: double.infinity,
      height: 70,
      child: ElevatedButton(
        onPressed: active ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg ?? Colors.blue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[300],
          textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  Widget _trailTest() {
    return Column(
      children: [
        const Text(
          'Tap the circles in order:\n1 → A → 2 → B → 3 → C → 4 → D → 5 → E',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Container(
          height: 400,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.blue, width: 3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: List.generate(trailSeq.length, (i) {
              final rnd = math.Random(i);
              final x = 20.0 + rnd.nextDouble() * 250;
              final y = 20.0 + rnd.nextDouble() * 300;
              final done = completedTrails.contains(trailSeq[i]);
              final isNext = completedTrails.length == i;
              
              return Positioned(
                left: x,
                top: y,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isNext) {
                        completedTrails.add(trailSeq[i]);
                        if (completedTrails.length == trailSeq.length) {
                          trailsPassed = true;
                        }
                      } else if (!done) {
                        completedTrails.clear();
                      }
                    });
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done ? Colors.green : (Colors.blue[100]),
                      border: Border.all(color: Colors.blue[900]!, width: 3),
                    ),
                    child: Center(
                      child: Text(
                        trailSeq[i],
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: done ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 16),
        if (trailsPassed)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 32),
                SizedBox(width: 12),
                Text('Trail Making Complete! ✓', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _cubeSection() {
    return Column(
      children: [
        const Text(
          'Draw the cube below using your finger or stylus',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          height: 150,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border.all(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomPaint(
            painter: CubePainter(),
            size: const Size(double.infinity, 150),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Your drawing:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          height: 250,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: GestureDetector(
            onPanStart: (details) {
              setState(() {
                cubePoints.add(details.localPosition);
              });
            },
            onPanUpdate: (details) {
              setState(() {
                cubePoints.add(details.localPosition);
              });
            },
            onPanEnd: (details) {
              setState(() {
                cubePoints.add(Offset.infinite);
              });
            },
            child: CustomPaint(
              painter: DrawingPainter(cubePoints),
              size: const Size(double.infinity, 250),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _largeBtn('Clear', () {
                setState(() => cubePoints.clear());
              }, bg: Colors.orange),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _largeBtn(cubePassed ? 'Marked ✓' : 'Mark Correct', () {
                setState(() => cubePassed = !cubePassed);
              }, bg: cubePassed ? Colors.green : Colors.blue),
            ),
          ],
        ),
      ],
    );
  }

  Widget _clockSection() {
    return Column(
      children: [
        const Text(
          'Draw a clock showing 10 past 11',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          height: 300,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: GestureDetector(
            onPanStart: (d) => setState(() => clockPoints.add(d.localPosition)),
            onPanUpdate: (d) => setState(() => clockPoints.add(d.localPosition)),
            onPanEnd: (d) => setState(() => clockPoints.add(Offset.infinite)),
            child: CustomPaint(
              painter: DrawingPainter(clockPoints),
              size: const Size(double.infinity, 300),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _largeBtn('Clear Drawing', () => setState(() => clockPoints.clear()), bg: Colors.orange),
        const SizedBox(height: 16),
        const Text('Score this section:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(4, (i) {
            return GestureDetector(
              onTap: () => setState(() => clockPts = i),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: clockPts == i ? Colors.blue : Colors.grey[200],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue, width: 2),
                ),
                child: Center(
                  child: Text(
                    '$i',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: clockPts == i ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _namingSection() {
    return Column(
      children: [
        const Text(
          'Name the following animals:',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        ...List.generate(animals.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                  child: Center(
                    child: CustomPaint(
                      painter: i == 0 ? LionPainter(Colors.orange[700]!) : 
                               i == 1 ? RhinoPainter(Colors.grey[700]!) : 
                               CamelPainter(Colors.brown[600]!),
                      size: const Size(100, 100),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Your answer',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: const TextStyle(fontSize: 20),
                  onChanged: (val) {
                    animalInputs[i] = val;
                    _checkNaming();
                  },
                ),
              ],
            ),
          );
        }),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Score: $namingPts / 3',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  void _checkNaming() {
    var pts = 0;
    for (var i = 0; i < animals.length; i++) {
      if (animalInputs[i].trim().toLowerCase() == animals[i].toLowerCase()) {
        pts++;
      }
    }
    setState(() => namingPts = pts);
  }

  void _startMemoryPresentation() {
    memoryTimer?.cancel();
    setState(() {
      memoryStarted = true;
      memoryComplete = false;
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
          memoryStarted = false;
          memoryComplete = true;
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
        const Text(
          'Remember these words. They will be tested later.',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        if (!memoryStarted && !memoryComplete) ...[
          _largeBtn('I\'m Ready', _startMemoryPresentation, ico: Icons.play_arrow),
        ] else if (memoryStarted &&
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
                : 'Word ${memoryWordIndex + 1} of ${memWords.length}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ] else if (memoryComplete) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: const Text(
              'Word presentation complete. Continue when ready.',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ],
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Try to remember these words for later!',
            style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
        ),
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
        const Text(
          'Forward: Repeat these numbers in the same order',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            fwdDigits.join('  '),
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: 8),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          children: List.generate(10, (n) {
            return ElevatedButton(
              onPressed: () {
                setState(() => fwdInput.add(n));
              },
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(60, 60),
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('$n', style: const TextStyle(fontSize: 24, color: Colors.white)),
            );
          }),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Your input: ${fwdInput.join(' ')}',
            style: const TextStyle(fontSize: 20),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _largeBtn('Clear', () => setState(() => fwdInput.clear()), bg: Colors.orange)),
            const SizedBox(width: 12),
            Expanded(child: _largeBtn('Check', () {
              setState(() {
                fwdOk = fwdInput.length == fwdDigits.length && 
                        List.generate(fwdInput.length, (i) => fwdInput[i] == fwdDigits[i]).every((e) => e);
              });
            })),
          ],
        ),
        if (fwdOk) 
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text('✓ Correct!', style: TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        const SizedBox(height: 32),
        const Text(
          'Backward: Repeat these numbers in reverse order',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.purple[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            bwdDigits.join('  '),
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: 8),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          children: List.generate(10, (n) {
            return ElevatedButton(
              onPressed: () => setState(() => bwdInput.add(n)),
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(60, 60),
                backgroundColor: Colors.purple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('$n', style: const TextStyle(fontSize: 24, color: Colors.white)),
            );
          }),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.purple, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Your input: ${bwdInput.join(' ')}',
            style: const TextStyle(fontSize: 20),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _largeBtn('Clear', () => setState(() => bwdInput.clear()), bg: Colors.orange)),
            const SizedBox(width: 12),
            Expanded(child: _largeBtn('Check', () {
              final reversed = bwdDigits.reversed.toList();
              setState(() {
                bwdOk = bwdInput.length == reversed.length && 
                        List.generate(bwdInput.length, (i) => bwdInput[i] == reversed[i]).every((e) => e);
              });
            })),
          ],
        ),
        if (bwdOk)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text('✓ Correct!', style: TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
      ],
    );
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
          'Tap the screen each time you see the letter "A"',
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
              child: Text(
                vigIdx < vigLetters.length ? vigLetters[vigIdx] : '',
                style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _largeBtn(vigIdx == 0 ? 'Start Test' : 'Tap for "A"', () {
            if (vigIdx == 0) {
              _startVigilance();
            } else {
              _handleVigilanceTap();
            }
          }),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: vigErrs <= 2 ? Colors.green[100] : Colors.red[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  'Test Complete!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: vigErrs <= 2 ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 12),
                Text('Errors: $vigErrs', style: const TextStyle(fontSize: 20)),
                Text('Missed: $vigMiss', style: const TextStyle(fontSize: 20)),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _startVigilance() {
    vigTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (vigIdx >= vigLetters.length) {
        t.cancel();
        setState(() => vigDone = true);
      }
    });
  }

  void _handleVigilanceTap() {
    if (vigIdx < vigLetters.length) {
      final letter = vigLetters[vigIdx];
      if (letter != 'A') {
        vigErrs++;
      }
      setState(() => vigIdx++);
    }
    
    while (vigIdx < vigLetters.length && vigLetters[vigIdx] == 'A') {
      vigMiss++;
      vigIdx++;
    }
    
    if (vigIdx >= vigLetters.length) {
      vigTimer?.cancel();
      setState(() => vigDone = true);
    }
  }

  Widget _serial7Section() {
    return Column(
      children: [
        const Text(
          'Serial 7s',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          'Starting at 100, subtract 7 repeatedly',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ...List.generate(5, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    i == 0 ? '100 - 7 =' : "${s7expected[i-1]} - 7 =",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    style: const TextStyle(fontSize: 22),
                    onChanged: (v) {
                      final num = int.tryParse(v);
                      if (num != null) {
                        setState(() {
                          if (i < s7answers.length) {
                            s7answers[i] = num;
                          } else {
                            s7answers.add(num);
                          }
                          _calcSerial7();
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Correct: $s7pts / 5',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  void _calcSerial7() {
    var correct = 0;
    for (var i = 0; i < s7answers.length && i < s7expected.length; i++) {
      if (s7answers[i] == s7expected[i]) correct++;
    }
    s7pts = correct;
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
        ...List.generate(abstractPairs.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  abstractPairs[i],
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'What they have in common',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: const TextStyle(fontSize: 20),
                  onChanged: (v) {
                    abstractInputs[i] = v;
                    _scoreAbstraction();
                  },
                ),
              ],
            ),
          );
        }),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Score: $abstractPts / 2',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  void _scoreAbstraction() {
    var pts = 0;
    final keywords = [
      ['fruit', 'food'],
      ['transport', 'vehicle', 'travel']
    ];
    
    for (var i = 0; i < abstractInputs.length && i < keywords.length; i++) {
      final ans = abstractInputs[i].toLowerCase();
      if (keywords[i].any((k) => ans.contains(k))) {
        pts++;
      }
    }
    setState(() => abstractPts = pts);
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
          'What were the 5 words from earlier?',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 24),
        ...List.generate(5, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Word ${i + 1}',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Colors.white,
              ),
              style: const TextStyle(fontSize: 20),
              onChanged: (v) {
                if (i < recallInputs.length) {
                  recallInputs[i] = v;
                } else {
                  recallInputs.add(v);
                }
                _scoreRecall();
              },
            ),
          );
        }),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Recalled: $recallPts / 5',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  void _scoreRecall() {
    var pts = 0;
    for (var i = 0; i < recallInputs.length && i < memWords.length; i++) {
      if (recallInputs[i].trim().toUpperCase() == memWords[i]) {
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
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Score: $orientPts / 6',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
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
          'MoCA Test Results',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: _totalScore >= 26 ? Colors.green[100] : Colors.orange[100],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _totalScore >= 26 ? Colors.green : Colors.orange, width: 3),
          ),
          child: Column(
            children: [
              Text(
                'Total Score',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: _totalScore >= 26 ? Colors.green[900] : Colors.orange[900],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '$_totalScore / 30',
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: _totalScore >= 26 ? Colors.green[900] : Colors.orange[900],
                ),
              ),

              const SizedBox(height: 40),
                ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentSection = 0;
                    _examComplete = false;
                    // Reset all state variables here
                    trailsPassed = false;
                    cubePassed = false;
                    clockPts = 0;
                    namingPts = 0;
                    fwdOk = false;
                    bwdOk = false;
                    vigErrs = 0;
                    vigMiss = 0;
                    vigDone = false;
                    memoryTimer?.cancel();
                    memoryStarted = false;
                    memoryComplete = false;
                    memoryWordIndex = -1;
                    memoryShowingGap = false;
                    s7answers.clear();
                    s7pts = 0;
                    sentencePts = 0;
                    fluencyList.clear();
                    fluencyActive = false;
                    timeLeft = 60;
                    abstractInputs.clear();
                    abstractPts = 0;
                    recallInputs.clear();
                    recallPts = 0;
                    orientation.clear();
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
              _scoreRow('Trail Making', trailsPassed ? 1 : 0, 1),
              _scoreRow('Cube Copy', cubePassed ? 1 : 0, 1),
              _scoreRow('Clock Drawing', clockPts, 3),
              _scoreRow('Naming', namingPts, 3),
              _scoreRow('Digits Forward', fwdOk ? 1 : 0, 1),
              _scoreRow('Digits Backward', bwdOk ? 1 : 0, 1),
              _scoreRow('Vigilance', vigErrs <= 2 ? 1 : 0, 1),
              _scoreRow('Serial 7s', s7pts, 5),
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
      _trailTest(),
      _cubeSection(),
      _clockSection(),
      _namingSection(),
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
        title: const Text('MoCA Cognitive Assessment'),
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
                        'Section ${_currentSection + 1} of 13',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${(((_currentSection + 1) / 13) * 100).toInt()}%',
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
                        color: Colors.black.withOpacity(0.1),
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
                            _currentSection == 12
                                ? (_isSavingResult ? 'Saving...' : 'Finish')
                                : 'Next',
                            () => _goNext(),
                            bg: Colors.green,
                            active: !_isSavingResult,
                            ico: _currentSection == 12 ? Icons.check : Icons.arrow_forward,
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

class DrawingPainter extends CustomPainter {
  final List<Offset> points;
  DrawingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue[900]!
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < points.length - 1; i++) {
      if (points[i] != Offset.infinite && points[i + 1] != Offset.infinite) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter old) => true;
}

class CubePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;
    final s = math.min(w, h) * 0.4;

    canvas.drawRect(Rect.fromLTWH(cx - s, cy - s/2, s, s), paint);
    canvas.drawRect(Rect.fromLTWH(cx - s/2, cy - s, s, s), paint);
    
    canvas.drawLine(Offset(cx - s, cy - s/2), Offset(cx - s/2, cy - s), paint);
    canvas.drawLine(Offset(cx, cy - s/2), Offset(cx + s/2, cy - s), paint);
    canvas.drawLine(Offset(cx - s, cy + s/2), Offset(cx - s/2, cy), paint);
    canvas.drawLine(Offset(cx, cy + s/2), Offset(cx + s/2, cy), paint);
  }

  @override
  bool shouldRepaint(CubePainter old) => false;
}

class LionPainter extends CustomPainter {
  final Color color;
  LionPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;

    canvas.drawCircle(Offset(cx, cy - 5), 35, paint);
    
    paint.color = color.withOpacity(0.8);
    canvas.drawCircle(Offset(cx, cy - 5), 22, paint);
    
    paint.color = color;
    canvas.drawCircle(Offset(cx - 18, cy - 20), 8, paint);
    canvas.drawCircle(Offset(cx + 18, cy - 20), 8, paint);

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy + 25), width: 50, height: 35),
      const Radius.circular(15),
    );
    canvas.drawRRect(bodyRect, paint);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 20, cy + 35, 10, 15),
        const Radius.circular(5),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx + 10, cy + 35, 10, 15),
        const Radius.circular(5),
      ),
      paint,
    );

    final tailPath = Path()
      ..moveTo(cx + 25, cy + 20)
      ..quadraticBezierTo(cx + 35, cy + 25, cx + 30, cy + 35);
    
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 4;
    canvas.drawPath(tailPath, paint);
  }

  @override
  bool shouldRepaint(LionPainter old) => color != old.color;
}

class RhinoPainter extends CustomPainter {
  final Color color;
  RhinoPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx + 5, cy + 5), width: 65, height: 40),
      const Radius.circular(20),
    );
    canvas.drawRRect(bodyRect, paint);

    final headRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx - 25, cy - 5), width: 30, height: 25),
      const Radius.circular(12),
    );
    canvas.drawRRect(headRect, paint);

    final hornPath = Path()
      ..moveTo(cx - 25, cy - 15)
      ..lineTo(cx - 20, cy - 28)
      ..lineTo(cx - 18, cy - 15)
      ..close();
    canvas.drawPath(hornPath, paint);

    canvas.drawCircle(Offset(cx - 20, cy - 15), 6, paint);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 15, cy + 20, 12, 18),
        const Radius.circular(6),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx + 5, cy + 20, 12, 18),
        const Radius.circular(6),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx + 20, cy + 20, 12, 18),
        const Radius.circular(6),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(RhinoPainter old) => color != old.color;
}

class CamelPainter extends CustomPainter {
  final Color color;
  CamelPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy + 10), width: 55, height: 30),
      const Radius.circular(15),
    );
    canvas.drawRRect(bodyRect, paint);

    canvas.drawCircle(Offset(cx + 5, cy - 5), 18, paint);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 25, cy - 10, 12, 25),
        const Radius.circular(6),
      ),
      paint,
    );

    final headRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx - 22, cy - 15), width: 18, height: 15),
      const Radius.circular(8),
    );
    canvas.drawRRect(headRect, paint);

    canvas.drawCircle(Offset(cx - 20, cy - 22), 4, paint);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 18, cy + 20, 10, 20),
        const Radius.circular(5),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 5, cy + 20, 10, 20),
        const Radius.circular(5),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx + 8, cy + 20, 10, 20),
        const Radius.circular(5),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx + 20, cy + 20, 10, 20),
        const Radius.circular(5),
      ),
      paint,
    );

    final tailPath = Path()
      ..moveTo(cx + 27, cy + 10)
      ..quadraticBezierTo(cx + 35, cy + 15, cx + 33, cy + 25);
    
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;
    canvas.drawPath(tailPath, paint);
  }

  @override
  bool shouldRepaint(CamelPainter old) => color != old.color;
}
