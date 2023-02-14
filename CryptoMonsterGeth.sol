// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CryptoMonster is ERC20("CryptoMonster", "CMON"){
    function decimals() public pure override returns (uint8) {
        return 12;
    }
    uint decim = 10**decimals();
    address Owner = 0x2aD1e771e91Ba8884DA5a56f69747adda4d8baD1;
    address privProv = 0x46179EB10A56f6647614B3E074c01933389221Fa;
    address publProv = 0xA2ccfAf68DE241CaC214AE0901399516C0A0Ac83;
    address inv1 = 0x3C353F710EE39508beD6bbe1291002F66DC7f5A0;
    address inv2 = 0x4A7A86F7bE56113adF3BfDaC7BF3586D416FEa1F;
    address BF = 0x9F550d63229E44FEcd54FF0Ba628e2D5DB84fbE3;
    uint public seedTokens;
    uint public privateTokens;
    uint public publicTokens; 
    enum role{user, investor, privateProvider, publicProvider, owner}
    WhiteList[] public reqWhiteList;
    WhiteList[] public whiteList;
    uint Time_start = block.timestamp;
    uint Time_dif;
    uint startPrivateStage = Time_start + 5 minutes;
    uint startPublicStage = startPrivateStage + 10 minutes;
    uint public tokenPrice = 0.001 ether;

    

    struct User {
        string login;
        uint balance;
        role role;
        address wallet;
        bool whiteList;
        bool investor;
        uint seedToken;
        uint privToken;
        uint publToken;
    }

    struct WhiteList{
        string name;
        address wallet;
    }

    mapping(address => User) public users;
    mapping(string => address) public add;
    mapping(address => string) public pass;

    constructor() public{
        _mint(Owner, 10000000*decim);

        users[Owner] = User("Owner", balanceOf(Owner), role.owner, Owner, false, false, 0, 0, 0);
        add["Owner"] = Owner;
        pass[Owner] = "123";

        users[privProv] = User("privProv", balanceOf(privProv), role.privateProvider, privProv, true, false, 0, 0, 0);
        add["privProv"] = privProv;
        pass[privProv] = "123";

        users[publProv] = User("publProv", balanceOf(publProv), role.publicProvider, publProv, false, false, 0, 0, 0);
        add["publProv"] = publProv;
        pass[publProv] = "123";

        users[inv1] = User("inv1", balanceOf(inv1), role.investor, inv1, false, true, 300000*decim, 0, 0);
        add["inv1"] = inv1;
        pass[inv1] = "123";

        users[inv2] = User("inv2", balanceOf(inv2), role.investor, inv2, false, true, 400000*decim, 0, 0);
        add["inv2"] = inv2;
        pass[inv2] = "123";

        users[BF] = User("BF", balanceOf(BF), role.investor, BF, false, true, 200000*decim, 0, 0);
        add["BF"] = BF;
        pass[BF] = "123";

        seedTokens = balanceOf(Owner) * 10 / 100;
        privateTokens = balanceOf(Owner) * 30 / 100;
        publicTokens = balanceOf(Owner) * 60 / 100;

        transfer(inv1 , 300000 * decim);
        transfer(inv2 , 400000 * decim);
        transfer(BF , 200000 * decim); 
    }

    //Регистрация
    function registration(string memory _login, string memory _password) public {
        require(users[msg.sender].wallet == address(0), "Account already registered");
        users[msg.sender] = User(_login, balanceOf(msg.sender), role.user, msg.sender, false, false, 0, 0, 0);
        add[_login] = msg.sender;
        pass[msg.sender] = _password;
    }

    //Авторизация
    function authorisation(string memory _login, string memory _password) public view returns(User memory) {
        require(keccak256(abi.encode(users[add[_login]].login)) == keccak256(abi.encode(_login)), "Undefined login");
        require(keccak256(abi.encode(pass[add[_login]])) == keccak256(abi.encode(_password)), "Undefined password");
        return users[add[_login]];
    }

    //buisness logic:
    //Приватная продажа
    function privateSale(uint _amount) public payable privateStages userWL{
        uint privTokenPrice = 0.0007 ether;
        require(msg.value/privTokenPrice == _amount, unicode"Вы внесли неправильное количество ether");
        require(_amount <= 100000, unicode"Превышен максимальный объем транзакции");
        require(privateTokens >= _amount, unicode"Не хватает токенов в приватной стадии");
        _approve(Owner, msg.sender, _amount*decim);
        transferFrom(Owner, msg.sender, _amount*decim);
        privateTokens -= _amount * decim;
        users[msg.sender].privToken += _amount*decim;
        users[msg.sender].balance = balanceOf(msg.sender);
        users[Owner].balance = balanceOf(Owner);
    }

    //Публичная продажа
    function publicSale(uint _amount) public payable publicStages userReg{
        require(msg.value/tokenPrice == _amount, unicode"Вы внесли неправильное количество ether");
        require(_amount <= 5000, unicode"Превышен максимальный объем транзакции");
        require(publicTokens >= _amount, unicode"Не хватает токенов в публичной стадии");
        _approve(Owner, msg.sender, _amount*decim);
        transferFrom(Owner, msg.sender, _amount*decim);
        publicTokens -= _amount * decim;
        users[msg.sender].publToken += _amount*decim;
        users[msg.sender].balance = balanceOf(msg.sender);
        users[Owner].balance = balanceOf(Owner);
    }
    
    //Вывод количества секунд со старта
    function timeLiveSystem() public view returns(uint){
        return(block.timestamp + Time_dif - Time_start);
    }

    //Перевод времени на 1 минуту
    function backToTheFuture() public{
        Time_dif += 1 minutes;
    }

    // owner panel:
    //Вывод юзера 
    function viewUser(address _user) public view Ownere returns(User memory){
        require(users[_user].wallet != address(0), "Undefined user");
        return users[_user];
    }

    //Передача прав провайдерам
    function assignment() Ownere public {
        approve(privProv, privateTokens*decim);
        approve(publProv, publicTokens*decim);
    }

    //user
    //Подача заявок в вайтлист
    function requestWhiteList(string memory _name) public userReg{
        reqWhiteList.push(WhiteList(_name, msg.sender));
    } 

    //Перевод токенов
    function transferToken(uint _countToken, address _recipient) public userReg{
        if(block.timestamp + Time_dif < startPrivateStage){
            require(users[msg.sender].seedToken >= _countToken, unicode"У вас не хватает токенов public группы");
            require(users[_recipient].investor == true, unicode"Получатель не водит в число инвесторов");
            transfer(_recipient, _countToken*decim);
            users[msg.sender].seedToken -= _countToken*decim;
            users[_recipient].seedToken += _countToken*decim;
            users[msg.sender].balance = balanceOf(msg.sender);
            users[_recipient].balance = balanceOf(_recipient);

        }
        else if(block.timestamp + Time_dif > startPublicStage){
            require(users[msg.sender].publToken >= _countToken, unicode"У вас не хватает токенов public группы");
            require(users[_recipient].wallet != address(0), unicode"У получателя нет аккаунта");
            transfer(_recipient, _countToken*decim);
            users[msg.sender].publToken -= _countToken*decim;
            users[_recipient].publToken += _countToken*decim;
            users[msg.sender].balance = balanceOf(msg.sender);
            users[_recipient].balance = balanceOf(_recipient);
        }
        else{
            revert(unicode"Сейчас нельзя передавать токены");
        }
    }

    //private panel 
    //Подтверждение\отказ заявок в вайтлист
    function applicationWL(uint _idRequest, bool _answer) public privateProvider{
        if(_answer == true){
            whiteList.push(reqWhiteList[_idRequest]);
            users[reqWhiteList[_idRequest].wallet].whiteList = true;
            delete reqWhiteList[_idRequest];
        }
        else{
            delete reqWhiteList[_idRequest];
        }
    }

    //Просмотр private токенов пользователя
    function userPrivateInfo(address _addUser) public view privateProvider returns(uint){
        return users[_addUser].privToken;
    }

    //public panel
    //Просмотр public токенов позльователя
    function userPublicInfo(address _addUser) public view publicProvider returns(uint){
        return users[_addUser].publToken;
    }

    //Вознаграждение партнеров проекта
    function donation(address _partner, uint _amount) public publicStages publicProvider{
        require(publicTokens >= _amount, unicode"Не хватает токенов в публичной стадии");
        require(users[_partner].wallet != address(0), unicode"У партнера нет аккаунта");
        transferFrom(Owner, _partner, _amount);
        users[_partner].publToken += _amount*decim;
        users[_partner].balance = balanceOf(_partner);
        publicTokens -= _amount*decim;
    }

    //Изменение цены токена
    function newTokenPrice(uint _newPrice) public publicProvider{
        tokenPrice = _newPrice;
    }

    //modifiers:
    modifier publicStages{
        require(block.timestamp + Time_dif >= startPublicStage, unicode"Публичная продажа еще не началась");
        require(publicTokens != 0, unicode"Токены для публичной стадии закончились");
        _;
    }

    modifier privateStages{
        require(block.timestamp + Time_dif >= startPrivateStage, "Free sale not started");
        require(block.timestamp + Time_dif <= startPublicStage, unicode"Приватная стадия закончилась");
        require(privateTokens != 0, unicode"Токены для приватной стадии закончились");
        _;
    }

    modifier userWL{
        require(users[msg.sender].whiteList == true, unicode"Вы не в вайтлисте!");
        _;
    }

    modifier privateProvider{
        require(msg.sender == privProv, unicode"Вы не private provider");
        _;
    }

    modifier publicProvider{
        require(msg.sender == publProv, unicode"Вы не public provider");
        _;
    }

    modifier userReg{
        require(users[msg.sender].wallet != address(0), unicode"Вы не зарегестрированы!");
        _;
    }
    
    modifier Ownere{
        require(msg.sender == Owner, unicode"Вы не владелец системы");
        _;
    }
}
