import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/firebase/remote_config_service.dart';
import '../../design_system/tds.dart';
import '../../design_system/components/toss_button.dart';
import '../../design_system/motion/fade_in_up.dart';

class _SoulSyncLayout {
  static const double buttonSize = 80.0; // LR-002
  static const double buttonSpacing = spaceXLarge; // LR-003, Was 40.0
  static const double dividerHeight = 2.0; // LR-005
}

class SoulSyncScreen extends StatefulWidget {
  const SoulSyncScreen({super.key});

  @override
  State<SoulSyncScreen> createState() => _SoulSyncScreenState();
}

class _SoulSyncScreenState extends State<SoulSyncScreen> {
  // T007: State variables
  List<String>? _questions; // Nullable to represent loading state
  int _currentIndex = 0;
  Map<String, bool?> _currentAnswers = {'A': null, 'B': null};
  List<Map<String, bool>> _completedAnswers = [];
  bool _showResult = false;

  // T024: Optional nudge timer
  Timer? _nudgeTimer;

  // T013: Match calculation
  int get _matches => _completedAnswers.where((r) => r['A'] == r['B']).length;

  int get _percent => _completedAnswers.isEmpty
      ? 0
      : (_matches / _completedAnswers.length * 100).round();

  // T008: initState with question shuffle
  @override
  void initState() {
    super.initState();
    _initGame();
  }

  @override
  void dispose() {
    _nudgeTimer?.cancel();
    super.dispose();
  }

  void _initGame() {
    _nudgeTimer?.cancel();

    // Fetch questions from Remote Config
    final allQuestions = RemoteConfigService.instance.soulSyncQuestions;

    // C1: Validate question pool has sufficient questions
    assert(
      allQuestions.length >= 5,
      'Question pool must have at least 5 questions',
    );
    final shuffled = List<String>.from(allQuestions)..shuffle();
    _questions = shuffled.take(5).toList();
    _currentIndex = 0;
    _currentAnswers = {'A': null, 'B': null};
    _completedAnswers = [];
    _showResult = false;
  }

  // T024: Start nudge timer when one player answers
  void _startNudgeTimer() {
    _nudgeTimer?.cancel();
    _nudgeTimer = Timer(const Duration(seconds: 10), () {
      // Only nudge if still waiting for other player
      if (_currentAnswers['A'] != null && _currentAnswers['B'] == null ||
          _currentAnswers['A'] == null && _currentAnswers['B'] != null) {
        HapticFeedback.lightImpact();
      }
    });
  }

  // T010 & T011: Answer handling with auto-advance
  void _onAnswer(String playerId, bool isO) {
    setState(() {
      _currentAnswers[playerId] = isO;

      // T011: Check if both players answered
      if (_currentAnswers['A'] != null && _currentAnswers['B'] != null) {
        // Cancel nudge timer since both answered
        _nudgeTimer?.cancel();

        // Save this round's answers
        _completedAnswers.add({
          'A': _currentAnswers['A']!,
          'B': _currentAnswers['B']!,
        });

        // Check if game is complete
        if (_completedAnswers.length >= 5) {
          _showResult = true;
        } else {
          // Move to next question
          _currentIndex++;
          _currentAnswers = {'A': null, 'B': null};
        }
      } else {
        // T024: One player answered, start nudge timer
        _startNudgeTimer();
      }
    });
  }

