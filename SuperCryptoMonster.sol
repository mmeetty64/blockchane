//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MonsterToken is ERC20("MonsterToken", "CMON"){
    function decimals() public view virtual override returns (uint8) {
    return 12;
    }
    address Owner = 0x9072437Ac1512c86fE19256f21136667878B5278;
    address privProv = 0x886f6406AB56f9033D677b28D38Fb55fB76eD4B0;
    address publProv = 0x4a7ca13b3180098d8883C94faEd7D73Fd796a4B1;
    address inv1 = 0x6A8c5208f3e1898ed1CBD4c0703Ee2c1B3FE3c2E;
    address inv2 = 0xa09089fda764C3e85983eD570dC08Cfd19e607f1;
    address BF = 0x57F5F21c363dEbCF53db8D3e37447cD93076bf3c;
    uint decim = 10**decimals();
    uint seedTokens = 0;
    uint privateTokens = 0;
    uint publicTokens = 0;
    uint Time_start = block.timestamp;
    uint startPrivateStage = Time_start + 5 minutes;
    uint startPublicStage = startPrivateStage + 10 minutes;
    uint Time_dif = 0;
    uint privatePrice = 0.0007 ether;
    uint publicPrice = 0.001 ether;
    enum Role{user, investor, privProv, publProv, Owner}
    enum typeToken{seedToken, privToken, publToken}
    WhiteList[] public reqWL;
    WhiteList[] public whiteList;


    struct User{
        string login;
        uint balance;
        address wallet;
        Role role;
        bool inWhiteList;
        uint seedToken;
        uint privToken;
        uint publToken;
    }

    struct WhiteList{
        string name;
        address wallet;
    }

    mapping(address => User) public user;
    mapping(string => address) public add;
    mapping(address => string) public pass;

    constructor() {
        _mint(Owner, 10000000*decim);

        privateTokens = balanceOf(Owner) * 30 / 100;
        publicTokens = balanceOf(Owner) * 60 / 100;
        transfer(inv1, 300000*decim);
        transfer(inv2, 400000*decim);
        transfer(BF, 200000*decim);
        seedTokens = balanceOf(Owner) - privateTokens - publicTokens;

        user[Owner] = User("Owner", balanceOf(Owner), Owner, Role.Owner, false, 0, 0, 0);
        add["Owner"] = Owner;
        pass[Owner] = "123";

        user[privProv] = User("privProv", balanceOf(privProv), privProv, Role.privProv, true, 0, 0, 0);
        add["privProv"] = privProv;
        pass[privProv] = "123";

        user[publProv] = User("publProv", balanceOf(publProv), publProv, Role.publProv, false, 0, 0, 0);
        add["publProv"] = publProv;
        pass[publProv] = "123";

        user[inv1] = User("inv1", balanceOf(inv1), inv1, Role.investor, false, balanceOf(inv1), 0, 0);
        add["inv1"] = inv1;
        pass[inv1] = "123";

        user[inv2] = User("inv2", balanceOf(inv2), inv2, Role.investor, false, balanceOf(inv2), 0, 0);
        add["inv2"] = inv2;
        pass[inv2] = "123";

        user[BF] = User("BF", balanceOf(BF), BF, Role.investor, false, balanceOf(BF), 0, 0);
        add["BF"] = BF;
        pass[BF] = "123";
    }

    //Регистрация
    function reg(string memory _login, string memory _password) public{
        require(user[msg.sender].wallet == address(0), unicode"Вы уже зарегестрированы!");
        user[msg.sender] = User(_login, balanceOf(msg.sender), msg.sender, Role.user, false, 0, 0, 0);
        add[_login] = msg.sender;
        pass[msg.sender] = _password;
    }

    //Авторизация
    function auth(string memory _login, string memory _password) public view returns(User memory){
        require(keccak256(abi.encode(user[add[_login]].login)) == keccak256(abi.encode(_login)), unicode"Неправильный логин!");
        require(keccak256(abi.encode(pass[add[_login]])) == keccak256(abi.encode(_password)), unicode"Неправильный пароль!");
        return user[add[_login]];
    }

    //buisness logic:

    //Приватная продажа
    function privateSale(uint _amount) public payable privateStage{
        require(_amount == msg.value/privatePrice, unicode"Внесено неправильное количество ether!");
        require(_amount <= 100000, unicode"Слишком большой объем транзакции!");
        require(privateTokens >= _amount * decim, unicode"Недостаточно токенов в приватной фазе!");
        _approve(privProv, msg.sender, _amount*decim);
        transferFrom(privProv, msg.sender, _amount*decim);
        user[msg.sender].privToken += _amount * decim;
        privateTokens -= _amount * decim;
        user[msg.sender].balance = balanceOf(msg.sender);
        user[privProv].balance = balanceOf(privProv);
    }

    //Публичная продажа
    function publicSale(uint _amount) public payable publicStage{
        require(_amount == msg.value/publicPrice, unicode"Внесено неправильное количество ether!");
        require(_amount <= 5000, unicode"Слишком большой объем транзакции!");
        require(publicTokens >= _amount * decim, unicode"Недостаточно токенов в приватной фазе!");
        _approve(publProv, msg.sender, _amount*decim);
        transferFrom(publProv, msg.sender, _amount*decim);
        user[msg.sender].publToken += _amount * decim;
        publicTokens -= _amount * decim;
        user[msg.sender].balance = balanceOf(msg.sender);
        user[privProv].balance = balanceOf(publProv);
    }

    //Добавление 1 минуты
    function boostTime() public{
        Time_dif += 1 minutes;
    }

    //передача обязанностей приватному провайдеру
    function activatePrivProv() public{
        transfer(privProv, privateTokens);
    }

    //передача обязанностей приватному провайдеру
    function activatePublProv() public{
        transfer(publProv, publicTokens);
    }

    function viewTokenPrice() public view returns(uint){
        if(block.timestamp + Time_dif >= startPrivateStage && block.timestamp + Time_dif < startPublicStage){
            return privatePrice;
        }
        else if(block.timestamp + Time_dif >= startPublicStage){
            return publicPrice;
        }
    }
    //user:

    //Подача заявки в вайтлист
    function reqWhiteList(string memory _name) public{
        require(user[msg.sender].inWhiteList != true, unicode"Вы уже в вайтлисте!");
        reqWL.push(WhiteList(_name, msg.sender));
    }

    //Перевод
    function newTransfer(address _user, uint _amount, typeToken _type) public{
        require(user[_user].wallet != address(0), unicode"У получателя нет аккаунта!");
        if(_type == typeToken.seedToken){
            require(user[msg.sender].seedToken >= _amount*decim, unicode"Не хватает seed токенов!");
            transfer(_user, _amount*decim);
            user[msg.sender].seedToken -= _amount*decim;
            user[_user].seedToken += _amount*decim;
            user[msg.sender].balance = balanceOf(msg.sender);
            user[_user].balance = balanceOf(_user);
        }
        else if(_type == typeToken.publToken){
            require(user[msg.sender].publToken >= _amount*decim, unicode"Не хватает public токенов!");
            transfer(_user, _amount*decim);
            user[msg.sender].publToken -= _amount*decim;
            user[_user].publToken += _amount*decim;
            user[msg.sender].balance = balanceOf(msg.sender);
            user[_user].balance = balanceOf(_user);
        }
        else if(_type == typeToken.privToken){
            require(user[msg.sender].privToken >= _amount*decim, unicode"Не хватает private токенов!");
            transfer(_user, _amount*decim);
            user[msg.sender].privToken -= _amount*decim;
            user[_user].privToken += _amount*decim;
            user[msg.sender].balance = balanceOf(msg.sender);
            user[_user].balance = balanceOf(_user);
        }
    } 

    //private provider:

    //Модерация заявок в вайтлист
    function applyReqWL(uint _id, bool _answer) public{
        if(_answer){
            user[reqWL[_id].wallet].inWhiteList = true;
            whiteList.push(reqWL[_id]);
            delete reqWL[_id];
        }
        else if(_answer == false){
            delete reqWL[_id];
        }
    }

    //Вывод заявок в вайтлист
    function viewReqWL() public view returns(WhiteList[] memory){
        return reqWL;
    }

    //private токены пользователя
    function privInfoUser(address _user) public view onlyPrivProv returns(uint){
        return user[_user].privToken;
    }
    
    //Owner:

    //Просмотр информации об активах
    function infoUser(address _user) public view onlyOwner returns(User memory){
        return user[_user];
    }

    //public provider 

    //выдача вознаграждения
    function donat(address _partner, uint _amount) public onlyPublProv publicStage{
        require(user[_partner].wallet != address(0), unicode"У получателя нет аккаунта!");
        transfer(_partner, _amount);
        user[_partner].publToken += _amount * decim;
        publicTokens -= _amount*decim;
        user[msg.sender].balance = balanceOf(msg.sender);
        user[_partner].balance = balanceOf(_partner);
    }

    //public токены пользователя
    function publInfoUser(address _user) public view onlyPublProv returns(uint){
        return user[_user].publToken;
    }

    //modifiers:

    modifier privateStage{
        require(block.timestamp + Time_dif >= startPrivateStage, unicode"Приватная стадия еще не началась!");
        require(block.timestamp + Time_dif < startPublicStage, unicode"Приватная стадия закончилась!");
        require(user[msg.sender].inWhiteList == true, "Free sale not started");
        _;
    }

    modifier publicStage{
        require(block.timestamp + Time_dif >= startPublicStage, unicode"Публичная стадия еще не началась!");
        _;
    }

    modifier onlyOwner{
        require(user[msg.sender].role == Role.Owner, unicode"Вы не владелец системы!");
        _;
    }

    modifier onlyPrivProv{
        require(user[msg.sender].role == Role.privProv, unicode"Вы не private провайдер!");
        _;
    }

    modifier onlyPublProv{
        require(user[msg.sender].role == Role.publProv, unicode"Вы не private провайдер!");
        _;
    }
}
