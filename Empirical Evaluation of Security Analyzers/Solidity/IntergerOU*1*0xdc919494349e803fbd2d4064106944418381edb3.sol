pragma solidity ^0.4.24;



















contract DSAuthority {
    function canCall(
        address src, address dst, bytes4 sig
    ) public view returns (bool);
}

contract DSAuthEvents {
    event LogSetAuthority (address indexed authority);
    event LogSetOwner     (address indexed owner);
}

contract DSAuth is DSAuthEvents {
    DSAuthority  public  authority;
    address      public  owner;

    function DSAuth() public {
        owner = msg.sender;
        LogSetOwner(msg.sender);
    }

    function setOwner(address owner_)
        public
        auth
    {
        owner = owner_;
        LogSetOwner(owner);
    }

    function setAuthority(DSAuthority authority_)
        public
        auth
    {
        authority = authority_;
        LogSetAuthority(authority);
    }

    modifier auth {
        require(isAuthorized(msg.sender, msg.sig));
        _;
    }

    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else if (authority == DSAuthority(0)) {
            return false;
        } else {
            return authority.canCall(src, this, sig);
        }
    }
}



















contract DSNote {
    event LogNote(
        bytes4   indexed  sig,
        address  indexed  guy,
        bytes32  indexed  foo,
        bytes32  indexed  bar,
        uint              wad,
        bytes             fax
    ) anonymous;

    modifier note {
        bytes32 foo;
        bytes32 bar;

        assembly {
            foo := calldataload(4)
            bar := calldataload(36)
        }

        LogNote(msg.sig, msg.sender, foo, bar, msg.value, msg.data);

        _;
    }
}



















