pragma solidity ^0.8.7;

import "./ERC20.sol";

contract NewToken is ERC20("cmonToken", "CMN") {
    constructor() public {
        _mint(msg.sender, 1000000);
    }

     struct Account{
         string login;
         address wallet;
     }

     mapping (address => Account) public  acc;
     mapping (string => address) public add;
     mapping (address => string) public pass;

     function registration(string memory _login, string memory _password) public{
         require(acc[msg.sender].wallet == address(0), "Account already registered");
         acc[msg.sender] = Account(_login, msg.sender);
         add[_login] = msg.sender;
         pass[msg.sender] = _password;
     }
     
     function authorisation(string memory _login, string memory _password) public view returns (Account memory){
         require(keccak256(abi.encode(acc[add[_login]].login)) == keccak256(abi.encode(_login)), "Invalid login");
         require(keccak256(abi.encode(pass[add[_login]])) == keccak256(abi.encode(_password)));
         return acc[add[_login]];
     }

     function issuanceToInvestors(address _firstInvestior, address _secondInvestor, address _thirdInvestor) public {
         transfer(_firstInvestior, 200000);
         transfer(_secondInvestor, 100000);
         transfer(_thirdInvestor, 50000);
     }
}
