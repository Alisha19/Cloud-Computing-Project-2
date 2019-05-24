pragma solidity >=0.4.25 <0.6.0;

import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

contract HouseMarket is usingOraclize
{
    enum StateType {
      ItemAvailable,
      OfferPlaced,
      Accepted
    }

    address public InstanceOwner;
    string public Description;
    uint public AskingPrice;
    string public Bedrooms;
    string public Bathrooms;
    string public Sq_ft;
    string public Lat;
    string public Long;
    StateType public State;
    uint constant CUSTOM_GASLIMIT = 150000;

    address public InstanceBuyer;
    int public OfferPrice;

    constructor(string memory description, string memory bedrooms, string memory bathrooms, string memory sq_ft, string memory lat, string memory long) public
    {
        InstanceOwner = msg.sender;
        Bedrooms = bedrooms;
        Bathrooms = bathrooms;
        Sq_ft = sq_ft;
        Lat = lat;
        Long = long;
        Description = description;
        State = StateType.ItemAvailable;

        setPrice();
        
    }

    
    event NewOralclizeQuery(string description);
    event PriceSet(string price);

    function __callback(bytes32 queryId, string memory result) public
    {
        if (msg.sender != oraclize_cbAddress())
            revert();
        emit PriceSet(result);
        AskingPrice = parseInt(result);

    }
    
    /* function setPrice() public payable
    {
        if (oraclize_getPrice("URL", CUSTOM_GASLIMIT) > address(this).balance) 
        {
            emit NewOralclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } 
        else 
        {
            emit NewOralclizeQuery("Query was sent. Waiting for response...");
            oraclize_query("URL", "https://us-central1-e-sunlight-233114.cloudfunctions.net/predictPrice?bedrooms=3&bathrooms=2&sqft=1600&lat=44&long=-123");
        }
    } */
    
    function append(string memory a, string memory b, string memory c, string memory d, string memory e) internal pure returns (string memory) {

    return string(abi.encodePacked(a, b, c, d, e));

    }
    
    function setPrice() public payable
    {
        emit NewOralclizeQuery("Query was sent. Waiting for response...");
        string memory _query1 = append("https://us-central1-e-sunlight-233114.cloudfunctions.net/predictPrice?bedrooms=", Bedrooms, "&bathrooms=", Bathrooms, "&sqft=");
        string memory _query2 = append(_query1, Sq_ft, "&lat=", Lat, "&long=");
        string memory query = append(_query2, Long, "", "", "");
        oraclize_query("URL", query);
    }

    function MakeOffer(int offerPrice) public
    {
        if (offerPrice == 0)
        {
            revert();
        }

        if (State != StateType.ItemAvailable)
        {
            revert();
        }

        if (InstanceOwner == msg.sender)
        {
            revert();
        }

        InstanceBuyer = msg.sender;
        OfferPrice = offerPrice;
        State = StateType.OfferPlaced;
    }

    function Reject() public
    {
        if ( State != StateType.OfferPlaced )
        {
            revert();
        }

        if (InstanceOwner != msg.sender)
        {
            revert();
        }

        InstanceBuyer = 0x0000000000000000000000000000000000000000;
        State = StateType.ItemAvailable;
    }

    function AcceptOffer() public
    {
        if ( msg.sender != InstanceOwner )
        {
            revert();
        }

        State = StateType.Accepted;
    }
}