const deriveKey = async (password, salt) => {
  const algorithm = {name: "AES-GCM", length: 256};
  const keyUsage = ["encrypt", "decrypt"];
  const baseKey = await window.crypto.subtle.importKey(
    "raw", 
    new TextEncoder().encode(password), 
    {name: "PBKDF2"}, 
    false, 
    ["deriveKey"]
  );
  return window.crypto.subtle.deriveKey(
    {
      "name": "PBKDF2",
      "salt": new TextEncoder().encode(salt),
      "iterations": Math.pow(10, 5),
      "hash": "SHA-256"
    },
    baseKey,
    algorithm,
    false,
    keyUsage
  );
}

const arrayBufferToBase64 = (buffer) => {
  return btoa(Array.from(buffer).map(c => String.fromCharCode(c)).join(''));
}

const base64toArrayBuffer = (b64str) => {
  return Uint8Array.from(atob(b64str), c => c.charCodeAt(0));
}

const encryptedDataToString = (data) => {
  return btoa(JSON.stringify({
    ciphertext: arrayBufferToBase64(new Uint8Array(data.ciphertext)),
    iv: arrayBufferToBase64(data.iv),
    salt: arrayBufferToBase64(data.salt),
    v: data.v
  }))
}

const stringToEncryptedData = (data) => {
  const { ciphertext, iv, salt, v } = JSON.parse(atob(data));
  return {
    ciphertext: base64toArrayBuffer(ciphertext),
    iv: base64toArrayBuffer(iv),
    salt: base64toArrayBuffer(salt),
    v: v
  }
}

const encrypt = async (data, password) => {
  const salt = window.crypto.getRandomValues(new Uint8Array(16));
  const iv = window.crypto.getRandomValues(new Uint8Array(12));
  const key = await deriveKey(password, salt);
  const encodedtext = new TextEncoder().encode(data);
  const ciphertext = await window.crypto.subtle.encrypt(
    { name: "AES-GCM", iv: iv },
    key,
    encodedtext
  );
  return encryptedDataToString({
    ciphertext: ciphertext,
    iv: iv,
    salt: salt,
    v: 1
  });
}

const decrypt = async (data, password) => {
  const { ciphertext, iv, salt } = stringToEncryptedData(data);
  const key = await deriveKey(password, salt);
  const decrypted = await window.crypto.subtle.decrypt(
    { name: "AES-GCM", iv: iv },
    key,
    ciphertext
  );
  return new TextDecoder().decode(decrypted);
}

const test = async (data = "Hello World!", password = "password") => {
  const encrypted = await encrypt(data, password);
  const decrypted = await decrypt(encrypted, password);
  if (data !== decrypted) {
    throw new Error("Decrypted test data does not match original test data");
  } else {
    console.info("Decrypted test data matches original test data");
  }
  return [encrypted, decrypted];
}

const cryptoUtils = Object.freeze({
  encrypt,
  decrypt,
  test
});

window.cryptoUtils = cryptoUtils;

export default cryptoUtils;