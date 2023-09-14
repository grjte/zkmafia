const { Group } = require("@semaphore-protocol/group");

const id1 = BigInt("25110831236485340883110622289796000776970593231140714974687806454846172217346") >> BigInt(8);
const id2 = BigInt("60596803116157862488645418490545665339018127271267691419712763485970375807951") >> BigInt(8);
const id3 = BigInt("52147870430266382320753323984792897648366374664368802333809644606100269853418") >> BigInt(8);

const g = new Group(0, 20);

g.addMember(id1)
g.addMember(id2)
g.addMember(id3)

const index = g.indexOf(id1);

const proof = g.generateMerkleProof(index);


console.log(proof);
