//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CryptoMonster is ERC20("CryptoMonster", "CMON"){
    function decimals() public view virtual override returns (uint8) {
    return 12;
    }
    uint decim = 10**decimals();
    address Owner = 0x2aD1e771e91Ba8884DA5a56f69747adda4d8baD1;
    address privProv = 0x46179EB10A56f6647614B3E074c01933389221Fa;
    address publProv = 0xA2ccfAf68DE241CaC214AE0901399516C0A0Ac83;
    address inv1 = 0x3C353F710EE39508beD6bbe1291002F66DC7f5A0;
    address inv2 = 0x4A7A86F7bE56113adF3BfDaC7BF3586D416FEa1F;
    address BF = 0x9F550d63229E44FEcd54FF0Ba628e2D5DB84fbE3;
    uint Time_start = block.timestamp;
    uint Time_dif = 0;
    uint startPrivateStage = Time_start + 5 minutes;
    uint startPublicStage = startPrivateStage + 10 minutes;
    uint privateTokenPrice = 0.00075 ether;
    uint public publicTokenPrice = 0.001 ether; 
    uint public seedTokens = 0;
    uint public privateTokens = 0;
    uint public publicTokens = 0;
    enum Role{user, investor, privProv, publProv, Owner}
    enum typeToken{seed, privateT, publicT}
    
    
    struct User{
        string login;
        uint balance;
        address wallet;
        Role role;
        bool inWhiteList;
        bool investor;
        uint seedToken;
        uint privToken;
        uint publToken;
    }

    struct WhiteList{
        string name;
        address user;
    }

    mapping(address => User) public user;
    mapping(address => string) public pass;
    mapping(string => address) public add;
    WhiteList[] public reqList;
    WhiteList[] public whiteList;

    constructor() {
        _mint(Owner, 10000000*decim);

        seedTokens = balanceOf(Owner) * 10/100;
        privateTokens = balanceOf(Owner) * 30/100;
        publicTokens = balanceOf(Owner) * 60/100;

        transfer(inv1, 300000*decim);
        transfer(inv2, 400000*decim);
        transfer(BF, 200000*decim);

        user[Owner] = User("Owner", balanceOf(Owner), Owner, Role.Owner, false, false, 0, 0, 0);
        pass[Owner] = "123";
        add["Owner"] = Owner;

        user[privProv] = User("privProv", balanceOf(privProv), privProv, Role.privProv, true, false, 0, 0, 0);
        pass[privProv] = "123";
        add["privProv"] = privProv;

        user[publProv] = User("publProv", balanceOf(publProv), publProv, Role.publProv, false, false, 0, 0, 0);
        pass[publProv] = "123";
        add["publProv"] = publProv;

        user[inv1] = User("inv1", balanceOf(inv1), inv1, Role.investor, false, false, 300000*decim, 0, 0);
        pass[inv1] = "123";
        add["inv1"] = inv1;

        user[inv2] = User("inv2", balanceOf(inv2), inv2, Role.investor, false, false, 400000*decim, 0, 0);
        pass[inv2] = "123";
        add["inv2"] = inv2;

        user[BF] = User("BF", balanceOf(BF), BF, Role.investor, false, false, 200000*decim, 0, 0);
        pass[BF] = "123";
        add["BF"] = BF;
    }

    //registration and authorisation:

    //регистрация
    function register(string memory _login, string memory _password) public{
        require(user[msg.sender].wallet == address(0), unicode"На ваш адрес уже зарегестрирован аккаунт!");
        user[msg.sender] = User(_login, balanceOf(msg.sender), msg.sender, Role.user, false, false, 0, 0, 0);
        pass[msg.sender] = _password;
        add[_login] = msg.sender;
    }

    //авторизация
    function auth(string memory _login, string memory _password) public view returns(User memory){
        require(keccak256(abi.encode(user[add[_login]].login)) == keccak256(abi.encode(_login)), unicode"Неправильный логин!");
        require(keccak256(abi.encode(pass[add[_login]])) == keccak256(abi.encode(_password)), unicode"Неправильный пароль!");
        return user[add[_login]];
    }

    //buisness logic:

    //покупка private токена
    function privateSale(uint _amount) public payable OnlyWL timePrivateStage{
        require(privateTokens > _amount*decim, unicode"Недостаточно токенов в приватной стадии!");
        require(msg.value == _amount*privateTokenPrice, unicode"Вы внесли неправильное количество ether!");
        require(_amount <= 100000, unicode"Слишком большой объем транзакции!");
        _approve(privProv, msg.sender, _amount*decim);
        transferFrom(privProv, msg.sender, _amount*decim);
        user[msg.sender].privToken += _amount * decim;
        privateTokens -= _amount * decim;
        user[msg.sender].balance = balanceOf(msg.sender);
        user[privProv].balance = balanceOf(privProv);
    }

    //покупка public токена
    function publicSale(uint _amount) public payable timePublicStage{
        require(publicTokens > _amount*decim, unicode"Недостаточно токенов в публичной стадии!");
        require(msg.value == _amount*publicTokenPrice, unicode"Вы внесли неправильное количество ether!");
        require(_amount <= 5000, unicode"Слишком большой объем транзакции!");
        _approve(publProv, msg.sender, _amount*decim);
        transferFrom(publProv, msg.sender, _amount*decim);
        user[msg.sender].publToken += _amount * decim;
        publicTokens -= _amount * decim;
        user[msg.sender].balance = balanceOf(msg.sender);
        user[privProv].balance = balanceOf(privProv);
    }

    //user:

    //подача заявки в вайтлист
    function reqWhiteList(string memory _name) public{
        require(user[msg.sender].inWhiteList == false, unicode"Вы уже в вайтлисте!");
        reqList.push(WhiteList(_name, msg.sender));
    }

    //Передача токенов
    function newTransfer(address _user, uint _amount, typeToken _type) public{
        if(_type == typeToken.seed){
            require(user[_user].role == Role.investor, unicode"Получатель не является инвестором!");
            require(user[msg.sender].seedToken >= _amount * decim, unicode"У вас не хватает seed токенов для отправки");
            transfer(_user, _amount*decim);
            user[_user].seedToken += _amount * decim;
            user[msg.sender].seedToken -= _amount * decim;
            user[msg.sender].balance = balanceOf(msg.sender);
            user[_user].balance = balanceOf(_user);
        }
        else if(_type == typeToken.publicT){
            require(block.timestamp + Time_dif >= startPublicStage, unicode"Сейчас нельзя отправлять public токены");
            require(user[msg.sender].publToken >= _amount * decim, unicode"У вас не хватает public токенов для отправки");
            transfer(_user, _amount*decim);
            user[_user].publToken += _amount * decim;
            user[msg.sender].publToken -= _amount * decim;
            user[msg.sender].balance = balanceOf(msg.sender);
            user[_user].balance = balanceOf(_user);
        }
    }
    
    //private provider:

    //модерация заявок вайтлиста
    function applyReqWL(uint _id, bool _answer) public OnlyPrivateProv{
        if(_answer){
            user[reqList[_id].user].inWhiteList = true;
            whiteList.push(reqList[_id]);
            delete reqList[_id];
        }
        else if(_answer == false){
            delete reqList[_id];
        }
    }

    //просмотр информации о токенах приватной группы
    function infoPrivTokenUser(address _addUser) public view OnlyPrivateProv returns(uint){
        return user[_addUser].privToken;
    }

    //public provider:

    //выдача вознагражения патрнерам проекта
    function donation(address _pathner, uint _amount) public OnlyPublicProv timePublicStage{
        transfer(_pathner, _amount*decim);
    }

    //просмотр информации о токенах публичной группы
    function infoPublTokenUser(address _addUser) public view OnlyPublicProv returns(uint){
        return user[_addUser].publToken;
    }

    //изменение стоимости токена
    function newTokenPrice(uint _newPrice) public OnlyPublicProv{
        publicTokenPrice = _newPrice;
    }

    //Owner:

    //просмотр полной информации об активах пользователя
    function checkUser(address _addUser) public view OnlyOwner returns(User memory) {
        return user[_addUser];
    }

    //prod tools:

    //перемотка времени на 1 минуту
    function timeBoost() public {
        Time_dif += 1 minutes;
    }

    //перевод private токенов Private провайдеру
    function allowancePrivate() public timePrivateStage{
        require(block.timestamp + Time_dif >= startPrivateStage && block.timestamp + Time_dif <= startPublicStage);
            transfer(privProv, privateTokens);
        
    }

    //перевод public токенов Public провайдеру
    function allowancePublic() public timePublicStage{
        require(block.timestamp + Time_dif >= startPublicStage);
            transfer(publProv, publicTokens);
    }

    //views
    function viewReqWL() public view returns(WhiteList[] memory){
        return reqList;
    }

    //modifiers

    modifier OnlyWL {
        require(user[msg.sender].inWhiteList == true, unicode"Вы не в вайтлисте!");
        _;
    }
    modifier OnlyPrivateProv {
        require(user[msg.sender].role == Role.privProv, unicode"Вы не являетесь приватным провайдером!");
        _;
    }
    modifier OnlyPublicProv {
        require(user[msg.sender].role == Role.publProv, unicode"Вы не являетесь приватным провайдером!");
        _;
    }
    modifier OnlyOwner {
        require(user[msg.sender].role == Role.Owner, unicode"Вы не являетесь владельцем системы!");
        _;
    }

    modifier timePublicStage{
        require(block.timestamp + Time_dif >= startPublicStage, unicode"Публичная стадия еще не началась");
        _;
    }
    modifier timePrivateStage{
        require(block.timestamp + Time_dif >= startPrivateStage, unicode"Приватная стадия еще не началась!");
        require(block.timestamp + Time_dif < startPublicStage, unicode"Приватная стадия закончилась!");
        _;
    }
}