// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PeerToPeerTutoring {

    // Declare the owner of the contract
    address public owner;

    // Define a struct to store tutor and student details
    struct Tutor {
        address payable tutorAddress;
        string name;
        uint hourlyRate; // Token per hour
        bool available; // Availability status
    }

    struct Student {
        address studentAddress;
        string name;
        uint balance; // Token balance
    }

    // Mapping to store tutors by address
    mapping(address => Tutor) public tutors;

    // Mapping to store students by address
    mapping(address => Student) public students;

    // Mapping to track tutor-student sessions
    mapping(address => address) public activeSessions;

    // Event for logging tutor registration
    event TutorRegistered(address tutorAddress, string name, uint hourlyRate);
    
    // Event for logging student registration
    event StudentRegistered(address studentAddress, string name);

    // Event for logging a new session creation
    event SessionStarted(address tutorAddress, address studentAddress);

    // Event for logging session payment
    event PaymentMade(address tutorAddress, address studentAddress, uint amount);

    // Constructor to set the contract owner
    constructor() {
        owner = msg.sender;
    }

    // Function to register a tutor
    function registerTutor(string memory _name, uint _hourlyRate) public {
        require(tutors[msg.sender].tutorAddress == address(0), "Tutor already registered");
        tutors[msg.sender] = Tutor(payable(msg.sender), _name, _hourlyRate, true);
        emit TutorRegistered(msg.sender, _name, _hourlyRate);
    }

    // Function to register a student
    function registerStudent(string memory _name) public {
        require(students[msg.sender].studentAddress == address(0), "Student already registered");
        students[msg.sender] = Student(msg.sender, _name, 0);
        emit StudentRegistered(msg.sender, _name);
    }

    // Function to fund the student's balance (add tokens to their account)
    function fundStudentBalance(uint _amount) public payable {
        require(msg.value == _amount, "Sent amount must match the requested amount");
        students[msg.sender].balance += _amount;
    }

    // Function to start a tutoring session
    function startSession(address _tutorAddress) public {
        require(tutors[_tutorAddress].available == true, "Tutor is not available");
        require(students[msg.sender].balance > 0, "Insufficient balance");

        uint hourlyRate = tutors[_tutorAddress].hourlyRate;

        // Check that the student has enough tokens for at least 1 hour
        require(students[msg.sender].balance >= hourlyRate, "Insufficient balance for session");

        activeSessions[_tutorAddress] = msg.sender;
        students[msg.sender].balance -= hourlyRate;
        emit SessionStarted(_tutorAddress, msg.sender);
    }

    // Function to end the session and make payment
    function endSession(address _tutorAddress) public {
        require(activeSessions[_tutorAddress] == msg.sender, "Session not active for this student");

        uint hourlyRate = tutors[_tutorAddress].hourlyRate;
        tutors[_tutorAddress].tutorAddress.transfer(hourlyRate);
        activeSessions[_tutorAddress] = address(0);
        
        emit PaymentMade(_tutorAddress, msg.sender, hourlyRate);
    }

    // Function to view tutor details
    function getTutorDetails(address _tutorAddress) public view returns (string memory, uint, bool) {
        Tutor memory tutor = tutors[_tutorAddress];
        return (tutor.name, tutor.hourlyRate, tutor.available);
    }

    // Function to view student details
    function getStudentDetails(address _studentAddress) public view returns (string memory, uint) {
        Student memory student = students[_studentAddress];
        return (student.name, student.balance);
    }
}

