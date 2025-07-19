pragma solidity ^0.5.0;



contract Context {
    
    
    constructor () internal { }
    

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; 
        return msg.data;
    }
}

library StringUtils {
    
    
    
    function compare(string memory _a, string memory _b)
        internal
        pure
        returns (int256)
    {
        bytes memory a = bytes(_a);
        bytes memory b = bytes(_b);
        uint256 minLength = a.length;
        if (b.length < minLength) minLength = b.length;
        
        for (uint256 i = 0; i < minLength; i++)
            if (a[i] < b[i]) return -1;
            else if (a[i] > b[i]) return 1;
        if (a.length < b.length) return -1;
        else if (a.length > b.length) return 1;
        else return 0;
    }

    
    function equal(string memory _a, string memory _b)
        internal
        pure
        returns (bool)
    {
        return compare(_a, _b) == 0;
    }

    
    function indexOf(string memory _haystack, string memory _needle)
        internal
        pure
        returns (int256)
    {
        bytes memory h = bytes(_haystack);
        bytes memory n = bytes(_needle);
        if (h.length < 1 || n.length < 1 || (n.length > h.length)) return -1;
        else if (h.length > (2**128 - 1))
            
            return -1;
        else {
            uint256 subindex = 0;
            for (uint256 i = 0; i < h.length; i++) {
                if (h[i] == n[0]) 
                {
                    subindex = 1;
                    while (
                        subindex < n.length &&
                        (i + subindex) < h.length &&
                        h[i + subindex] == n[subindex] 
                    ) {
                        subindex++;
                    }
                    if (subindex == n.length) return int256(i);
                }
            }
            return -1;
        }
    }

    
    
    
    
    
    
}


library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    
    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}


