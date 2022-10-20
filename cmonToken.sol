pragma solidity ^0.8.7;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract NewToken is ERC20("cmonToken", "CMN") {
    address admin =  msg.sender;
    address investor1 = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
    address investor2 = 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db;
    address investor3 = 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB;
    address developer1 = 0x617F2E2fD72FD9D5503197092aC168c91465E7f2;
    address VIPPerson = 0x17F6AD8Ef982297579C203069C1DbfFE4348c372;
    address[] public whiteList;
    address[] requestWhiteList;
    uint stage1 = block.timestamp;
    uint stage2 = block.timestamp + 3 minutes;
    uint stage3 = block.timestamp + 5 minutes;
    uint stage4 = block.timestamp + 10 minutes;
    uint volClosedSale = 200000*(10**decimals());
    uint dec = 10**decimals();
    uint priceToken = 0 ether;

    constructor() public {
        uint256 decim = 10**decimals();
        _mint(admin, 650000 * decim);
        _mint(investor1, 200000 * decim);
        _mint(investor2, 100000 * decim);
        _mint(investor3, 50000 * decim);

        acc[investor1] = Account("investor1", balanceOf(investor1), investor1, false, false);
        add["investor1"] = investor1;
        pass[investor1] = "123";

        acc[investor2] = Account("investor2", balanceOf(investor2), investor2, false, false);
        add["investor2"] = investor2;
        pass[investor2] = "123";

        acc[investor3] = Account("investor3", balanceOf(investor3), investor3, false, false);
        add["investor3"] = investor3;
        pass[investor3] = "123";

        acc[developer1] = Account("dev1", balanceOf(developer1), developer1, false, true);
        add["dev1"] = developer1;
        pass[developer1] = "123";
        devTake[developer1] = 40000;

        acc[VIPPerson] = Account("vip", balanceOf(VIPPerson), VIPPerson, true, false);
        add["vip"] = VIPPerson;
        pass[VIPPerson] = "123";
        whiteList.push(VIPPerson);
    }

    struct Account{
         string login;
         uint balance;
         address wallet;
         bool presWhiteList;
         bool deveveloper;
    }

    mapping (address => Account) public  acc;
    mapping (string => address) public add;
    mapping (address => string) public pass;
    mapping (address => uint) public devTake; 

    function registration(string memory _login, string memory _password) public{
         require(acc[msg.sender].wallet == address(0), "Account already registered");
         acc[msg.sender] = Account(_login, balanceOf(msg.sender), msg.sender, false, false);
         add[_login] = msg.sender;
         pass[msg.sender] = _password;
    }
     
    function authorisation(string memory _login, string memory _password) public view returns (Account memory){
         require(keccak256(abi.encode(acc[add[_login]].login)) == keccak256(abi.encode(_login)), "Invalid login");
         require(keccak256(abi.encode(pass[add[_login]])) == keccak256(abi.encode(_password)), "Invalid password");
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

    function closedSale () public payable VIP openClosedSale{
        priceToken = 0.001 ether;
        require(volClosedSale >= msg.value/priceToken * (10**decimals()), "Tokens for the closed sale are over!");
           payable(admin).transfer(msg.value);
           transferFrom(admin, msg.sender, msg.value/priceToken*(10**decimals()));
           volClosedSale -= (msg.value/priceToken* (10**decimals()));
    }

    function openSale () public payable openOpenSale{
        priceToken = 0.0075 ether;
        payable(admin).transfer(msg.value);
        transferFrom(admin, msg.sender, msg.value/priceToken*(10**decimals()));
    }

    function takeDevToken() public onlyDev{
        if(block.timestamp < stage3 + 3 minutes && block.timestamp >= stage3 && devTake[msg.sender] >= 30000){
            transferFrom(admin, msg.sender, (devTake[msg.sender] - 30000) * dec);
            devTake[msg.sender] -=(devTake[msg.sender] - 30000);
        }
        else if(block.timestamp >= stage3 + 3 minutes && block.timestamp < stage3 + 6 minutes && devTake[msg.sender] >= 20000){
            transferFrom(admin, msg.sender, (devTake[msg.sender] - 20000) * dec);
            devTake[msg.sender] -=(devTake[msg.sender] - 20000);
        }
        else if(block.timestamp >= stage3 + 6 minutes && block.timestamp < stage3 + 9 minutes && devTake[msg.sender] >= 10000){
            transferFrom(admin, msg.sender, (devTake[msg.sender] - 10000) * dec);
            devTake[msg.sender] -=(devTake[msg.sender] - 10000);
        }
        else if(block.timestamp >= stage3 + 9 minutes && devTake[msg.sender] >= 0 ){
            transferFrom(admin, msg.sender, devTake[msg.sender] * dec);
            devTake[msg.sender] -=(devTake[msg.sender]);
        }
        else {
           revert("Distribution to developers has not yet begun"); 
        }
    } 

    function addTime() public{
        stage2 -= 1 minutes;
        stage3 -= 1 minutes;
        stage4 -= 1 minutes;
    }
        


    function decimals() public pure override returns (uint8) {
        return 18;
    }
    
    modifier onlyAdmin{
        require(msg.sender == admin,  "You'r not a admin");
        _;
    }
    modifier onlyUser{
        require(acc[msg.sender].wallet != address(0), "You don't have an account");
        _;
    }
    modifier VIP{
        require(acc[msg.sender].presWhiteList == true, "You are not on the whitelist");
        _;
    }
    modifier openClosedSale{
        require(block.timestamp < stage4 && block.timestamp >= stage2, "Closed buy stage ended or not started yet");
        _;
    }

    modifier openOpenSale{ 
        require(block.timestamp >= stage4, "The open purchase stage has not started yet");
        _;
    }

    modifier onlyDev{
        require(acc[msg.sender].deveveloper == true, "You'r not developer");
        _;
    }
}