  // T009: Split-screen layout build method
  @override
  Widget build(BuildContext context) {
    // T014: Show result when complete
    if (_showResult) {
      return _buildResultScreen();
    }

    // Handle loading state
    if (_questions == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final currentQuestion = _questions![_currentIndex];

    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top player area (rotated 180°)
            Expanded(
              child: Transform.rotate(
                angle: pi, // 180 degrees
                child: _PlayerArea(
                  playerId: 'A',
                  question: currentQuestion,
                  answered: _currentAnswers['A'],
                  isWaiting: _currentAnswers['A'] != null,
                  onAnswer: (isO) => _onAnswer('A', isO),
                ),
              ),
            ),
            // Divider (LR-005)
            Container(
              height: _SoulSyncLayout.dividerHeight,
              color: cs.outlineVariant.withOpacity(0.3),
              margin: const EdgeInsets.symmetric(horizontal: spaceLarge),
            ),
            // Progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: spaceXSmall),
              child: Text(
                '${_currentIndex + 1} / 5',
                style: bodyText(cs).copyWith(color: cs.onSurfaceVariant),
              ),
            ),
            // Bottom player area (normal orientation)
            Expanded(
              child: _PlayerArea(
                playerId: 'B',
                question: currentQuestion,
                answered: _currentAnswers['B'],
                isWaiting: _currentAnswers['B'] != null,
                onAnswer: (isO) => _onAnswer('B', isO),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // T015: Result message getter with 3-tier logic
  String get _resultMessage {
    if (_percent >= 80) return '천생연분!';
    if (_percent >= 50) return '꽤 맞네?';
    return '이건 좀...';
  }

  // T020: Result emoji based on tier
  String get _resultEmoji {
    if (_percent >= 80) return '🎉';
    if (_percent >= 50) return '😊';
    return '😅';
  }

  // T017: Tiered haptic feedback
  void _triggerResultHaptic() {
    if (_percent >= 80) {
      HapticFeedback.vibrate(); // 축하!
    } else if (_percent >= 50) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }
  }

  // T018: Reset game with new shuffled questions
  void _restartGame() {
    setState(() {
      _initGame();
    });
    HapticFeedback.mediumImpact();
  }

  // T019: Navigate back to IntroScreen
  void _goHome() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop();
  }

  // T014 + T016: Polished result screen with FadeInUp
  Widget _buildResultScreen() {
    // T017: Trigger haptic on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerResultHaptic();
    });

    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        color: cs.surface,
        child: SafeArea(
          child: Center(
            child: FadeInUp(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: spaceXLarge),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // T020: Emoji
                    Text(_resultEmoji, style: const TextStyle(fontSize: 80)),
                    const SizedBox(height: spaceMedium),
                    // T015: Result message
                    Text(
                      _resultMessage,
                      style: titleBig(cs).copyWith(
                        fontSize: 36,
                        color: _percent >= 80
                            ? cs.primary
                            : _percent >= 50
                            ? cs.tertiary
                            : cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: spaceMedium),
                    // Match count
                    Text('$_matches / 5 일치 ($_percent%)', style: bodyText(cs)),
                    const SizedBox(height: spaceXLarge),
                    // T018: 다시하기 버튼
                    TossButton(
                      text: '다시하기',
                      onTap: _restartGame,
                    ),
                    const SizedBox(height: spaceSmall),
                    // T019: 홈으로 버튼
                    TossButton(
                      text: '홈으로',
                      color: cs.onSurfaceVariant,
                      onTap: _goHome,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// T006: 플레이어 영역 위젯
class _PlayerArea extends StatelessWidget {
  final String playerId;
  final String question;
  final bool? answered; // null = not answered, true = O, false = X
  final bool isWaiting;
  final void Function(bool isO) onAnswer;

  const _PlayerArea({
    required this.playerId,
    required this.question,
    required this.answered,
    required this.isWaiting,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: spaceLarge,
        vertical: spaceMedium,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 질문 텍스트
          Text(
            question,
            textAlign: TextAlign.center,
            style: titleMedium(cs).copyWith(fontSize: 18),
          ),
          const SizedBox(height: spaceLarge),
          // 대기 중이면 대기 메시지 표시
          if (isWaiting)
            Text('기다리는 중~', style: bodyText(cs).copyWith(color: cs.tertiary))
          else
            // O/X 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildOXButton(
                  context: context,
                  isO: true,
                  disabled: answered != null,
                  onTap: () => onAnswer(true),
                ),
                const SizedBox(width: _SoulSyncLayout.buttonSpacing),
                _buildOXButton(
                  context: context,
                  isO: false,
                  disabled: answered != null,
                  onTap: () => onAnswer(false),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildOXButton({
    required BuildContext context,
    required bool isO,
    required VoidCallback onTap,
    bool disabled = false,
  }) {
    final cs = Theme.of(context).colorScheme;
    final color = isO ? cs.secondary : cs.primary;
    // C5: Semantics wrapper for future accessibility (AR-006)
    return Semantics(
      label: isO ? '동의 버튼' : '비동의 버튼',
      button: true,
      enabled: !disabled,
      child: GestureDetector(
        onTap: disabled
            ? null
            : () {
                HapticFeedback.mediumImpact();
                onTap();
              },
        child: Opacity(
          opacity: disabled ? 0.4 : 1.0,
          child: Container(
            width: _SoulSyncLayout.buttonSize,
            height: _SoulSyncLayout.buttonSize,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                isO ? 'O' : 'X',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 6. PAINTER (High Performance Graphics)
// -----------------------------------------------------------------------------
