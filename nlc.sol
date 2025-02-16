pragma solidity ^0.8.28;




contract NLCTokenn is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply=10_000_000_000; // مقدار کل توکن‌ها
    string private _name = "Nine Live Cats"; // نام توکن
    string private _symbol = "NLC"; // نماد توکن
    uint256 public taxFee = 1; // 1% کارمزد تراکنش
    address public feeRecipient; // آدرس دریافت کارمزد

    address public owner; // مالک قرارداد

    modifier onlyOwner() {
        require(_msgSender() == owner, "Only owner can call this function");
        _;
    }

    constructor() {
    _name = "Nine Live Cats"; // مقدار پیش‌فرض نام توکن
    _symbol = "NLC"; // مقدار پیش‌فرض نماد توکن
    feeRecipient = msg.sender; // مقدار پیش‌فرض آدرس دریافت‌کننده کارمزد
    owner = _msgSender(); // تنظیم مالک قرارداد
    _mint(owner, 10_000_000_000 * 10 ** 18); // مینت اولیه به کیف پول مالک
    }


    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 value) public virtual override returns (bool) {
        address owner_ = _msgSender();
        _transfer(owner_, to, value);
        return true;
    }

    function allowance(address owner_, address spender) public view virtual override returns (uint256) {
        return _allowances[owner_][spender];
    }

    function approve(address spender, uint256 value) public virtual override returns (bool) {
        address owner_ = _msgSender();
        _approve(owner_, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        require(from != address(0), "ERC20: transfer from zero address");
        require(to != address(0), "ERC20: transfer to zero address");

        uint256 fee = (value * taxFee) / 100;
        uint256 amountAfterFee = value - fee;

        _update(from, to, amountAfterFee);

        if (fee > 0) {
            _update(from, feeRecipient, fee);
        }
    }

    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            _totalSupply += value;
            _balances[to] += value;
            emit Transfer(address(0), to, value);
        } else if (to == address(0)) {
            require(_balances[from] >= value, "ERC20: burn amount exceeds balance");
            _balances[from] -= value;
            _totalSupply -= value;
            emit Transfer(from, address(0), value);
        } else {
            require(_balances[from] >= value, "ERC20: transfer amount exceeds balance");
            _balances[from] -= value;
            _balances[to] += value;
            emit Transfer(from, to, value);
        }
    }

    function _mint(address account, uint256 value) internal {
        require(account != address(0), "ERC20: mint to zero address");
        _update(address(0), account, value);
    }

    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from zero address");
        _update(account, address(0), value);
    }

    function _approve(address owner_, address spender, uint256 value) internal {
        require(owner_ != address(0), "ERC20: approve from zero address");
        require(spender != address(0), "ERC20: approve to zero address");
        _allowances[owner_][spender] = value;
        emit Approval(owner_, spender, value);
    }

    function _spendAllowance(address owner_, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner_, spender);
        require(currentAllowance >= value, "ERC20: insufficient allowance");
        _approve(owner_, spender, currentAllowance - value);
    }
    function mint(uint256 amount) external onlyOwner {
        _mint(owner, amount);
    }
}