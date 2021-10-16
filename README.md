# Rocket-Elevators-Ruby-Controller

### Description

This program serve as an elevator controller for application in the residential department, coded in Ruby

#### Exemple:

On a request call from any floor of the building, the controller will first select the best elevator available.
Selection is based on the status, direction and distance of each elevator to the target floor.
Once an elevator have been selected, it is sent to the corresponding floor to pick up the user and move him to the floor of his choice

### Installation 

The controller file is located in the lib folder and the test file is located in the spec folder
To run the controller and the test file you need Ruby 

https://www.ruby-lang.org/en/downloads/

The test file require 2 gems:

'rspec' to run the test file

`gem install rspec`

'duplicate' that serve as a deep copy method for object in Ruby

`gem install duplicate`

### Testing

To launch the tests:

`bin/rspec`

You can also get more details about each test by adding the -fd flag:

`bin/rspec -fd`


