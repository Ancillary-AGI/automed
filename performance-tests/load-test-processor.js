const faker = require('faker');

// Authentication token storage
let authTokens = [];

module.exports = {
  setAuthHeader,
  $randomEmail,
  $randomPatientId,
  $randomHospitalId,
  $randomDoctorId,
  $randomMedicalQuery,
  $randomSymptom,
  $randomInt,
  $randomFloat,
  $now,
  $uuid,
  $futureTimestamp,
  $generateLargePatientDataset
};

function setAuthHeader(context, events, done) {
  // Set authentication header if token exists
  if (context.vars.authToken) {
    context.vars.authHeader = `Bearer ${context.vars.authToken}`;
  }
  return done();
}

function $randomEmail() {
  return faker.internet.email();
}

function $randomPatientId() {
  // Generate realistic patient IDs
  const patientIds = [
    'PAT001', 'PAT002', 'PAT003', 'PAT004', 'PAT005',
    'PAT006', 'PAT007', 'PAT008', 'PAT009', 'PAT010',
    'PAT011', 'PAT012', 'PAT013', 'PAT014', 'PAT015',
    'PAT016', 'PAT017', 'PAT018', 'PAT019', 'PAT020'
  ];
  return patientIds[Math.floor(Math.random() * patientIds.length)];
}

function $randomHospitalId() {
  const hospitalIds = [
    'HOSP001', 'HOSP002', 'HOSP003', 'HOSP004', 'HOSP005'
  ];
  return hospitalIds[Math.floor(Math.random() * hospitalIds.length)];
}

function $randomDoctorId() {
  const doctorIds = [
    'DOC001', 'DOC002', 'DOC003', 'DOC004', 'DOC005',
    'DOC006', 'DOC007', 'DOC008', 'DOC009', 'DOC010'
  ];
  return doctorIds[Math.floor(Math.random() * doctorIds.length)];
}

function $randomMedicalQuery() {
  const queries = [
    "What are the symptoms of diabetes?",
    "How to treat hypertension?",
    "What medications are used for heart disease?",
    "Explain the side effects of aspirin",
    "What is the normal blood pressure range?",
    "How to manage chronic pain?",
    "What are the signs of infection?",
    "Explain the treatment for pneumonia",
    "What is the recommended dosage for insulin?",
    "How to prevent cardiovascular disease?"
  ];
  return queries[Math.floor(Math.random() * queries.length)];
}

function $randomSymptom() {
  const symptoms = [
    "fever", "headache", "nausea", "fatigue", "dizziness",
    "chest pain", "shortness of breath", "cough", "sore throat",
    "abdominal pain", "back pain", "joint pain", "muscle aches",
    "skin rash", "swelling", "numbness", "tingling", "blurred vision"
  ];
  return symptoms[Math.floor(Math.random() * symptoms.length)];
}

function $randomInt(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function $randomFloat(min, max) {
  return (Math.random() * (max - min) + min).toFixed(1);
}

function $now() {
  return new Date().toISOString();
}

function $uuid() {
  return faker.datatype.uuid();
}

function $futureTimestamp() {
  const future = new Date();
  future.setHours(future.getHours() + Math.floor(Math.random() * 168)); // Next week
  return future.toISOString();
}

function $generateLargePatientDataset() {
  const patients = [];
  const count = Math.floor(Math.random() * 100) + 50; // 50-150 patients
  
  for (let i = 0; i < count; i++) {
    patients.push({
      firstName: faker.name.firstName(),
      lastName: faker.name.lastName(),
      email: faker.internet.email(),
      phone: faker.phone.phoneNumber(),
      dateOfBirth: faker.date.past(80, new Date(2005, 0, 1)).toISOString().split('T')[0],
      gender: faker.random.arrayElement(['male', 'female', 'other']),
      address: {
        street: faker.address.streetAddress(),
        city: faker.address.city(),
        state: faker.address.state(),
        zipCode: faker.address.zipCode(),
        country: faker.address.country()
      },
      emergencyContact: {
        name: faker.name.findName(),
        phone: faker.phone.phoneNumber(),
        relationship: faker.random.arrayElement(['spouse', 'parent', 'sibling', 'child', 'friend'])
      },
      medicalHistory: {
        allergies: faker.random.arrayElements(['penicillin', 'peanuts', 'shellfish', 'latex'], Math.floor(Math.random() * 3)),
        chronicConditions: faker.random.arrayElements(['diabetes', 'hypertension', 'asthma', 'arthritis'], Math.floor(Math.random() * 2)),
        medications: faker.random.arrayElements(['aspirin', 'metformin', 'lisinopril', 'albuterol'], Math.floor(Math.random() * 3))
      },
      insurance: {
        provider: faker.company.companyName(),
        policyNumber: faker.random.alphaNumeric(10),
        groupNumber: faker.random.alphaNumeric(8)
      }
    });
  }
  
  return patients;
}