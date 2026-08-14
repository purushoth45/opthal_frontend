import 'package:ophthal_vivaedge/models/answer_block_model.dart';
import 'package:ophthal_vivaedge/models/question_model.dart';
import 'package:ophthal_vivaedge/repositories/question_repository.dart';

class MockQuestionRepository implements QuestionRepository {
  final List<QuestionModel> _questions = [
    QuestionModel(
      id: 1,
      topic: 'Cornea & Lens',
      questionText: 'Causes of gradual painless loss of vision',
      answerBlocks: [
        AnswerBlockModel.heading(
          heading: 'Common Causes of Gradual Painless Loss of Vision',
          displayOrder: 1,
        ),
        AnswerBlockModel.text(
          text: '1. Cataract (most common cause worldwide)\n'
              '2. Primary Open Angle Glaucoma (POAG)\n'
              '3. Diabetic Retinopathy (Non-proliferative & Proliferative)\n'
              '4. Age-Related Macular Degeneration (AMD - Dry & Wet)\n'
              '5. Uncorrected Refractive Errors (Myopia, Hypermetropia, Astigmatism)\n'
              '6. Corneal Dystrophies & Degenerations\n'
              '7. Optic Atrophy',
          displayOrder: 2,
        ),
      ],
    ),
    QuestionModel(
      id: 2,
      topic: 'Glaucoma & Uvea',
      questionText: 'Causes of acute painful loss of vision',
      answerBlocks: [
        AnswerBlockModel.heading(
          heading: 'Ophthalmic Emergencies Presenting with Painful Vision Loss',
          displayOrder: 1,
        ),
        AnswerBlockModel.text(
          text: '1. Primary Angle Closure Glaucoma (Acute attack with marked IOP elevation)\n'
              '2. Acute Anterior Uveitis (Iridocyclitis)\n'
              '3. Bacterial / Fungal Corneal Ulcer (Keratitis)\n'
              '4. Endophthalmitis / Panophthalmitis\n'
              '5. Optic Neuritis (Pain aggravated by eye movements)\n'
              '6. Ocular Trauma (Chemical burns, perforating injuries)',
          displayOrder: 2,
        ),
      ],
    ),
    QuestionModel(
      id: 3,
      topic: 'Strabismus & Neuro-Ophthalmology',
      questionText: 'Difference between monocular and binocular diplopia',
      answerBlocks: [
        AnswerBlockModel.text(
          text: 'Diplopia → Doubling of images. It is classified into Uniocular (Monocular) and Binocular diplopia depending on ocular closure tests.',
          displayOrder: 1,
        ),
        AnswerBlockModel.table(
          columns: ['Uniocular (Monocular)', 'Binocular'],
          rows: [
            [
              'When the abnormal eye is closed, diplopia disappears but if the normal eye is closed, diplopia persists.',
              'When either eye closes, diplopia disappears immediately.'
            ],
            [
              'Persists when looking through a pinhole if caused by optical aberrations.',
              'Disappears when looking through a pinhole.'
            ],
            [
              'Ocular Causes:\n• Cataract (Incipient stage)\n• Subluxated lens\n• Double pupil (Iridodialysis)\n• Keratoconus / Uncorrected astigmatism',
              'Extraocular Causes:\n• Extraocular muscle paresis (3rd, 4th, 6th nerve palsy)\n• Restrictive squint (Thyroid eye disease, Blowout fracture)\n• Myasthenia gravis'
            ],
          ],
          displayOrder: 2,
        ),
      ],
    ),
    QuestionModel(
      id: 4,
      topic: 'Lens & Glaucoma Clinical Tests',
      questionText: 'Causes of coloured haloes and Fincham\'s test',
      answerBlocks: [
        AnswerBlockModel.heading(
          heading: 'Causes of Coloured Haloes Around Light',
          displayOrder: 1,
        ),
        AnswerBlockModel.text(
          text: 'Coloured haloes result from diffraction of light by particulate matter or epithelial edema in optical media.\n\n'
              '1. Acute Angle-Closure Glaucoma: Stagnant corneal epithelial edema (haloes have red outermost ring, violet innermost ring).\n'
              '2. Early Stage Cataract: Chromatic aberration in swollen lens fibers.\n'
              '3. Mucus Flakes: Mucopurulent conjunctivitis (haloes disappear on blinking).',
          displayOrder: 2,
        ),
        AnswerBlockModel.heading(
          heading: 'Fincham\'s Test',
          displayOrder: 3,
        ),
        AnswerBlockModel.text(
          text: 'Used to clinically differentiate haloes of glaucoma from early cataract:\n\n'
              '• Procedure: A stenopaeic slit is passed slowly across the pupil.\n'
              '• Cataract Halo: The halo breaks up into spectrum colors and moves as the slit moves.\n'
              '• Glaucomatous Halo: The halo remains intact and merely diminishes in intensity without splitting.',
          displayOrder: 4,
        ),
      ],
    ),
  ];

  @override
  Future<List<QuestionModel>> getQuestions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List<QuestionModel>.from(_questions);
  }

  @override
  Future<QuestionModel> getQuestionById(int id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _questions.firstWhere(
      (q) => q.id == id,
      orElse: () => throw Exception('Question with ID $id not found'),
    );
  }

  @override
  Future<QuestionModel> createQuestion(QuestionModel question) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newId = _questions.isEmpty ? 1 : (_questions.map((q) => q.id).reduce((a, b) => a > b ? a : b) + 1);
    final created = question.copyWith(id: newId);
    _questions.add(created);
    return created;
  }

  @override
  Future<QuestionModel> updateQuestion(int id, QuestionModel question) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _questions.indexWhere((q) => q.id == id);
    if (index != -1) {
      _questions[index] = question.copyWith(id: id);
      return _questions[index];
    }
    throw Exception('Question with ID $id not found');
  }

  @override
  Future<void> deleteQuestion(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _questions.removeWhere((q) => q.id == id);
  }
}
