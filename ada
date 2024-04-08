const CardanoWasm = require('@emurgo/cardano-serialization-lib-nodejs');
const fetch = require('node-fetch');

async function sendADA() {
  // 构造发送者的私钥
  const senderPrivateKeyHex = 'YOUR_SENDER_PRIVATE_KEY_HEX';
  const senderPrivateKey = CardanoWasm.PrivateKey.from_hex(senderPrivateKeyHex);

  // 构造接收者地址
  const recipientAddress = 'RECIPIENT_ADDRESS';

  // 设置转账金额
  const amount = 1000000; // 1 ADA (单位为 Lovelace，1 ADA = 1,000,000 Lovelace)

  // 构造输入
  const senderPublicKey = senderPrivateKey.to_public();
  const senderAddress = Buffer.from(senderPublicKey.to_address().to_bytes()).toString('hex');
  const input = {
    address: senderAddress,
    amount: { ...amount },
  };

  // 构造输出
  const output = {
    address: recipientAddress,
    amount: { ...amount },
  };

  // 构造交易
  const transaction = CardanoWasm.TransactionBuilder.new(
    CardanoWasm.LinearFee.new(CardanoWasm.BigNum.from_str('44'), CardanoWasm.BigNum.from_str('155381')),
    CardanoWasm.BigNum.from_str('1000000'),
    CardanoWasm.BigNum.from_str('500000'),
    CardanoWasm.BigNum.from_str('500000'),
  ).add_input(input.address, input.amount).add_output(output.address, output.amount).build();

  // 签名交易
  const signedTransaction = transaction.add_certificate(senderPrivateKey);

  // 序列化交易
  const serializedTransaction = signedTransaction.to_bytes();

  // 发送交易
  const response = await fetch('https://YOUR_CARDANO_NODE:YOUR_PORT', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ transaction: serializedTransaction }),
  });

  const data = await response.json();
  console.log(data);
}

sendADA().catch(console.error);
