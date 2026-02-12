String dbToUiType(String db) {
  return {
    'INTERNSHIP': 'Internship',
    'TRAINING': 'Training',
    'JOB': 'Job',
    'VOLUNTEER': 'Volunteer',
    'COMPETITION': 'Competition',
  }[db] ?? 'Internship';
}

String uiToDbType(String ui) {
  return {
    'Internship': 'INTERNSHIP',
    'Training': 'TRAINING',
    'Job': 'JOB',
    'Volunteer': 'VOLUNTEER',
    'Competition': 'COMPETITION',
  }[ui] ?? 'INTERNSHIP';
}