contract DSMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {
        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {
        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {
        return x >= y ? x : y;
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }
    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }
    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    function rpow(uint x, uint n) internal pure returns (uint z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}

























contract DSThing is DSAuth, DSNote, DSMath {

    function S(string s) internal pure returns (bytes4) {
        return bytes4(keccak256(s));
    }

}
























contract DSStop is DSNote, DSAuth {

    bool public stopped;

    modifier stoppable {
        require(!stopped);
        _;
    }
    function stop() public auth note {
        stopped = true;
    }
    function start() public auth note {
        stopped = false;
    }

}












contract ERC20Events {
    event Approval(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);
}

contract ERC20 is ERC20Events {
    function totalSupply() public view returns (uint);
    function balanceOf(address guy) public view returns (uint);
    function allowance(address src, address guy) public view returns (uint);

    function approve(address guy, uint wad) public returns (bool);
    function transfer(address dst, uint wad) public returns (bool);
    function transferFrom(
        address src, address dst, uint wad
    ) public returns (bool);
}
























contract DSTokenBase is ERC20, DSMath {
    uint256                                            _supply;
    mapping (address => uint256)                       _balances;
    mapping (address => mapping (address => uint256))  _approvals;

    function DSTokenBase(uint supply) public {
        _balances[msg.sender] = supply;
        _supply = supply;
    }

    function totalSupply() public view returns (uint) {
        return _supply;
    }
    function balanceOf(address src) public view returns (uint) {
        return _balances[src];
    }
    function allowance(address src, address guy) public view returns (uint) {
        return _approvals[src][guy];
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public
        returns (bool)
    {
        if (src != msg.sender) {
            _approvals[src][msg.sender] = sub(_approvals[src][msg.sender], wad);
        }

        _balances[src] = sub(_balances[src], wad);
        _balances[dst] = add(_balances[dst], wad);

        Transfer(src, dst, wad);

        return true;
    }

    function approve(address guy, uint wad) public returns (bool) {
        _approvals[msg.sender][guy] = wad;

        Approval(msg.sender, guy, wad);

        return true;
    }
}

























contract DSToken is DSTokenBase(0), DSStop {

    bytes32  public  symbol;
    uint256  public  decimals = 18; 

    function DSToken(bytes32 symbol_) public {
        symbol = symbol_;
    }

    event Mint(address indexed guy, uint wad);
    event Burn(address indexed guy, uint wad);

    function approve(address guy) public stoppable returns (bool) {
        return super.approve(guy, uint(-1));
    }

    function approve(address guy, uint wad) public stoppable returns (bool) {
        return super.approve(guy, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public
        stoppable
        returns (bool)
    {
        if (src != msg.sender && _approvals[src][msg.sender] != uint(-1)) {
            _approvals[src][msg.sender] = sub(_approvals[src][msg.sender], wad);
        }

        _balances[src] = sub(_balances[src], wad);
        _balances[dst] = add(_balances[dst], wad);

        Transfer(src, dst, wad);

        return true;
    }

    function push(address dst, uint wad) public {
        transferFrom(msg.sender, dst, wad);
    }
    function pull(address src, uint wad) public {
        transferFrom(src, msg.sender, wad);
    }
    function move(address src, address dst, uint wad) public {
        transferFrom(src, dst, wad);
    }

    function mint(uint wad) public {
        mint(msg.sender, wad);
    }
    function burn(uint wad) public {
        burn(msg.sender, wad);
    }
    function mint(address guy, uint wad) public auth stoppable {
        _balances[guy] = add(_balances[guy], wad);
        _supply = add(_supply, wad);
        Mint(guy, wad);
    }
    function burn(address guy, uint wad) public auth stoppable {
        if (guy != msg.sender && _approvals[guy][msg.sender] != uint(-1)) {
            _approvals[guy][msg.sender] = sub(_approvals[guy][msg.sender], wad);
        }

        _balances[guy] = sub(_balances[guy], wad);
        _supply = sub(_supply, wad);
        Burn(guy, wad);
    }

    
    bytes32   public  name = "";

    function setName(bytes32 name_) public auth {
        name = name_;
    }
}























contract DSValue is DSThing {
    bool    has;
    bytes32 val;
    function peek() public view returns (bytes32, bool) {
        return (val,has);
    }
    function read() public view returns (bytes32) {
        var (wut, haz) = peek();
        assert(haz);
        return wut;
    }
    function poke(bytes32 wut) public note auth {
        val = wut;
        has = true;
    }
    function void() public note auth {  
        has = false;
    }
}

























contract SaiVox is DSThing {
    uint256  _par;
    uint256  _way;

    uint256  public  fix;
    uint256  public  how;
    uint256  public  tau;

    function SaiVox(uint par_) public {
        _par = fix = par_;
        _way = RAY;
        tau  = era();
    }

    function era() public view returns (uint) {
        return block.timestamp;
    }

    function mold(bytes32 param, uint val) public note auth {
        if (param == 'way') _way = val;
    }

    
    function par() public returns (uint) {
        prod();
        return _par;
    }
    function way() public returns (uint) {
        prod();
        return _way;
    }

    function tell(uint256 ray) public note auth {
        fix = ray;
    }
    function tune(uint256 ray) public note auth {
        how = ray;
    }

    function prod() public note {
        var age = era() - tau;
        if (age == 0) return;  
        tau = era();

        if (_way != RAY) _par = rmul(_par, rpow(_way, age));  

        if (how == 0) return;  
        var wag = int128(how * age);
        _way = inj(prj(_way) + (fix < _par ? wag : -wag));
    }

    function inj(int128 x) internal pure returns (uint256) {
        return x >= 0 ? uint256(x) + RAY
            : rdiv(RAY, RAY + uint256(-x));
    }
    function prj(uint256 x) internal pure returns (int128) {
        return x >= RAY ? int128(x - RAY)
            : int128(RAY) - int128(rdiv(RAY, x));
    }
}





























contract SaiTubEvents {
    event LogNewCup(address indexed lad, bytes32 cup);
}

contract SaiTub is DSThing, SaiTubEvents {
    DSToken  public  sai;  
    DSToken  public  sin;  

    DSToken  public  skr;  
    ERC20    public  gem;  

    DSToken  public  gov;  

    SaiVox   public  vox;  
    DSValue  public  pip;  
    DSValue  public  pep;  

    address  public  tap;  
    address  public  pit;  

    uint256  public  axe;  
    uint256  public  cap;  
    uint256  public  mat;  
    uint256  public  tax;  
    uint256  public  fee;  
    uint256  public  gap;  

    bool     public  off;  
    bool     public  out;  

    uint256  public  fit;  

    uint256  public  rho;  
    uint256         _chi;  
    uint256         _rhi;  
    uint256  public  rum;  

    uint256                   public  cupi;
    mapping (bytes32 => Cup)  public  cups;

    struct Cup {
        address  lad;      
        uint256  ink;      
        uint256  art;      
        uint256  ire;      
    }

    function lad(bytes32 cup) public view returns (address) {
        return cups[cup].lad;
    }
    function ink(bytes32 cup) public view returns (uint) {
        return cups[cup].ink;
    }
    function tab(bytes32 cup) public returns (uint) {
        return rmul(cups[cup].art, chi());
    }
    function rap(bytes32 cup) public returns (uint) {
        return sub(rmul(cups[cup].ire, rhi()), tab(cup));
    }

    
    function din() public returns (uint) {
        return rmul(rum, chi());
    }
    
    function air() public view returns (uint) {
        return skr.balanceOf(this);
    }
    
    function pie() public view returns (uint) {
        return gem.balanceOf(this);
    }

    

    function SaiTub(
        DSToken  sai_,
        DSToken  sin_,
        DSToken  skr_,
        ERC20    gem_,
        DSToken  gov_,
        DSValue  pip_,
        DSValue  pep_,
        SaiVox   vox_,
        address  pit_
    ) public {
        gem = gem_;
        skr = skr_;

        sai = sai_;
        sin = sin_;

        gov = gov_;
        pit = pit_;

        pip = pip_;
        pep = pep_;
        vox = vox_;

        axe = RAY;
        mat = RAY;
        tax = RAY;
        fee = RAY;
        gap = WAD;

        _chi = RAY;
        _rhi = RAY;

        rho = era();
    }

    function era() public constant returns (uint) {
        return block.timestamp;
    }

    

    function mold(bytes32 param, uint val) public note auth {
        if      (param == 'cap') cap = val;
        else if (param == 'mat') { require(val >= RAY); mat = val; }
        else if (param == 'tax') { require(val >= RAY); drip(); tax = val; }
        else if (param == 'fee') { require(val >= RAY); drip(); fee = val; }
        else if (param == 'axe') { require(val >= RAY); axe = val; }
        else if (param == 'gap') { require(val >= WAD); gap = val; }
        else return;
    }

    

    function setPip(DSValue pip_) public note auth {
        pip = pip_;
    }
    function setPep(DSValue pep_) public note auth {
        pep = pep_;
    }
    function setVox(SaiVox vox_) public note auth {
        vox = vox_;
    }

    
    function turn(address tap_) public note {
        require(tap  == 0);
        require(tap_ != 0);
        tap = tap_;
    }

    

    
    function per() public view returns (uint ray) {
        return skr.totalSupply() == 0 ? RAY : rdiv(pie(), skr.totalSupply());
    }
    
    function ask(uint wad) public view returns (uint) {
        return rmul(wad, wmul(per(), gap));
    }
    
    function bid(uint wad) public view returns (uint) {
        return rmul(wad, wmul(per(), sub(2 * WAD, gap)));
    }
    function join(uint wad) public note {
        require(!off);
        require(ask(wad) > 0);
        require(gem.transferFrom(msg.sender, this, ask(wad)));
        skr.mint(msg.sender, wad);
    }
    function exit(uint wad) public note {
        require(!off || out);
        require(gem.transfer(msg.sender, bid(wad)));
        skr.burn(msg.sender, wad);
    }

    

    
    function chi() public returns (uint) {
        drip();
        return _chi;
    }
    function rhi() public returns (uint) {
        drip();
        return _rhi;
    }
    function drip() public note {
        if (off) return;

        var rho_ = era();
        var age = rho_ - rho;
        if (age == 0) return;    
        rho = rho_;

        var inc = RAY;

        if (tax != RAY) {  
            var _chi_ = _chi;
            inc = rpow(tax, age);
            _chi = rmul(_chi, inc);
            sai.mint(tap, rmul(sub(_chi, _chi_), rum));
        }

        
        if (fee != RAY) inc = rmul(inc, rpow(fee, age));
        if (inc != RAY) _rhi = rmul(_rhi, inc);
    }


    

    
    function tag() public view returns (uint wad) {
        return off ? fit : wmul(per(), uint(pip.read()));
    }
    
    function safe(bytes32 cup) public returns (bool) {
        var pro = rmul(tag(), ink(cup));
        var con = rmul(vox.par(), tab(cup));
        var min = rmul(con, mat);
        return pro >= min;
    }


    

    function open() public note returns (bytes32 cup) {
        require(!off);
        cupi = add(cupi, 1);
        cup = bytes32(cupi);
        cups[cup].lad = msg.sender;
        LogNewCup(msg.sender, cup);
    }
    function give(bytes32 cup, address guy) public note {
        require(msg.sender == cups[cup].lad);
        require(guy != 0);
        cups[cup].lad = guy;
    }

    function lock(bytes32 cup, uint wad) public note {
        require(!off);
        cups[cup].ink = add(cups[cup].ink, wad);
        skr.pull(msg.sender, wad);
        require(cups[cup].ink == 0 || cups[cup].ink > 0.005 ether);
    }
    function free(bytes32 cup, uint wad) public note {
        require(msg.sender == cups[cup].lad);
        cups[cup].ink = sub(cups[cup].ink, wad);
        skr.push(msg.sender, wad);
        require(safe(cup));
        require(cups[cup].ink == 0 || cups[cup].ink > 0.005 ether);
    }

    function draw(bytes32 cup, uint wad) public note {
        require(!off);
        require(msg.sender == cups[cup].lad);
        require(rdiv(wad, chi()) > 0);

        cups[cup].art = add(cups[cup].art, rdiv(wad, chi()));
        rum = add(rum, rdiv(wad, chi()));

        cups[cup].ire = add(cups[cup].ire, rdiv(wad, rhi()));
        sai.mint(cups[cup].lad, wad);

        require(safe(cup));
        require(sai.totalSupply() <= cap);
    }
    function wipe(bytes32 cup, uint wad) public note {
        require(!off);

        var owe = rmul(wad, rdiv(rap(cup), tab(cup)));

        cups[cup].art = sub(cups[cup].art, rdiv(wad, chi()));
        rum = sub(rum, rdiv(wad, chi()));

        cups[cup].ire = sub(cups[cup].ire, rdiv(add(wad, owe), rhi()));
        sai.burn(msg.sender, wad);

        var (val, ok) = pep.peek();
        if (ok && val != 0) gov.move(msg.sender, pit, wdiv(owe, uint(val)));
    }

    function shut(bytes32 cup) public note {
        require(!off);
        require(msg.sender == cups[cup].lad);
        if (tab(cup) != 0) wipe(cup, tab(cup));
        if (ink(cup) != 0) free(cup, ink(cup));
        delete cups[cup];
    }

    function bite(bytes32 cup) public note {
        require(!safe(cup) || off);

        
        var rue = tab(cup);
        sin.mint(tap, rue);
        rum = sub(rum, cups[cup].art);
        cups[cup].art = 0;
        cups[cup].ire = 0;

        
        var owe = rdiv(rmul(rmul(rue, axe), vox.par()), tag());

        if (owe > cups[cup].ink) {
            owe = cups[cup].ink;
        }

        skr.push(tap, owe);
        cups[cup].ink = sub(cups[cup].ink, owe);
    }

    

    function cage(uint fit_, uint jam) public note auth {
        require(!off && fit_ != 0);
        off = true;
        axe = RAY;
        gap = WAD;
        fit = fit_;         
        require(gem.transfer(tap, jam));
    }
    function flow() public note auth {
        require(off);
        out = true;
    }
}

















contract WETH9 {
    string public name     = "Wrapped Ether";
    string public symbol   = "WETH";
    uint8  public decimals = 18;

    event  Approval(address indexed src, address indexed guy, uint wad);
    event  Transfer(address indexed src, address indexed dst, uint wad);
    event  Deposit(address indexed dst, uint wad);
    event  Withdrawal(address indexed src, uint wad);

    mapping (address => uint)                       public  balanceOf;
    mapping (address => mapping (address => uint))  public  allowance;

    function() public payable {
        deposit();
    }
    function deposit() public payable {
        balanceOf[msg.sender] += msg.value;
        Deposit(msg.sender, msg.value);
    }
    function withdraw(uint wad) public {
        require(balanceOf[msg.sender] >= wad);
        balanceOf[msg.sender] -= wad;
        msg.sender.transfer(wad);
        Withdrawal(msg.sender, wad);
    }

    function totalSupply() public view returns (uint) {
        return this.balance;
    }

    function approve(address guy, uint wad) public returns (bool) {
        allowance[msg.sender][guy] = wad;
        Approval(msg.sender, guy, wad);
        return true;
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public
        returns (bool)
    {
        require(balanceOf[src] >= wad);

        if (src != msg.sender && allowance[src][msg.sender] != uint(-1)) {
            require(allowance[src][msg.sender] >= wad);
            allowance[src][msg.sender] -= wad;
        }

        balanceOf[src] -= wad;
        balanceOf[dst] += wad;

        Transfer(src, dst, wad);

        return true;
    }
}




contract CDPCreator is DSMath {
    WETH9 public weth;
    ERC20 public peth;
    ERC20 public dai;
    SaiTub public tub;

    event CDPCreated(bytes32 id, address creator, uint256 dai);

    constructor(address _weth, address _peth, address _dai, address _tub) public {
        require(_weth != address(0) && _peth != address(0) && _tub != address(0) && _dai != address(0));
        weth = WETH9(_weth);
        peth = ERC20(_peth);
        dai = ERC20(_dai);
        tub = SaiTub(_tub);

        weth.approve(address(tub), uint(-1));
        peth.approve(address(tub), uint(-1));
    }

    function createCDP(uint256 amountDAI) payable external {
        require(msg.value >= 0.005 ether);
        require(address(weth).call.value(msg.value)());

        bytes32 cupID = tub.open();
        
        uint256 amountPETH = rdiv(msg.value, tub.per());
        tub.join(amountPETH);
        tub.lock(cupID, amountPETH);
        tub.draw(cupID, amountDAI);

        tub.give(cupID, msg.sender);
        dai.transfer(msg.sender, amountDAI);

        emit CDPCreated(cupID, msg.sender, amountDAI);
    }

    function lockETH(uint256 id) payable external {
        require(address(weth).call.value(msg.value)());

        uint256 amountPETH = rdiv(msg.value, tub.per());
        tub.join(amountPETH);

        tub.lock(bytes32(id), amountPETH);
    }

    function convertETHToPETH() payable external {
        require(address(weth).call.value(msg.value)());

        uint256 amountPETH = rdiv(msg.value, tub.per());
        tub.join(amountPETH);
        peth.transfer(msg.sender, amountPETH);
    }

    function convertPETHToETH(uint256 amountPETH) external {
        require(peth.transferFrom(msg.sender, address(this), amountPETH));
        
        uint256 bid = tub.bid(amountPETH);
        tub.exit(amountPETH);
        weth.withdraw(bid);
        msg.sender.transfer(bid);
    }

    function () payable external {
        
        require(msg.sender == address(weth));
    }
}