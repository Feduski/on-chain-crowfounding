// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract Crowfounding{

    enum ProjectState { Opened, Closed }

    struct Project {
        string id;
        string projectName;
        string description;
        ProjectState state;
        uint fundraisingGoal;
        uint funds;
        address payable author;
    }

    struct Contribution{
        address contributor; 
        uint value;
    }

    Project[] public projects;
    mapping (string => Contribution[]) public contributions;

    event Funded(string project_id, uint value);

    event ChangedState(string project_id, ProjectState newstate);

    event ProjectCreated(string id, string name, string description, uint fundraisingGoal);

    modifier onlyAuthor(uint projectIndex) {
        require(msg.sender == projects[projectIndex].author, "You arent the author");
        _;
    }

    modifier notAuthor(uint projectIndex) {
        require(msg.sender != projects[projectIndex].author, "You are the author");
        _;
    }

    function createProject(string calldata _id, string calldata _projectName, string calldata _description, uint _fundraisingGoal) public {
        require(_fundraisingGoal > 0, "Fundraising goal cannot be less than 0");
        Project memory project = Project(_id, _projectName, _description, ProjectState.Opened, _fundraisingGoal, 0, payable(msg.sender));
        projects.push(project);
        emit ProjectCreated(_id, _projectName, _description, _fundraisingGoal);
    }

    function fundProject(uint projectIndex) public payable notAuthor(projectIndex){
        Project memory project = projects[projectIndex];
        require(project.state == ProjectState.Opened, "Project is closed");
            require(msg.value > 0, "Funds cannot be less than 0");
                (project.author).transfer(msg.value);
                project.funds += msg.value;
                projects[projectIndex] = project;

                contributions[project.id].push(Contribution(msg.sender, msg.value));
            
                emit Funded(project.id, msg.value);
    }

    function changeProjectName(string memory _newProjectName, uint projectIndex) public onlyAuthor(projectIndex) {
        Project memory project = projects[projectIndex];
        project.projectName = _newProjectName;
        projects[projectIndex] = project;
    }

    function changeProjectState(ProjectState newState, uint projectIndex) public onlyAuthor(projectIndex){
        Project memory project = projects[projectIndex];
        require(newState != project.state, "Status must be different");
            project.state = newState;
            projects[projectIndex] = project;

            emit ChangedState(project.id, newState);
    }
}