//SPDX-License-Identifier: Unlicense
pragma solidity >=0.5.0 <0.9.0;

contract SupplyChainManagement {

    address Owner;

    constructor() {
        Owner = msg.sender;
    }

    modifier onlyByOwner() {
        require(msg.sender == Owner, "You are not the owner of this contract");
        _;
    }

    uint256 public medicineCount =0;
    uint256 public rmsCount =0;
    uint256 public manCount =0;
    uint256 public disCount =0;
    uint256 public retCount =0;

    enum State{
        Init,
        RawMaterialSupply,
        Manufactured,
        Distributed,
        Retailed,
        Sold
    }

    State constant defaultState = State.Init;

 struct Medicine{
   uint id;
   string Medname;
   uint Mfgdate; 
   uint Expdate;
   uint price;
   uint MedCount;  
   uint MedRemain;
   uint RMSid;
   uint MANid;
   uint DISid;
   uint RETid;
   State medState;
 }


 mapping(uint=>Medicine) public medicines;
 
 mapping(address=>mapping(uint=>uint)) public medcounts;
 uint public nextId;

function showStage(uint256 Medid)
        public
        view
        returns (string memory) 
    {
        require(medicineCount > 0);
        if (medicines[Medid].medState == State.Init)
            return "Medicine Ordered";
        else if (medicines[Medid].medState == State.RawMaterialSupply)
            return "RMS Stage";
        else if (medicines[Medid].medState == State.Manufactured)
            return "Manufacturing Stage";
        else if (medicines[Medid].medState == State.Distributed)
            return "Distribution Stage";
        else if (medicines[Medid].medState == State.Retailed)
            return "Retail Stage";
        else if (medicines[Medid].medState == State.Sold)
            return "Medicine Sold";
    }

        //To store information 

    struct rawMaterialSupplier {
        address addr;
        uint256 id; 
        string name; 
        string place; 
    }

    //To store all the raw material suppliers on the blockchain
    mapping(uint256 => rawMaterialSupplier) public RMS;
   
    struct manufacturer {
        address addr;
        uint256 id; 
        string name; 
        string place; 
    }

    mapping(uint256 => manufacturer) public MAN;

    struct distributor {
        address addr;
        uint256 id; 
        string name; 
        string place; 
    }

    mapping(uint256 => distributor) public DIS;

    struct retailer {
        address addr;
        uint256 id;
        string name; 
        string place; 
    }

    mapping(uint256 => retailer) public RET;

    //only by owner 
    // add roles

        function addRMS(
        address _address,
        string memory _name,
        string memory _place
    ) public onlyByOwner() {
        rmsCount++;
        RMS[rmsCount] = rawMaterialSupplier(_address, rmsCount, _name, _place);
    }

    function addManufacturer(
        address _address,
        string memory _name,
        string memory _place
    ) public onlyByOwner() {
        manCount++;
        MAN[manCount] = manufacturer(_address, manCount, _name, _place);
    }

    function addDistributor(
        address _address,
        string memory _name,
        string memory _place
    ) public onlyByOwner() {
        disCount++;
        DIS[disCount] = distributor(_address, disCount, _name, _place);
    }

    function addRetailer(
        address _address,
        string memory _name,
        string memory _place
    ) public onlyByOwner() {
        retCount++;
        RET[retCount] = retailer(_address, retCount, _name, _place);
    }


    //To check if RMS is available
    function findRMS(address _address) private view returns (uint256) {
        require(rmsCount > 0);
        for (uint256 i = 1; i <= rmsCount; i++) {
            if (RMS[i].addr == _address) return RMS[i].id;
        }
        return 0;
    }

    //To check if Manufacturer is available
    function findMAN(address _address) private view returns (uint256) {
        require(manCount > 0);
        for (uint256 i = 1; i <= manCount; i++) {
            if (MAN[i].addr == _address) return MAN[i].id;
        }
        return 0;
    }

    //To check if Distributor is available
    function findDIS(address _address) private view returns (uint256) {
        require(disCount > 0);
        for (uint256 i = 1; i <= disCount; i++) {
            if (DIS[i].addr == _address) return DIS[i].id;
        }
        return 0; 
    }

    //To check if retailer is available
    function findRET(address _address) private view returns (uint256) {
        require(retCount > 0);
        for (uint256 i = 1; i <= retCount; i++) {
            if (RET[i].addr == _address) return RET[i].id;
        }
        return 0;
    } 

    //To supply raw materials
    function RMSsupply(uint256 Medid) public {
        uint256 _id = findRMS(msg.sender);
        require(_id > 0);
        require(medicines[Medid].medState == State.Init);
        medicines[Medid].RMSid = _id;
        medicines[Medid].medState = State.RawMaterialSupply;
    }

    //To manufacture medicine
    function Manufacturing(uint256 Medid) public {
        uint256 _id = findMAN(msg.sender);
        require(_id > 0);
        require(medicines[Medid].medState == State.RawMaterialSupply);
        medicines[Medid].MANid = _id;
        medicines[Medid].medState = State.Manufactured;
    }

    //To Distribute
    function Distributor(uint256 Medid, uint quantity) external payable 
    {
        uint256 _id = findDIS(msg.sender);
        require(_id > 0);
        require(medicines[Medid].medState == State.Manufactured, "Medicines are not manufactured yet");                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        `````````rnufactured);
        require(medicines[Medid].Expdate!=0,"Medicine does not manufactured");
        require(medicines[Medid].Expdate>block.timestamp,"Medicine is expired");
        Medicine storage _medicine = medicines[Medid];
        require(msg.value==(_medicine.price*quantity),"Ether is not enough");
        require(_medicine.MedRemain>=quantity,"Not enough tickets");
        _medicine.MedRemain-=quantity;
        medcounts[msg.sender][Medid]+=quantity;
        medicines[Medid].DISid = _id;
        medicines[Medid].medState = State.Distributed;
        
    }

    //To Retail medicine
    function Retailer(uint256 Medid, uint quantity) external payable{
        uint256 _id = findRET(msg.sender);
        require(_id > 0);
        require(medicines[Medid].medState == State.Distributed);
        require(medicines[Medid].Expdate!=0,"Medicine does not distributed");
        require(medicines[Medid].Expdate>block.timestamp,"Medicine is expired");
        Medicine storage _medicine = medicines[Medid];
        require(msg.value==(_medicine.price*quantity),"Ether is not enough");
        require(_medicine.MedRemain>=quantity,"Not enough tickets");
        _medicine.MedRemain-=quantity;
        medcounts[msg.sender][Medid]+=quantity;
        medicines[Medid].RETid = _id;
        medicines[Medid].medState = State.Retailed;
    }

    //To sell medicines from retailer to consumer
    function Sold(uint256 Medid,uint quantity) external payable {
        uint256 _id = findRET(msg.sender);
        require(_id > 0);
        require(medicines[Medid].medState == State.Retailed);
        require(medicines[Medid].Expdate>block.timestamp,"Medicine is expired");
        Medicine storage _medicine = medicines[Medid];
        require(msg.value==(_medicine.price*quantity),"Ether is not enough");
        require(_medicine.MedRemain>=quantity,"Not enough tickets");
        _medicine.MedRemain-=quantity;
        medcounts[msg.sender][Medid]+=quantity;
        medicines[Medid].RETid = _id;
        medicines[Medid].medState = State.Sold;
 
    }

        // To add new medicines to the stock
    function addMedicine()
        public
        onlyByOwner()
    {
        require((disCount > 0) && (retCount > 0));
        medicineCount++;
        
    }


 function MfgMedicine(uint id, string memory Medname,uint Mfgdate,uint Expdate,uint price,uint MedCount,uint RMSid,uint MANid, uint DISid,uint RETid, State medState) external{
   require(Expdate>block.timestamp,"Your medicine is expired");
   require(MedCount>0,"You can create medicines only if you create more than 0 medicines");


   medicines[nextId] = Medicine(id, Medname,Mfgdate,Expdate,price,MedCount,MedCount,RMSid,MANid, DISid,RETid, medState);
   nextId++;
 }

 function buyMedicine(uint Medid,uint quantity) external payable{
   require(medicines[Medid].Expdate!=0,"Medicine does not manufactured");
   require(medicines[Medid].Expdate>block.timestamp,"Medicine is expired");
   Medicine storage _medicine = medicines[Medid];
   require(msg.value==(_medicine.price*quantity),"Ether is not enough");
   require(_medicine.MedRemain>=quantity,"Not enough tickets");
   _medicine.MedRemain-=quantity;
   medcounts[msg.sender][Medid]+=quantity;

 }


}

