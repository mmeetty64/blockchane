pragma solidity ^0.8.7;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract NewToken is ERC20("cmonToken", "CMN") {
    address admin =  msg.sender;
    address investor1 = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
    address investor2 = 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db;
    address investor3 = 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB;
    address[] public whiteList;
    address[] requestWhiteList;
    uint stage1 = block.timestamp;
    uint stage2 = stage1 + 3 minutes;
    uint stage3 = stage2 + 2 minutes;
    uint stage4 = stage3 + 5 minutes;

    constructor() public {
        uint256 decim = 10**decimals();
        _mint(admin, 650000 * decim);
        _mint(investor1, 200000 * decim);
        _mint(investor2, 100000 * decim);
        _mint(investor3, 50000 * decim);

    }

    struct Account{
         string login;
         uint balance;
         address wallet;
         bool presWhiteList;
    }

    mapping (address => Account) public  acc;
    mapping (string => address) public add;
    mapping (address => string) public pass;

    function registration(string memory _login, string memory _password) public{
         require(acc[msg.sender].wallet == address(0), "Account already registered");
         acc[msg.sender] = Account(_login, balanceOf(msg.sender), msg.sender, false);
         add[_login] = msg.sender;
         pass[msg.sender] = _password;
    }
     
    function authorisation(string memory _login, string memory _password) public view returns (Account memory){
         require(keccak256(abi.encode(acc[add[_login]].login)) == keccak256(abi.encode(_login)), "Invalid login");
         require(keccak256(abi.encode(pass[add[_login]])) == keccak256(abi.encode(_password)));
         return acc[add[_login]];
    }

    function reqWhiteList() public {
        requestWhiteList.push(msg.sender);
    } 

    function addWhiteList(bool _answer, uint _idRequest) public onlyAdmin{
        if(_answer == true){
            whiteList.push(requestWhiteList[_idRequest]);
            delete requestWhiteList[_idRequest];
            acc[requestWhiteList[_idRequest]].presWhiteList = true;
        }else{
            delete requestWhiteList[_idRequest];
        }
    }

    
    modifier onlyAdmin{
        require(msg.sender == admin,  "You'r not a admin");
        _;
    }
    modifier onlyUser{
        require(acc[msg.sender].wallet != address(0), "You don't have an account");
        _;
    }
}
