use dep::std::ec::tecurve::affine::{Curve,Point};
use dep::std::ec::consts::te::{BabyJubjub,baby_jubjub};
use dep::std::println;

struct Ciphertext {
    A: Point,
    B: Point
}

fn pub_key(priv_key: Field) -> Point
{
    let bjj: BabyJubjub = baby_jubjub();
    bjj.curve.mul(priv_key,bjj.base8)
}

fn mask(message: Field, random_scalar: Field, pub_key: Point) -> Ciphertext {
    let bjj: BabyJubjub = baby_jubjub();
    let ca = bjj.curve.mul(random_scalar, bjj.base8);
    let pm: Point = bjj.curve.mul(message, bjj.base8);
    let rh = bjj.curve.mul(random_scalar, pub_key);
    Ciphertext {
        A: ca,
        B: bjj.curve.add(rh,pm)
    }
}

fn remask(ciphertext: Ciphertext, random_scalar: Field, pub_key: Point) -> Ciphertext {
    let bjj: BabyJubjub = baby_jubjub();
    let rh = bjj.curve.mul(random_scalar, pub_key);
    let ca = bjj.curve.mul(random_scalar, bjj.base8);
    Ciphertext {
        A: bjj.curve.add(ciphertext.A, ca),
        B: bjj.curve.add(ciphertext.B, rh)
    }
}

fn decryption_key(ciphertext: Ciphertext, priv_key: Field) -> Point {
    let bjj: BabyJubjub = baby_jubjub();
    bjj.curve.mul(priv_key,ciphertext.A)
}


fn combine_keys(key: Point, other_key: Point) -> Point {
    let bjj: BabyJubjub = baby_jubjub();
    bjj.curve.add(key, other_key)
}

fn unmask(ciphertext: Ciphertext, decryption_key: Point) -> Point {
    let bjj: BabyJubjub = baby_jubjub();
    bjj.curve.subtract(ciphertext.B, decryption_key)
}

#[test]
fn test_pub_key() {
    pub_key(200);

    // Uncomment to make test fail
    // main(1, 1);
}

#[test]
fn test_mask() {
    mask(100, 100, pub_key(200));
}

#[test]
fn test_basic() {
    let bjj: BabyJubjub = baby_jubjub();
    let pbk = pub_key(200);
    let c = mask(1, 32, pbk);
    let dk = decryption_key(c, 200);
    let m = unmask(c, dk);
    let pm = bjj.curve.mul(1, bjj.base8);
    assert(m.x == pm.x);
    assert(m.y == pm.y);
}
