pragma solidity ^0.4.18;

contract Token {

// 현재까지 공급된 토큰수
function totalSupply() constant returns (uint256 supply) {}
// _owner가 보유한 토큰잔액을 반환
function balanceOf(address _owner) constant returns (uint256 balance) {}
// 수신자(_to) 로 해당금액(_value)를 송금. 송금이 성공하면 TRUE를 반환하고, 실패하면 FALSE를 반환.
function transfer(address _to, uint256 _value) returns (bool success) {}
//송신자(_from)주소에서 수신자(_to) 주소로 해당금액(_value)을 송금. 송금이 성공하면 TRUE를 반환하고, 실패하면 FALSE를 반환.       
// transferFrom이 성공하려면 먼저 approve 인터페이스를 사용하여 일정금액을 인출할수 있도록 허락하여야 함.
function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}
// 송신자(msg.sender)가 보유한 토큰에서 일정금액(_value)만큼의 토큰을 인출할수 있는 권한을 수신자(_spender)에게 부여.
function approve(address _spender, uint256 _value) returns (bool success) {}
// 토큰 소유자(_owner)가 토큰 수신자(_spender)에게 인출을 허락한 토큰이 얼마인지를 반환.
function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}

contract StandardToken is Token {

    function transfer(address _to, uint256 _value) returns (bool success) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        //if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        //same as above. Replace this line with the following if you want to protect against wrapping uints.
        //if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public totalSupply;
}

contract AJOUToken is StandardToken { // CHANGE THIS. Update the contract name.

    /* Public variables of the token */

    /*
    NOTE:
    The following variables are OPTIONAL vanities. One does not have to include them.
    They allow one to customise the token contract & in no way influences the core functionality.
    Some wallets/interfaces might not even bother to look at this information.
    */
    string public name;                   // Token Name
    uint8 public decimals;                // How many decimals to show. To be standard complicant keep it 18
    string public symbol;                 // An identifier: eg SBX, XPR etc..
    string public version = 'H1.0'; 
    uint256 public unitsOneEthCanBuy;     // How many units of your coin can be bought by 1 ETH?
    uint256 public totalEthInWei;         // WEI is the smallest unit of ETH (the equivalent of cent in USD or satoshi in BTC). We'll store the total ETH raised via our ICO here.  
    address public fundsWallet;           // Where should the raised ETH go?

    // This is a constructor function 
    // which means the following function name has to match the contract name declared above
    function AJOUToken() {
        balances[msg.sender] = 1000000000000000000000;               // Give the creator all initial tokens. This is set to 1000 for example. If you want your initial tokens to be X and your decimal is 5, set this value to X * 100000. (CHANGE THIS)
        totalSupply = 1000000000000000000000;                        // Update total supply (1000 for example) (CHANGE THIS)
        name = "AJOUToken";                                   // Set the name for display purposes (CHANGE THIS)
        decimals = 18;                                               // Amount of decimals for display purposes (CHANGE THIS)
        symbol = "AJOU_Pompei";                                             // Set the symbol for display purposes (CHANGE THIS)
        unitsOneEthCanBuy = 100;                                      // Set the price of your token for the ICO (CHANGE THIS)
        fundsWallet = msg.sender;                                    // The owner of the contract gets ETH

        // balances, totalSupply : 만들고자 하는 토큰의 전체갯수 (위의 예는 1000개)
        // name : 만들고자 하는 토큰명 (AJOU토큰)
        // decimals : 소수점단위를 의미하며 디폴트 18로 설정해놓는것이 이더 단위와 일치하기 때문에 좋습니다. 
        // symbol : 토큰의 단축약어
        // unitsOneEthCanBuy : 해당 컨트랙트 주소로 이더를 송금하였을경우 자동으로 받게되는 토큰의 갯수. 
        // 위의 예는 10으로 설정하였기 때문에 1이더를 전송하면 100개의 토큰을 받게 됩니다.
        // 코드작성은 Remix IDE를 사용하고 코드작성을 완료후 Run tab에서 작성하고자하는 토큰명을 선택하고 
        // Create를 한후 하기화면과 같이 Test net에 접속되어있음을 확인하고  Submit을 선택합니다.
    }

    function() payable{
        totalEthInWei = totalEthInWei + msg.value;
        uint256 amount = msg.value * unitsOneEthCanBuy;
        require(balances[fundsWallet] >= amount);

        balances[fundsWallet] = balances[fundsWallet] - amount;
        balances[msg.sender] = balances[msg.sender] + amount;

        Transfer(fundsWallet, msg.sender, amount); // Broadcast a message to the blockchain

        //Transfer ether to fundsWallet
        fundsWallet.transfer(msg.value);                               
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}