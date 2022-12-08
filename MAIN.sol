pragma solidity ^0.8.7;

contract mail {
    address mainAdmin = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    address commonAdmin = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
    address worker1 = 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db;
    address worker2 = 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB;
    address user1 = 0x617F2E2fD72FD9D5503197092aC168c91465E7f2;
    uint timeStart = block.timestamp;

    constructor() {
        Users[mainAdmin] = user("Ivan", "none", mainAdmin.balance, role.mainAdmin, mainAdmin);
        Add["Ivan"] = mainAdmin;
        Pass[mainAdmin] = "123";

        Users[commonAdmin] = user("Semen", "none", commonAdmin.balance, role.admin, commonAdmin);
        Add["Semen"] = commonAdmin;
        Pass[commonAdmin] = "123";

        Users[worker1] = user("Petr", "none", worker1.balance, role.worker, worker1);
        Add["Petr"] = worker1;
        Pass[worker1] = "123";
        idWorker[worker1] = 344000;

        Users[worker2] = user("Anton", "none", worker2.balance, role.worker, worker2);
        Add["Anton"] = worker2;
        Pass[worker2] = "123";
        idWorker[worker2] = 347900;

        Users[user1] = user("Uriy", "none", user1.balance, role.user, user1);
        Add["Uriy"] = user1;
        Pass[user1] = "123";
        idWorker[user1] = 347900;

        specClass[1] = classes(5, 0.5 ether);
        specClass[2] = classes(10, 0.3 ether);
        specClass[3] = classes(15, 0.1 ether);
    }

    struct user {
        string name;
        string homeAddress;
        uint256 balance;
        role role;
        address wallet;
    }

    struct MoneyTransfer{
        address otprav;
        address poluch;
        uint summ;
        uint lifeTime;
        uint realLifeTime;
    }

    struct posilka{
        uint treknumber;
        string sender;
        string poluchatel;
        string types;
        uint class;
        uint srok;
        uint cost;
        uint weight;
        uint specCost;
        uint finalCost;
        string addressNaznach;
        string addressSend;
    }

    struct checkpoint{
        uint idOtdel;
        uint treckNum;
        uint weight;
    }
    
    struct classes{
        uint crok;
        uint cost;
    }
    mapping(address => user) public Users;
    mapping(string => address) public Add;
    mapping(address => string) public Pass;
    mapping(address => uint256) public idWorker;
    mapping(address => MoneyTransfer[]) public Transfer;
    mapping(uint => posilka) public Posilka;
    mapping(uint => classes) public specClass;
    mapping(uint => checkpoint[]) public checking;
    enum role {none, user, worker, admin, mainAdmin}

    function register(string memory _name, string memory _password, string memory _homeAddress) public {
        require(Users[msg.sender].wallet == address(0), "Users already registered");
        Users[msg.sender] = user(_name, _homeAddress, msg.sender.balance, role.user, msg.sender);
        Add[_name] = msg.sender;
        Pass[msg.sender] = _password;
    }

    function authoris(string memory _name, string memory _password) public view returns (user memory) {
        require(keccak256(abi.encode(Users[Add[_name]].name)) == keccak256(abi.encode(_name)), "Undefined name");
        require(keccak256(abi.encode(Pass[Add[_name]])) == keccak256(abi.encode(_password)), "Undefined password");
        return Users[Add[_name]];
    }

    function editProfileName(string memory _newName) public {
        Users[msg.sender].name = _newName;
    }

    function editProfileAddress(string memory _newHomeAddress) public {
        Users[msg.sender].homeAddress = _newHomeAddress;
    }

    //user
    function sendMoney(address _poluchatel, uint _summa, uint _timeLife) public payable{ 
        uint timeLife = block.timestamp + (_timeLife * 5) * 1 seconds;
        uint summa = _summa * (10** 18);
        Transfer[_poluchatel].push(MoneyTransfer(msg.sender, _poluchatel, summa, timeLife, _timeLife));
        payable(address(this)).transfer;
    }

    function poluchMoney(uint _id, bool _answer) public payable {
        if (_answer == true && Transfer[msg.sender][_id].lifeTime > block.timestamp){
            payable(msg.sender).transfer(Transfer[msg.sender][_id].summ);
            delete Transfer[msg.sender][_id];
        }
        else if (_answer == false || Transfer[msg.sender][_id].lifeTime < block.timestamp) {
            payable(Transfer[msg.sender][_id].otprav).transfer(Transfer[msg.sender][_id].summ);
            delete Transfer[msg.sender][_id];
        }
    }

    //posilka
    function createPosilka(uint _trekNumber, string memory _sender, string memory _poluchatel, string memory _type, uint _class, uint _weight, uint _specCost, string memory _addressNaznach, string memory _addressSend) public{
        uint srok = specClass[_class].crok;
        uint deliveryCost = specClass[_class].cost * _weight;
        uint finalCost = specClass[_class].cost * _weight + _specCost / 10;
        Posilka[_trekNumber] = posilka(_trekNumber, _sender, _poluchatel, _type, _class, srok, deliveryCost, _weight, _specCost, finalCost, _addressNaznach, _addressSend);
    }

    //view
    function vyvodMoneyTransfer() public view returns (MoneyTransfer[] memory){
         return Transfer[msg.sender];
    }
}
