var AzizaChecker = artifacts.require("./AzizaChecker.sol");
var AzizaLedger = artifacts.require("./AzizaLedger.sol");

module.exports = function(deployer) {
  deployer.deploy( AzizaChecker, 
                  '0xf423d00aadefa8143c32f8a4b4cd00af5a2fc5ad',
                  '0x6ed175aecabf6e53c4f60e8283942901efda6836',
                  '0xbc55f0976d4b560e92da181799584da34873d5ca'
                  ).then(function() {
                    return deployer.deploy( AzizaLedger, 
                      '0xf423d00aadefa8143c32f8a4b4cd00af5a2fc5ad',
                      '0x6ed175aecabf6e53c4f60e8283942901efda6836',
                      '0xbc55f0976d4b560e92da181799584da34873d5ca', 
                      AzizaChecker.address,
                      'AZCoin', 'AZC');
                  });              
};






