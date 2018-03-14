pragma solidity ^0.4.15;

contract MultiSigWallet {
    address public _owner;

    uint[] public _pendingTransactions;
    uint public _transactionIndex;     // auto incrememnting transaction ID
    uint constant MIN_SIGNATURES = 2;     //  need x signatures to sign Transaction

    mapping(address => uint8) public _owners;
    mapping (uint => Transaction) public _transactions;

    struct Transaction {
        address source;
        address destination;
        uint value;
        uint signatureCount; //add how many people signed and who
        mapping (address => uint8) signatures; // keep record of who signed
    }

    modifier isOwner() {
        require(msg.sender == _owner);
        _;
    }

    modifier validOwner() {
        require(msg.sender == _owner || _owners[msg.sender] == 1);
        _;
    }

    /// @dev logged events
    event DepositFunds(address source, uint amount);
    /// @dev full sequence of the transaction event logged
    event TransactionCreated(address source, address destination, uint value, uint transactionID);
    event TransactionCompleted(address source, address destination, uint value, uint transactionID);
    /// @dev keeps track of who is signing the transactions
    event TransactionSigned(address by, uint transactionID);


    /// @dev Contract constructor sets initial owners
    function MultiSigWallet() public {
        _owner = msg.sender;
    }

    /// @dev add new owner to have access, enables the ability to create more than one owner to manage the wallet
    function addOwner(address newOwner) isOwner public {
        _owners[newOwner] = 1;
    }

    /// @dev remove suspicious owners
    function removeOwner(address existingOwner) isOwner public {
        _owners[existingOwner] = 0;
    }

    /// @dev Fallback function, which accepts ether when sent to contract
    function () public payable {
        emit DepositFunds(msg.sender, msg.value);
    }

    function withdraw(uint amount) public payable { // what is this function for?
      require(address(this).balance >= msg.value);
      require(_owners[msg.sender] == 1);

      msg.sender.transfer(amount);
    }


    /// Start by creating your transaction. Since we defined it as a struct,
    /// we need to define it in a memory context. Update the member attributes.
    ///
    /// note, keep transactionID updated
    function transferTo(address destination, uint value) validOwner public {
        require(address(this).balance >= value);
        //add transaction to the data structures
        _pendingTransactions;
        _transactionIndex;
        _owners;
        _transactions;
        Transaction memory transaction = Transaction({
            source: msg.sender,
            destination: destination,
            value: value,
            signatureCount: 0
        });
        _transactions[_transactionIndex] = transaction;
        _pendingTransactions.push(_transactionIndex);
        _transactionIndex += 1;

      //log that the transaction was created to a specific address
        emit TransactionCreated(transaction.source, transaction.destination, transaction.value, _transactionIndex);

    }

    //returns pending transcations
    function getPendingTransactions() constant validOwner public returns (uint[]) {
        return _pendingTransactions;
    }

    /// @dev Allows an owner to confirm a transaction.
    /// @param transactionId Transaction ID.
    /// Sign and Execute transaction.
    function signTransaction(uint transactionId) validOwner public {

        require(transaction.source != 0x0); // Transaction must exist, note: use require(), but can't do require(transaction), .
        require(msg.sender != _owner);
        require(transaction.signatures[msg.sender] == 0); // Cannot sign a transaction more than once, use require()

        Transaction storage transaction = _transactions[_pendingTransactions[transactionId]]; //Create variable transaction using storage (which creates a reference point)

        // ???>>> assign the transaction = 1, so that when the function is called again it will fail
        // transaction = 1;

        transaction.signatureCount += 1; // increment signatureCount
        emit TransactionSigned(msg.sender, transactionId); // log transaction

        //  check to see if transaction has enough signatures so that it can actually be completed
        // if true, make the transaction. Don't forget to log the transaction was completed.
        if (transaction.signatureCount >= MIN_SIGNATURES) {
            require(address(this).balance >= transaction.value); //validate transaction
            transaction.destination.transfer(transaction.value);
            emit TransactionCompleted(transaction.source, transaction.destination, transaction.value, transactionId);
            deleteTransaction(transactionId);

        } else {
            revert();
        }
    }

    /// @dev clean up function
    function deleteTransaction(uint transactionId) validOwner public {
      uint8 replace = 0;
      for(uint i = 0; i < _pendingTransactions.length; i++) {
        if (1 == replace) {
          _pendingTransactions[i-1] = _pendingTransactions[i];
        } else if (transactionId == _pendingTransactions[i]) {
          replace = 1;
         }
      }
      delete _pendingTransactions[_pendingTransactions.length - 1];
      _pendingTransactions.length--;
      delete _transactions[transactionId];
    }

    /// @return Returns balance
    function walletBalance() view public returns(uint) {
        return address(this).balance;
    }

 }
