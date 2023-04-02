//SPDX-License-Identifier: Unlicense
pragma solidity >=0.5.0 <0.9.0;


contract SupplychainContract {

    address public Owner;

    constructor() {
        Owner = msg.sender;
    }

    modifier onlyByOwner() {
        require(msg.sender == Owner);
        _;
    }

    uint256 public medicineCtr =0;
    uint256 public disCtr =0;
    uint256 public retCtr =0;

 struct Medicine{
   string Medname;
   uint Mfgdate; //0 1 2
   uint Expdate;
   uint price;
   uint MedCount;  //1 sec  0.5 sec
   uint ticketRemain;
   uint DISid;
   uint RETid;
 }


 mapping(uint=>Medicine) public medicines;
 mapping(address=>mapping(uint=>uint)) public medcounts;
 uint public nextId;


    //To store information about distributor
    struct distributor {
        address addr;
        uint256 id; //distributor id
        string name; //Name of the distributor
        string place; //Place the distributor is based in
    }

    //To store all the distributors on the blockchain
    mapping(uint256 => distributor) public DIS;

    //To store information about retailer
    struct retailer {
        address addr;
        uint256 id; //retailer id
        string name; //Name of the retailer
        string place; //Place the retailer is based in
    }

    //To store all the retailers on the blockchain
    mapping(uint256 => retailer) public RET;


    //To add distributor. Only contract owner can add a new distributor
    function addDistributor(
        address _address,
        string memory _name,
        string memory _place
    ) public onlyByOwner() {
        disCtr++;
        DIS[disCtr] = distributor(_address, disCtr, _name, _place);
    }

    //To add retailer. Only contract owner can add a new retailer
    function addRetailer(
        address _address,
        string memory _name,
        string memory _place
    ) public onlyByOwner() {
        retCtr++;
        RET[retCtr] = retailer(_address, retCtr, _name, _place);
    }

    //To supply raw materials from RMS supplier to the manufacturer
    function Distributor(uint256 Medid, uint quantity) external payable {
        uint256 _id = findDIS(msg.sender);
        require(_id > 0);
        require(medicines[Medid].Expdate!=0,"Medicine does not manufactured");
        require(medicines[Medid].Expdate>block.timestamp,"Medicine is expired");
        Medicine storage _medicine = medicines[Medid];
        require(msg.value==(_medicine.price*quantity),"Ether is not enough");
        require(_medicine.ticketRemain>=quantity,"Not enough tickets");
        _medicine.ticketRemain-=quantity;
        medcounts[msg.sender][Medid]+=quantity;
        medicines[Medid].DISid = _id;
    }

    //To check if RMS is available in the blockchain
    function findDIS(address _address) private view returns (uint256) {
        require(disCtr > 0);
        for (uint256 i = 1; i <= disCtr; i++) {
            if (DIS[i].addr == _address) return DIS[i].id;
        }
        return 0; 
    }

    //To manufacture medicine
    function Retailer(uint256 Medid, uint quantity) external payable{
        uint256 _id = findRET(msg.sender);
        require(_id > 0);
        require(medicines[Medid].Expdate!=0,"Medicine does not manufactured");
        require(medicines[Medid].Expdate>block.timestamp,"Medicine is expired");
        Medicine storage _medicine = medicines[Medid];
        require(msg.value==(_medicine.price*quantity),"Ether is not enough");
        require(_medicine.ticketRemain>=quantity,"Not enough tickets");
        _medicine.ticketRemain-=quantity;
        medcounts[msg.sender][Medid]+=quantity;
        medicines[Medid].RETid = _id;
    }

    //To check if Manufacturer is available in the blockchain
    function findRET(address _address) private view returns (uint256) {
        require(retCtr > 0);
        for (uint256 i = 1; i <= retCtr; i++) {
            if (RET[i].addr == _address) return RET[i].id;
        }
        return 0;
    } 

    //To sell medicines from retailer to consumer
    function consumer(uint256 Medid,uint quantity) external payable {
        uint256 _id = findRET(msg.sender);
        require(_id > 0);
        require(medicines[Medid].Expdate>block.timestamp,"Medicine is expired");
        Medicine storage _medicine = medicines[Medid];
        require(msg.value==(_medicine.price*quantity),"Ether is not enough");
        require(_medicine.ticketRemain>=quantity,"Not enough tickets");
        _medicine.ticketRemain-=quantity;
        medcounts[msg.sender][Medid]+=quantity;
        medicines[Medid].RETid = _id;
 
    }

        // To add new medicines to the stock
    function addMedicine()
        public
        onlyByOwner()
    {
        require((disCtr > 0) && (retCtr > 0));
        medicineCtr++;

    }




 function MfgMedicine(string memory Medname,uint Mfgdate,uint Expdate,uint price,uint MedCount,uint DISid,uint RETid) external{
   require(Expdate>block.timestamp,"Your medicine is expired");
   require(MedCount>0,"You can create medicines only if you create more than 0 medicines");


   medicines[nextId] = Medicine(Medname,Mfgdate,Expdate,price,MedCount,MedCount,DISid,RETid);
   nextId++;
 }


 function buyMedicine(uint Medid,uint quantity) external payable{
   require(medicines[Medid].Expdate!=0,"Medicine does not manufactured");
   require(medicines[Medid].Expdate>block.timestamp,"Medicine is expired");
   Medicine storage _medicine = medicines[Medid];
   require(msg.value==(_medicine.price*quantity),"Ether is not enough");
   require(_medicine.ticketRemain>=quantity,"Not enough tickets");
   _medicine.ticketRemain-=quantity;
   medcounts[msg.sender][Medid]+=quantity;


 }

 //function transferTicket(uint id,uint quantity,address to) external{
 //  require(events[id].date!=0,"Event does not exist");
 //  require(events[id].date>block.timestamp,"Event has already occured");
 //  require(tickets[msg.sender][id]>=quantity,"You do not have enough tickets");
 //  tickets[msg.sender][id]-=quantity;
 //  tickets[to][id]+=quantity;
 //}
}

