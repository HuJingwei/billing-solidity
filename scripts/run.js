const fs = require('fs')
const Web3 = require('web3')

const {endpoint, account, cost} = require('./config.json')

const attAdd = "0x204aea11fa34a0ca807d2692899650416bf8e0df";
const contractAddress = "0x832fc6b937d9b3f4617bc47ee5931161196c5825";
const owner = "0x3ae88fe370c39384fc16da2c9e768cf5d2495b48";
const beneficiary = "0xca9f427df31a1f5862968fad1fe98c0a9ee068c4";
this.web3 =  new Web3(new Web3.providers.HttpProvider(endpoint));
this.web3.personal.unlockAccount(account.address, account.password);
const abiFile = fs.readFileSync('../build/contracts/DbotBilling.json');
const attAbi = fs.readFileSync('../build/contracts/ATT.json');
const jsonString = JSON.parse(abiFile);
const jsonString2 = JSON.parse(attAbi);
this.billContractsAbi = jsonString.abi;
this.attContractsAbi = jsonString2.abi;
const contract = this.web3.eth.contract(this.billContractsAbi);
this.bill = contract.at(contractAddress);
const attContract = this.web3.eth.contract(this.attContractsAbi);
this.att = attContract.at(attAdd);
// console.log(this.att);
// this.att.generateTokens.sendTransaction("0x3ae88fe370c39384fc16da2c9e768cf5d2495b48",33,{from:"0x3ae88fe370c39384fc16da2c9e768cf5d2495b48",gas:3000000});
// this.att.approve.sendTransaction("0x832fc6b937d9b3f4617bc47ee5931161196c5825", 100,{from:"0x3ae88fe370c39384fc16da2c9e768cf5d2495b48",gas:4712387});
// console.log(this.att.allowance("0x3ae88fe370c39384fc16da2c9e768cf5d2495b48","0x832fc6b937d9b3f4617bc47ee5931161196c5825",{from:"0x3ae88fe370c39384fc16da2c9e768cf5d2495b48",gas:3000000}))
// console.log(this.att.balanceOf("0x3ae88fe370c39384fc16da2c9e768cf5d2495b48"))
// this.bill.billing(owner);
// this.bill.deductFee();
