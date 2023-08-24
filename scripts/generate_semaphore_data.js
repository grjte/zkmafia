const { Identity } = require("@semaphore-protocol/identity");
const identity = new Identity("zkmafia");
const { trapdoor, nullifier, commitment } = identity;

console.log(`Identity:\n trapdoor: ${trapdoor} \n nullifier ${nullifier} \n commitment ${commitment}`);

const { Group } = require("@semaphore-protocol/group");
const group = new Group(1, 20);

group.addMember(commitment);

const externalNullifier = group.root;
const signal = 1;

console.log(`externalNullifier: ${externalNullifier}\n signal: ${signal}`);

const { generateProof } = require("@semaphore-protocol/proof");

const fullProof = generateProof(identity, group, externalNullifier, signal, {
  zkeyFilePath: "./semaphore.zkey",
  wasmFilePath: "./semaphore.wasm",
}).then((success) => {
console.log(success);
});

