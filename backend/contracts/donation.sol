// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


/Importing required libraries and contracts
import 'hardhat/console.sol';
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

// A smart contract for donating to women initiatives
contract DonateToWomen {

    // A struct to store the details of each initiative
    struct Initiative {
        string name; // the name of the initiative
        string description; // a brief description of the initiative
        address payable recipient; // the address of the initiative's account
        uint256 goal; // the fundraising goal in wei
        uint256 raised; // the amount raised so far in wei
        bool active; // whether the initiative is still accepting donations
    }

    // An array to store all the initiatives
    Initiative[] public initiatives;

    // An event to emit when a donation is made
    event DonationMade(address indexed donor, uint256 indexed initiativeId, uint256 amount);

    // A modifier to check if the initiative is active
    modifier onlyActive(uint256 initiativeId) {
        require(initiatives[initiativeId].active, "Initiative is not active");
        _;
    }

    // A function to create a new initiative
    function createInitiative(
        string memory name,
        string memory description,
        address payable recipient,
        uint256 goal
    ) public {
        // Create a new initiative object
        Initiative memory newInitiative = Initiative({
            name: name,
            description: description,
            recipient: recipient,
            goal: goal,
            raised: 0,
            active: true
        });

        // Push the initiative to the array
        initiatives.push(newInitiative);
    }

    // A function to donate to an initiative
    function donate(uint256 initiativeId) public payable onlyActive(initiativeId) {
        // Get the initiative object
        Initiative storage initiative = initiatives[initiativeId];

        // Update the raised amount
        initiative.raised += msg.value;

        // Transfer the donation to the recipient
        initiative.recipient.transfer(msg.value);

        // Emit the donation event
        emit DonationMade(msg.sender, initiativeId, msg.value);

        // Check if the goal is reached
        if (initiative.raised >= initiative.goal) {
            // Mark the initiative as inactive
            initiative.active = false;
        }
    }

    // A function to get the number of initiatives
    function getInitiativesCount() public view returns (uint256) {
        return initiatives.length;
    }
}
