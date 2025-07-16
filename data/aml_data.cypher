// ==========================
// Users
// ==========================
CREATE (:User {id: 1, name: 'Nguyen Van A', isPEP: false, isSanctioned: false});
CREATE (:User {id: 2, name: 'Le Thi B', isPEP: true, isSanctioned: false});
CREATE (:User {id: 3, name: 'Tran Van C', isPEP: false, isSanctioned: true});
CREATE (:User {id: 4, name: 'Pham Thi D', isPEP: false, isSanctioned: false});
CREATE (:User {id: 5, name: 'Vo Van E', isPEP: false, isSanctioned: false});

// ==========================
// Accounts
// ==========================
CREATE (:Account {id: 101, type: 'personal', accountNumber: 'AC001'});
CREATE (:Account {id: 102, type: 'business', accountNumber: 'AC002'});
CREATE (:Account {id: 103, type: 'personal', accountNumber: 'AC003'});
CREATE (:Account {id: 104, type: 'personal', accountNumber: 'AC004'});
CREATE (:Account {id: 105, type: 'personal', accountNumber: 'AC005'});

// ==========================
// Addresses
// ==========================
CREATE (:Address {id: 1, value: '123 Đường A, Hà Nội', country: 'Vietnam'});
CREATE (:Address {id: 2, value: '456 Đường B, TP.HCM', country: 'Vietnam'});
CREATE (:Address {id: 3, value: '789 Street C, Tehran', country: 'Iran'});
CREATE (:Address {id: 4, value: '101 Street D, Pyongyang', country: 'North Korea'});

// ==========================
// PEPs and Sanctions
// ==========================
CREATE (:PEP {id: 1, name: 'Le Thi B'});
CREATE (:Sanction {id: 1, name: 'Tran Van C'});

// ==========================
// Transactions
// ==========================
CREATE (:Transaction {id: 201, amount: 100, date: datetime('2024-07-10T10:00:00'), country: 'Vietnam', isSuspiciousTransaction: false, isConfirmedMoneyLaundering: false});
CREATE (:Transaction {id: 202, amount: 200, date: datetime('2024-07-09T11:00:00'), country: 'Vietnam', isSuspiciousTransaction: false, isConfirmedMoneyLaundering: false});
CREATE (:Transaction {id: 203, amount: 150, date: datetime('2024-07-08T12:00:00'), country: 'Vietnam', isSuspiciousTransaction: false, isConfirmedMoneyLaundering: false});
CREATE (:Transaction {id: 204, amount: 120, date: datetime('2024-07-07T13:00:00'), country: 'Vietnam', isSuspiciousTransaction: true, isConfirmedMoneyLaundering: false});
CREATE (:Transaction {id: 205, amount: 10000, date: datetime('2024-07-11T10:00:00'), country: 'Vietnam', isSuspiciousTransaction: true, isConfirmedMoneyLaundering: false});
CREATE (:Transaction {id: 206, amount: 15000, date: datetime('2024-07-10T11:00:00'), country: 'Vietnam', isSuspiciousTransaction: true, isConfirmedMoneyLaundering: false});
CREATE (:Transaction {id: 207, amount: 20000, date: datetime('2024-07-09T12:00:00'), country: 'Vietnam', isSuspiciousTransaction: true, isConfirmedMoneyLaundering: false});
CREATE (:Transaction {id: 208, amount: 5000, date: datetime('2024-07-11T13:00:00'), country: 'Vietnam', isSuspiciousTransaction: true, isConfirmedMoneyLaundering: true});
CREATE (:Transaction {id: 209, amount: 5000, date: datetime('2024-07-11T14:00:00'), country: 'Vietnam', isSuspiciousTransaction: true, isConfirmedMoneyLaundering: true});
CREATE (:Transaction {id: 210, amount: 5000, date: datetime('2024-07-11T15:00:00'), country: 'Vietnam', isSuspiciousTransaction: true, isConfirmedMoneyLaundering: true});
CREATE (:Transaction {id: 211, amount: 3000, date: datetime('2024-07-11T16:00:00'), country: 'Iran', isSuspiciousTransaction: true, isConfirmedMoneyLaundering: false});
CREATE (:Transaction {id: 212, amount: 4000, date: datetime('2024-07-10T17:00:00'), country: 'North Korea', isSuspiciousTransaction: true, isConfirmedMoneyLaundering: false});

// ==========================
// Relationships: OWNS
// ==========================
MATCH (u:User), (a:Account)
WHERE u.id = 1 AND a.id = 101
CREATE (u)-[:OWNS]->(a);

MATCH (u:User), (a:Account)
WHERE u.id = 2 AND a.id = 102
CREATE (u)-[:OWNS]->(a);

MATCH (u:User), (a:Account)
WHERE u.id = 3 AND a.id = 103
CREATE (u)-[:OWNS]->(a);

MATCH (u:User), (a:Account)
WHERE u.id = 4 AND a.id = 104
CREATE (u)-[:OWNS]->(a);

MATCH (u:User), (a:Account)
WHERE u.id = 5 AND a.id = 105
CREATE (u)-[:OWNS]->(a);

