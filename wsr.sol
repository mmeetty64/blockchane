pragma solidity ^0.8.7;

contract registration{

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
    mapping (address => Account) public acc;
    mapping (string => address) public add;
    mapping (address => string) public pass;

    enum role{Guest, Buyer, Seller, Provider, Bank, Admin, Shop}

    struct Shops{
        uint Id;
        string Sity;
        uint balance;
        address[] sellersShop;
    }
    mapping (address => Shops) public shops;

    struct Sellers{
        string sity;
        address Shop;
    }
    mapping (address => Sellers) public sellers;
 

    struct RequestRise{
        address shop;
        address seller;
    }
    RequestRise[] public reqRiseList;
    address[] public DowngradeList;

    struct Comment{
        uint id;
        address sender;
        uint grade;
        string comment;
        uint like;
        uint dislike;
        string[] commAnswer;
    }
    mapping (uint => Comment[]) public commShop;

    address[] public Admins;
    
    function shopSellers(address _shop) public view returns (address[] memory){
        return shops[_shop].sellersShop;    
    }

    function commAnswer(uint _shopId, uint _commId, uint _commAnswerId) public view returns (string memory){
        return commShop[_shopId][_commId].commAnswer[_commAnswerId];    
    }

    function commsAnswers(uint _shopId, uint _commId) public view returns (string[] memory){
        return commShop[_shopId][_commId].commAnswer;    
    }
    //string storage ref[] storage ref

    address payable[] public reqLoan;
    //role checking
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
    constructor(address _buyer, address _shop1, address _seller, address _admin) {
        acc[_buyer] = Account("buyer", "123", _buyer.balance, role.Buyer, 0, _buyer);
        add["buyer"] = _buyer;
        pass[_buyer] = "123";

        acc[_shop1] = Account("shop1", "123", _shop1.balance, role.Shop, 0, _shop1);
        add["shop1"] = _shop1;
        pass[_shop1] = "123";
        address[] memory empty;
        shops[_shop1] = Shops(1, "SPB", _shop1.balance, empty);

        acc[_seller] = Account("seller", "123", _seller.balance, role.Seller, 0, _seller);
        add["seller"] = _seller;
        pass[_seller] = "123";
        sellers[_seller] = Sellers(shops[_shop1].Sity, _shop1);
        shops[_shop1].sellersShop.push(_seller);
        
        acc[_admin] = Account("admin", "123", _admin.balance, role.Admin, 0, _admin);
        add["admin"] = _admin;
        pass[_admin] = "123";
        Admins.push(_admin);
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
    
    function commenting(uint _shopId,uint _grade, string memory _comm) public {
        commId++;
        string[] memory empty;
        commShop[_shopId].push(Comment(commId, msg.sender, _grade, _comm, 0, 0, empty));
    }

    function likeComm(uint _idShop, uint _idComm) public{
        commShop[_idShop][_idComm].like++;
    }

    function dislike(uint _idShop, uint _idComm) public {
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
    //function addSellers ();


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

   // function leaveAComment(string memory _comm, uint _grade, address _shop){} 



    
}
