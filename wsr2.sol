pragma solidity ^0.8.7;

contract registration{

    address admin = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    address buyer = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
    address seller = 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db;
    address bank = 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB;
    address provider = 0x617F2E2fD72FD9D5503197092aC168c91465E7f2;
    address shop1 = 0x17F6AD8Ef982297579C203069C1DbfFE4348c372;
    address shop2 = 0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678;
    address shop3 = 0x03C6FcED478cBbC9a4FAB34eF9f40767739D1Ff7;
    address shop4 = 0x1aE0EA34a72D944a8C7603FfB3eC30a6669E454C;
    address shop5 = 0x0A098Eda01Ce92ff4A4CCb7A4fFFb5A43EBC70DC;
    address shop6 = 0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c;
    address shop7 = 0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C;
    address shop8 = 0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB;
    address shop9 = 0x583031D1113aD414F02576BD6afaBfb302140225;

    
    
    
    constructor() {
        
        acc[admin] = Account("admin", "123", admin.balance, role.Admin, 0, admin);
        add["admin"] = admin;
        pass[admin] = "123";
        Admins.push(admin);

        acc[buyer] = Account("buyer", "123", buyer.balance, role.Buyer, 0, buyer);
        add["buyer"] = buyer;
        pass[buyer] = "123";


        acc[seller] = Account("seller", "123", seller.balance, role.Seller, 0, seller);
        add["seller"] = seller;
        pass[seller] = "123";
        sellers[seller] = Sellers(shops[shop1].Sity, shop1);
        shops[shop1].sellersShop.push(seller);

        acc[bank] = Account("bank", "123", bank.balance, role.Bank, 0, bank);
        add["bank"] = bank;
        pass[bank] = "123";

        acc[provider] = Account("provider", "123", provider.balance, role.Provider, 0, provider);
        add["provider"] = provider;
        pass[provider] = "123";
        
        address[] memory empty;

        acc[shop1] = Account("shop1", "123", shop1.balance, role.Shop, 0, shop1);
        add["shop1"] = shop1;
        pass[shop1] = "123";
        shops[shop1] = Shops(1, "Dmitrov", shop1.balance, empty);

        acc[shop2] = Account("shop2", "123", shop2.balance, role.Shop, 0, shop2);
        add["shop2"] = shop2;
        pass[shop2] = "123";
        shops[shop2] = Shops(2, "Kaluga", shop2.balance, empty);

        acc[shop3] = Account("shop3", "123", shop3.balance, role.Shop, 0, shop3);
        add["shop3"] = shop3;
        pass[shop3] = "123";
        shops[shop3] = Shops(3, "Moscow", shop3.balance, empty);

        acc[shop4] = Account("shop4", "123", shop4.balance, role.Shop, 0, shop4);
        add["shop4"] = shop4;
        pass[shop4] = "123";
        shops[shop4] = Shops(4, "Ryazan", shop4.balance, empty);

        acc[shop5] = Account("shop5", "123", shop5.balance, role.Shop, 0, shop5);
        add["shop5"] = shop5;
        pass[shop5] = "123";
        shops[shop5] = Shops(5, "Samara", shop5.balance, empty);

        acc[shop6] = Account("shop6", "123", shop6.balance, role.Shop, 0, shop6);
        add["shop6"] = shop6;
        pass[shop6] = "123";
        shops[shop6] = Shops(6, "Saint-Petersburg", shop6.balance, empty);

        acc[shop7] = Account("shop7", "123", shop7.balance, role.Shop, 0, shop7);
        add["shop7"] = shop7;
        pass[shop7] = "123";
        shops[shop7] = Shops(7, "Taganrog", shop7.balance, empty);
        
        acc[shop8] = Account("shop8", "123", shop8.balance, role.Shop, 0, shop8);
        add["shop8"] = shop8;
        pass[shop8] = "123";
        shops[shop8] = Shops(8, "Tomsk", shop8.balance, empty);

        acc[shop9] = Account("shop9", "123", shop9.balance, role.Shop, 0, shop9);
        add["shop9"] = shop9;
        pass[shop9] = "123";
        shops[shop9] = Shops(9, "Habarovsk", shop9.balance, empty);

    }

    uint shopId = 0;
    uint commId = 0;
    struct Account{
        string login;
        string fullName;
        uint balance;
        role role; // 1 - Buyer, 2 - Seller, 3 - Provider, 4 - Bank, 5 - Admin, 6 - Shop  
        uint tempRole;
        address wallet;
    }
    
    struct Shops{
        uint Id;
        string Sity;
        uint balance;
        address[] sellersShop;
    }

    struct Sellers{
        string sity;
        address Shop;
    }
    
    struct RequestRise{
        address shop;
        address seller;
    }
    
    struct Comment{
        uint id;
        address sender;
        uint grade;
        string comment;
        uint like;
        uint dislike;
        string[] commAnswer;
    }

    mapping (address => Account) public acc;
    mapping (string => address) public add;
    mapping (address => string) public pass;
    mapping (uint => Comment[]) public commShop;
    mapping (address => Shops) public shops;
    mapping (address => Sellers) public sellers;
    address[] public Admins;
    address payable[] public reqLoan;
    RequestRise[] public reqRiseList;
    address[] public DowngradeList;

    //role checking

    enum role{Guest, Buyer, Seller, Provider, Bank, Admin, Shop}

    modifier onlyBuyer{
        require(acc[msg.sender].role == role.Buyer || acc[msg.sender].tempRole == 1, "You`re not buyer");
        _;
    }

    modifier onlySeller{
        require(acc[msg.sender].role == role.Seller, "You`re not seller");
        _;
    }

    modifier onlyProvider{
        require(acc[msg.sender].role == role.Provider, "You`re not provider");
        _;
    }

    modifier onlyBank{
        require(acc[msg.sender].role == role.Bank, "You`re not bank");
        _;
    }

    modifier onlyAdmin{
        require(acc[msg.sender].role == role.Admin, "You`re not admin");
        _;
    }

    modifier onlyShop{
        require(acc[msg.sender].role == role.Shop, "You`re not shop");
        _;
    }
    


    //registration and authorisation
    function regAcc (string memory _login, string memory _fullName, string memory _pass) public{
        require(acc[msg.sender].wallet == address(0), "Account already register");
        acc[msg.sender] = Account(_login, _fullName, msg.sender.balance, role.Buyer, 0, msg.sender);
        add[_login] = msg.sender;
        pass[msg.sender] = _pass;
    }

    function authAcc (string memory _login, string memory _pass) public view returns (Account memory){
        require(keccak256(abi.encode(acc[add[_login]].login)) == keccak256(abi.encode(_login)), "Undefined login");
        require(keccak256(abi.encode(pass[add[_login]])) == keccak256(abi.encode(_pass)), "invalid password");
        return acc[add[_login]];
    }

    function sellersDetails () public view onlySeller returns(Sellers memory){
        return sellers[msg.sender];       
    }
    
    //Buyer  
    function requestRaise(address _shop) public onlyBuyer{
        reqRiseList.push(RequestRise(_shop, msg.sender));
    }
    
    function commenting(uint _shopId,uint _grade, string memory _comm) public onlyBuyer{
        commId++;
        string[] memory empty;
        commShop[_shopId].push(Comment(commId, msg.sender, _grade, _comm, 0, 0, empty));
    }

    function likeComm(uint _idShop, uint _idComm) public onlyBuyer{
        commShop[_idShop][_idComm].like++;
    }

    function dislike(uint _idShop, uint _idComm) public onlyBuyer{
        commShop[_idShop][_idComm].dislike++;
    }

    //Bank
    function loan(bool _answer, uint _id) public payable onlyBank{
        if (_answer == true){
        require(msg.value == 1 ether, "insufficient loan amount");
        reqLoan[_id].transfer(msg.value);
        delete reqLoan[_id];}
        else {
            delete reqLoan[_id];
        }
    }

    //Shops
    
    function requestLoan() public onlyShop{
        reqLoan.push(payable(msg.sender));
    }

    //Seller

    function requestDowngrade() public onlySeller{
        DowngradeList.push(msg.sender);
    }
    
    function SellerOnTheBuyer() public onlySeller{
        acc[msg.sender].tempRole = 1;
    }

    function becomeASeller() public onlySeller{
        acc[msg.sender].tempRole = 0;
    }

    function replyComment(uint _idComm, string memory _reply) public onlySeller{
        commShop[shops[sellers[msg.sender].Shop].Id][_idComm].commAnswer.push(_reply);   
    } 

    //Admin

    function addSellers (bool _answer, uint _id) public onlyAdmin{
        if (_answer == true){
        acc[reqRiseList[_id].seller].role = role.Seller;
        sellers[reqRiseList[_id].seller] = Sellers(shops[reqRiseList[_id].shop].Sity, reqRiseList[_id].shop);
        shops[reqRiseList[_id].shop].sellersShop.push(reqRiseList[_id].seller);
        delete reqRiseList[_id];}
        else {
            delete reqRiseList[_id];
        }
    }

    function AdminOnTheBuyer() public onlyAdmin{
        acc[msg.sender].tempRole = 1;
    }

    function becomeAAdmin() public onlyAdmin{
        acc[msg.sender].tempRole = 0;
    }

    function downgradeSellers (bool _answer, uint _id) public onlyAdmin{
        if (_answer == true){
        acc[DowngradeList[_id]].role = role.Buyer;
        delete sellers[DowngradeList[_id]];
        delete DowngradeList[_id];}
        else {
            delete DowngradeList[_id];
        }
    }

    function addAdmin (address _newAdmin) public onlyAdmin{
        acc[_newAdmin].role = role.Admin;
        Admins.push(_newAdmin);
    }

    function regShop(address _newShop, string memory _sity) public onlyAdmin{
        acc[_newShop].role = role.Shop;
        shopId++;
        address[] memory empty;
        shops[_newShop] = Shops(shopId, _sity, _newShop.balance, empty);
    }

    function deleteShop (address _shop) public onlyAdmin{
        for(uint i = 0; i < shops[_shop].sellersShop.length; i++){
            acc[shops[_shop].sellersShop[i]].role = role.Buyer;
            delete sellers[shops[_shop].sellersShop[i]];
        }
        delete commShop[shops[_shop].Id];
        delete shops[_shop];
        acc[_shop].role = role.Buyer;
        
    }

    //readout
    function shopSellers(address _shop) public view returns (address[] memory){
        return shops[_shop].sellersShop;    
    }

    function commAnswer(uint _shopId, uint _commId, uint _commAnswerId) public view returns (string memory){
        return commShop[_shopId][_commId].commAnswer[_commAnswerId];    
    }

    function commsAnswers(uint _shopId, uint _commId) public view returns (string[] memory){
        return commShop[_shopId][_commId].commAnswer;    
    }
    
    //tools
    function addBuyer () public{
        acc[msg.sender].role = role.Buyer;
    } 
    function addSeller () public{
        acc[msg.sender].role = role.Seller;
    } 
    function addProvider () public{
        acc[msg.sender].role = role.Provider;
    } 
    function addBank () public{
        acc[msg.sender].role = role.Bank;
    } 
    function addAdmin () public{
        acc[msg.sender].role = role.Admin;
    } 
    function addShop () public{
        acc[msg.sender].role = role.Shop;
    } 
     
}