// ==========================
// Relationships: LIVES_AT
// ==========================
MATCH (u:User), (a:Address)
WHERE u.id = 1 AND a.id = 1
CREATE (u)-[:LIVES_AT]->(a);

MATCH (u:User), (a:Address)
WHERE u.id = 2 AND a.id = 2
CREATE (u)-[:LIVES_AT]->(a);

MATCH (u:User), (a:Address)
WHERE u.id = 3 AND a.id = 3
CREATE (u)-[:LIVES_AT]->(a);

MATCH (u:User), (a:Address)
WHERE u.id = 4 AND a.id = 4
CREATE (u)-[:LIVES_AT]->(a);

// ==========================
// Relationships: IS (PEP)
// ==========================
MATCH (u:User), (p:PEP)
WHERE u.id = 2 AND p.id = 1
CREATE (u)-[:IS]->(p);

// ==========================
// Relationships: IS_IN (Sanction)
// ==========================
MATCH (u:User), (s:Sanction)
WHERE u.id = 3 AND s.id = 1
CREATE (u)-[:IS_IN]->(s);

// ==========================
// Relationships: FROM_ACCOUNT & TO_ACCOUNT
// ==========================
MATCH (t:Transaction), (a:Account)
WHERE t.id = 201 AND a.id = 101
CREATE (t)-[:FROM_ACCOUNT]->(a);
MATCH (t:Transaction), (a:Account)
WHERE t.id = 201 AND a.id = 102
CREATE (t)-[:TO_ACCOUNT]->(a);

MATCH (t:Transaction), (a:Account)
WHERE t.id = 202 AND a.id = 101
CREATE (t)-[:FROM_ACCOUNT]->(a);
MATCH (t:Transaction), (a:Account)
WHERE t.id = 202 AND a.id = 102
CREATE (t)-[:TO_ACCOUNT]->(a);

MATCH (t:Transaction), (a:Account)
WHERE t.id = 203 AND a.id = 101
CREATE (t)-[:FROM_ACCOUNT]->(a);
MATCH (t:Transaction), (a:Account)
WHERE t.id = 203 AND a.id = 102
CREATE (t)-[:TO_ACCOUNT]->(a);

MATCH (t:Transaction), (a:Account)
WHERE t.id = 204 AND a.id = 101
CREATE (t)-[:FROM_ACCOUNT]->(a);
MATCH (t:Transaction), (a:Account)
WHERE t.id = 204 AND a.id = 102
CREATE (t)-[:TO_ACCOUNT]->(a);

MATCH (t:Transaction), (a:Account)
WHERE t.id = 205 AND a.id = 102
CREATE (t)-[:FROM_ACCOUNT]->(a);
MATCH (t:Transaction), (a:Account)
WHERE t.id = 205 AND a.id = 105
CREATE (t)-[:TO_ACCOUNT]->(a);

MATCH (t:Transaction), (a:Account)
WHERE t.id = 206 AND a.id = 103
CREATE (t)-[:FROM_ACCOUNT]->(a);
MATCH (t:Transaction), (a:Account)
WHERE t.id = 206 AND a.id = 105
CREATE (t)-[:TO_ACCOUNT]->(a);

MATCH (t:Transaction), (a:Account)
WHERE t.id = 207 AND a.id = 104
CREATE (t)-[:FROM_ACCOUNT]->(a);
MATCH (t:Transaction), (a:Account)
WHERE t.id = 207 AND a.id = 105
CREATE (t)-[:TO_ACCOUNT]->(a);

MATCH (t:Transaction), (a:Account)
WHERE t.id = 208 AND a.id = 101
CREATE (t)-[:FROM_ACCOUNT]->(a);
MATCH (t:Transaction), (a:Account)
WHERE t.id = 208 AND a.id = 102
CREATE (t)-[:TO_ACCOUNT]->(a);

MATCH (t:Transaction), (a:Account)
WHERE t.id = 209 AND a.id = 102
CREATE (t)-[:FROM_ACCOUNT]->(a);
MATCH (t:Transaction), (a:Account)
WHERE t.id = 209 AND a.id = 103
CREATE (t)-[:TO_ACCOUNT]->(a);

MATCH (t:Transaction), (a:Account)
WHERE t.id = 210 AND a.id = 103
CREATE (t)-[:FROM_ACCOUNT]->(a);
MATCH (t:Transaction), (a:Account)
WHERE t.id = 210 AND a.id = 101
CREATE (t)-[:TO_ACCOUNT]->(a);

MATCH (t:Transaction), (a:Account)
WHERE t.id = 211 AND a.id = 104
CREATE (t)-[:FROM_ACCOUNT]->(a);
MATCH (t:Transaction), (a:Account)
WHERE t.id = 211 AND a.id = 103
CREATE (t)-[:TO_ACCOUNT]->(a);

MATCH (t:Transaction), (a:Account)
WHERE t.id = 212 AND a.id = 105
CREATE (t)-[:FROM_ACCOUNT]->(a);
MATCH (t:Transaction), (a:Account)
WHERE t.id = 212 AND a.id = 103
CREATE (t)-[:TO_ACCOUNT]->(a);