library Address {
    
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        
        
        
        
        
        
        
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

contract TokenismAdminWhitelist is Context {
    using Roles for Roles.Role;
    Roles.Role private _managerWhitelisteds;

    
     mapping(address => string) public admins;
     address superAdmin;
     address feeAddress;

     
    
    
    bool public accreditationCheck = true;

    struct whitelistInfoManager {
        address wallet;
        string role;
        bool valid;
    }

    mapping(address => whitelistInfoManager) whitelistManagers;

     constructor() public {
        
        
        admins[_msgSender()] = "superAdmin";
        superAdmin = msg.sender;
       
    }
    function addSuperAdmin(address _superAdmin) public {

         require(msg.sender == superAdmin, "Only super admin can add admin");
         admins[_superAdmin] = "superAdmin";
         admins[superAdmin] = "dev";
         superAdmin = _superAdmin;
        
    }

    modifier onlyAdmin() {
       require(
          StringUtils.equal(admins[_msgSender()], "superAdmin") ||
          StringUtils.equal(admins[_msgSender()], "dev") ||
          StringUtils.equal(admins[_msgSender()], "fee") ||
          StringUtils.equal(admins[_msgSender()], "admin"),
                "Only admin is allowed"
        );
         _;
    }

    modifier onlyManager() {
    require(
            isWhitelistedManager(_msgSender()) || 
             StringUtils.equal(admins[_msgSender()], "superAdmin") ||
             StringUtils.equal(admins[_msgSender()], "dev") ||
             StringUtils.equal(admins[_msgSender()], "fee") ||
             StringUtils.equal(admins[_msgSender()], "admin"),
            "TokenismAdminWhitelist: caller does not have the Manager role"
        );
        _;
    }
    
    function updateAccreditationCheck(bool status) public onlyManager {
        accreditationCheck = status;
    }

    
    function addWhitelistedManager(address _wallet, string memory _role)
        public
        onlyAdmin
    {
        require(
            StringUtils.equal(_role, "finance") ||
            StringUtils.equal(_role, "signer") ||
                StringUtils.equal(_role, "assets"),
            "TokenismAdminWhitelist: caller does not have the Manager role"
        );

        whitelistInfoManager storage newManager = whitelistManagers[_wallet];

        _managerWhitelisteds.add(_wallet);
        newManager.wallet = _wallet;
        newManager.role = _role;
        newManager.valid = true;
    }

    function getManagerRole(address _wallet)
        public
        view
        returns (string memory)
    {
        whitelistInfoManager storage m = whitelistManagers[_wallet];
        return m.role;
    }

    function updateRoleManager(address _wallet, string memory _role)
        public
        onlyAdmin
    {
         require(
            StringUtils.equal(_role, "finance") ||
            StringUtils.equal(_role, "signer") ||
                StringUtils.equal(_role, "assets"),
            "TokenismAdminWhitelist: Invalid  Manager role"
        );
        whitelistInfoManager storage m = whitelistManagers[_wallet];
        m.role = _role;
    }

    function isWhitelistedManager(address _wallet) public view returns (bool) {
        whitelistInfoManager memory m = whitelistManagers[_wallet];

        if (  StringUtils.equal(admins[_wallet], "superAdmin") ||
              StringUtils.equal(admins[_wallet], "dev") ||
              StringUtils.equal(admins[_wallet], "fee") ||
             StringUtils.equal(admins[_wallet], "admin")) return true;
        else if (!m.valid) return false;
        else return true;
    }

    
    function removeWhitelistedManager(address _wallet) public onlyAdmin {
        _managerWhitelisteds.remove(_wallet);
        whitelistInfoManager storage m = whitelistManagers[_wallet];
        m.valid = false;
    }

    function transferOwnership(address  _newAdmin)
        public
        returns (bool)
    {
        
        require(_msgSender() == superAdmin, "Only super admin can add admin");
         admins[_newAdmin] = "superAdmin";
         admins[superAdmin] = "";
         superAdmin = _newAdmin;

        return true;
    }
    function addAdmin(address  _newAdmin, string memory _role)
    public
    onlyAdmin
    returns (bool)
    {
        
    require(_msgSender() == superAdmin || Address.isContract(_newAdmin) , "Only super admin can add admin");
    require(
              StringUtils.equal(_role, "dev") ||
              StringUtils.equal(_role, "fee") ||
              StringUtils.equal(_role, "admin"),
             "undefind admin role"
             );
        admins[_newAdmin] = _role;
        return true;
    }

   
   function addFeeAddress(address _feeAddress) public {
       require(_msgSender() == superAdmin, "Only super admin can add Fee Address");
      feeAddress = _feeAddress;
   }
   function getFeeAddress()public view returns(address){
       return feeAddress;
   } 

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

    
    
    
    function isAdmin(address _calle)public view returns(bool) {
        if(StringUtils.equal(admins[_calle] , "superAdmin") ||
             StringUtils.equal(admins[_calle] , "dev") ||
             StringUtils.equal(admins[_calle] , "fee") ||
             StringUtils.equal(admins[_calle] , "admin")){
                 return true;
             }
             return false;
        
    }
    function isSuperAdmin(address _calle) public view returns(bool){
        if(StringUtils.equal(admins[_calle] , "superAdmin")){
            return true;
        }
        return false;
    }
   function isManager(address _calle)public returns(bool) {
        whitelistInfoManager memory m = whitelistManagers[_calle];
        return m.valid;
   }
}

contract TokenismWhitelist is Context, TokenismAdminWhitelist {
    using Roles for Roles.Role;
    Roles.Role private _userWhitelisteds;
    mapping(string=> bool) public symbolsDef;

    struct  whitelistInfo {
        bool valid;
        address wallet;
        bool kycVerified;
        bool accredationVerified;
        uint256 accredationExpiry;
        uint256 taxWithholding;
        string  userType;
        bool suspend;
    }
    mapping(address => whitelistInfo) public whitelistUsers;
    address[] public userList;

    
    function addWhitelistedUser(address _wallet, bool _kycVerified, bool _accredationVerified, uint256 _accredationExpiry) public onlyManager {
        if(_accredationVerified)
            require(_accredationExpiry >= block.timestamp, "accredationExpiry: Accredation Expiry time is before current time");

        _userWhitelisteds.add(_wallet);
        whitelistInfo storage newUser = whitelistUsers[_wallet];

        newUser.valid = true;
        newUser.suspend = false;
        newUser.taxWithholding = 0;

        newUser.wallet = _wallet;
        newUser.kycVerified = _kycVerified;
        newUser.accredationExpiry = _accredationExpiry;
        newUser.accredationVerified = _accredationVerified;
        newUser.userType = "Basic";
        
        userList.push(_wallet);
    }

    function getWhitelistedUser(address _wallet) public view returns (address, bool, bool, uint256, uint256){
        whitelistInfo memory u = whitelistUsers[_wallet];
        return (u.wallet, u.kycVerified, u.accredationExpiry >= block.timestamp, u.accredationExpiry, u.taxWithholding);
    }

    function updateKycWhitelistedUser(address _wallet, bool _kycVerified) public onlyManager {
        whitelistInfo storage u = whitelistUsers[_wallet];
        u.kycVerified = _kycVerified;
    }

    function updateAccredationWhitelistedUser(address _wallet, uint256 _accredationExpiry) public onlyManager {
        require(_accredationExpiry >= block.timestamp, "accredationExpiry: Accredation Expiry time is before current time");

        whitelistInfo storage u = whitelistUsers[_wallet];
        u.accredationExpiry = _accredationExpiry;
    }

    function updateTaxWhitelistedUser(address _wallet, uint256 _taxWithholding) public onlyManager {
        whitelistInfo storage u = whitelistUsers[_wallet];
        u.taxWithholding = _taxWithholding;
    }

    function suspendUser(address _wallet) public onlyManager {
        whitelistInfo storage u = whitelistUsers[_wallet];
        u.suspend = true;
    }

    function activeUser(address _wallet) public onlyManager {
        whitelistInfo storage u = whitelistUsers[_wallet];
        u.suspend = false;
    }

    function updateUserType(address _wallet, string memory _userType) public onlyManager {
        require(
            StringUtils.equal(_userType , 'Basic') || StringUtils.equal(_userType , 'Premium')
        , "Please Enter Valid User Type");
        whitelistInfo storage u = whitelistUsers[_wallet];
        u.userType = _userType;
    }


    function isWhitelistedUser(address wallet) public view returns (uint) {
        whitelistInfo storage u = whitelistUsers[wallet];
    whitelistInfoManager memory m = whitelistManagers[wallet];

       
      if(StringUtils.equal(admins[wallet], "superAdmin")) return 100;

       
        if(StringUtils.equal(admins[wallet], "fee"))   return 110;

         
        if(StringUtils.equal(admins[wallet], "dev"))   return 111;

         
        if(StringUtils.equal(admins[wallet], "admin")) return 112;

        
        if(StringUtils.equal(m.role, "finance"))     return 120;

         
         if(StringUtils.equal(m.role, "assets"))  return 121;

           
         if(StringUtils.equal(m.role, "signer"))  return 122;
         
        
        

        
        else if(!u.valid) return 404;

        
        else if(u.suspend) return 401;

        
        else if(!u.kycVerified) return 400;

        
        else if(!accreditationCheck) return 200;

        
        else if(u.accredationExpiry <= block.timestamp)
            return 201;

        
        else return 200;
    }

    function removeWhitelistedUser(address _wallet) public onlyManager {
        _userWhitelisteds.remove(_wallet);
        whitelistInfo storage u = whitelistUsers[_wallet];
        u.valid = false;
    }

    
    function addSymbols(string calldata _symbols)
        external
        
        returns(bool){
            if(symbolsDef[_symbols] == true)
                return false;
            else{
                symbolsDef[_symbols]=true;
                return true;
            }
        }
    
    function removeSymbols(string calldata _symbols)
        external
        
        returns(bool){
            if(symbolsDef[_symbols] == true)
            symbolsDef[_symbols] = false;
            return true;


        }

    function closeTokenismWhitelist() public {
      require(StringUtils.equal(admins[_msgSender()], "superAdmin"), "only superAdmin can destroy Contract");
    selfdestruct(msg.sender);
    } 


    function storedAllData()public view onlyAdmin returns(
        address[] memory _userList,
        bool[] memory _validity,
        bool[] memory _kycVery,
        bool[] memory _accredationVery,
        uint256[] memory _accredationExpir,
        uint256[] memory _taxWithHold,
        uint256[] memory _userTypes
        )
        {

            uint size = userList.length;

        bool[] memory validity = new bool[](size);
        bool[] memory kycVery = new bool[](size);
        bool[] memory accredationVery = new bool[](size);
        uint256[] memory accredationExpir = new uint256[](size);
        uint256[] memory taxWithHold = new uint256[](size);
        uint256[] memory userTypes = new uint256[](size);
            uint i;
            for(i=0; i<userList.length; i++){
                        if(whitelistUsers[userList[i]].valid){
                            validity[i]= true;
                        }
                        else{
                        validity[i]=false;   
                        }
                    if(whitelistUsers[userList[i]].kycVerified)
                    {
                    kycVery[i] = true;
                    }
                    else{
                    kycVery[i] = false;
                    }
                    if(whitelistUsers[userList[i]].accredationVerified)
                    {
                    accredationVery[i] = true;
                    }
                    else{
                    accredationVery[i] = false;
                    }
                    accredationExpir[i] = (whitelistUsers[userList[i]].accredationExpiry);
                    taxWithHold[i] = (whitelistUsers[userList[i]].taxWithholding);
                    if(StringUtils.equal(whitelistUsers[userList[i]].userType, "Basic")){
                        userTypes[i] = 20; 
                    }
                    else
                    userTypes[i] = 100;
            }
            return (userList,validity, kycVery,accredationVery, accredationExpir, taxWithHold,userTypes);
        }



    function userType(address _caller) public view returns(bool){
        if(StringUtils.equal(whitelistUsers[_caller].userType, "Premium"))
        return true;
        return false;
    }
}