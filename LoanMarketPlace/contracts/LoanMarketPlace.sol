// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract LoanMarketPlace {

  address public owner = msg.sender;
  mapping (uint256 => Loan) public Loans;

  uint LoanCounter=1;

  event PublishedLoan(address _from, uint _id, uint _quantity,uint periods,uint interest, string dni, string reason, uint timestamp);
  event DeletedLoan(address _from, uint _id, uint timestamp);
  event LoanAgreement(address _from, address _to, uint quantity, uint periods, uint timestamp);
  event QuotePayed(address _from, address _to, uint timestamp);

  struct Loan{
      uint256 Id;
      address Address;
      uint Quantity;
      uint Periods;
      uint Interest;
      string Dni;
      string Reason;
      bool IsPaid;
      uint PendingQuotes;
      address BorrowerAddress;// Por defecto lo inicializo como el address del que publica, en el momento de acuerdo lo modifico
      uint timestamp;
  }

  function publishLoan(uint  _quantity, uint  _periods, uint _interest, string memory _dni, string memory _reason) public{
        Loans[LoanCounter]= Loan(LoanCounter,msg.sender, _quantity,_periods,_interest, _dni, _reason,false,_periods,msg.sender, block.timestamp);
        emit PublishedLoan(msg.sender,LoanCounter,_quantity,_periods,_interest,_dni,_reason, block.timestamp);
        LoanCounter++;
  }

  function deleteLoan(uint _id) public{
    //Solo lo puede hacer el mismo que ha creado el prestamos
    if (msg.sender==Loans[_id].Address && Loans[_id].IsPaid==false ){       
        delete Loans[_id];
        emit DeletedLoan(msg.sender, _id,block.timestamp);
    }
  }

  function signLoanContract(uint _id) public  payable {
    require(msg.value >= Loans[_id].Quantity);// No se si esta biem, quiero comprobar que el saldo de la cuenta local es suficiente para pagarle
    if (msg.sender!=Loans[_id].Address){
      Loans[_id].IsPaid=true;
      payable(Loans[_id].Address).transfer(Loans[_id].Quantity);
      Loans[_id].BorrowerAddress=msg.sender; //Modifico el address del prestador
      emit LoanAgreement(msg.sender,Loans[_id].Address , Loans[_id].Quantity, Loans[_id].Periods,block.timestamp);
    }
  }

  function  payQuote(uint _id) payable public{ // de alguna forma creo que podriamos crear una clase o struct que instanciemos en cada acuerdo y almacenemos los pagos.
    require(Loans[_id].PendingQuotes>0);
    payable(Loans[_id].BorrowerAddress).transfer((Loans[_id].Quantity+Loans[_id].Interest)/Loans[_id].Periods);
    Loans[_id].PendingQuotes--;
    emit QuotePayed( msg.sender, Loans[_id].BorrowerAddress , block.timestamp);
  }

}