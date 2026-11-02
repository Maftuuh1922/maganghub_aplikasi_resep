import 'package:flutter_test/flutter_test.dart';
import 'package:pantom_meals/presentation/widgets/recipe_detail_sheet.dart';

void main() {
  test('instruction parser removes duplicated step prefixes', () {
    expect(
      parseInstructionSteps('STEP 1\n1. Mix ingredients\n2) Bake gently'),
      ['Mix ingredients', 'Bake gently'],
    );
  });

  test('instruction parser handles empty instructions', () {
    expect(parseInstructionSteps(null), isEmpty);
    expect(parseInstructionSteps('  \r\n '), isEmpty);
  });

  test('instruction parser groups a long one-paragraph response', () {
    final steps = parseInstructionSteps(
      'First step. Second step. Third step. Fourth step. Fifth step. Sixth step.',
    );
    expect(steps, hasLength(2));
    expect(steps.first, contains('Third step'));
    expect(steps.last, contains('Sixth step'));
  });
}
