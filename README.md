## Intro

This repo contains a solution for the problem described in the `PROBLEM.md` file.

The solution was implemented using the Ruby programming language and includes unit tests using `RSpec`

There are two ways to run the solution and its unit tests:

1. Directly using ruby in your computer, which requires setting the dev environment.
2. By running the docker container (Not yet implemented).

### Run the solution using Ruby directly

1. Install Ruby Version Manager, follow the instructions [here](https://rvm.io/rvm/install).

2. Clone the repo by executing the following command in a terminal:
    ```bash
    git clone https://github.com/elyalvarado/psl-sspe
    ```

3. Change the working directory to the repo:
    ```bash
    cd psl-sspe
    ```

4. Install the project dependencies:
    ```bash
    gem install bundler
    bundle install
    ```

5. To run the  parser with the sample provided file:
    ```bash
    ruby parser.rb sample.txt
    ```

6. To run the tests:
    ```bash
    rspec
    ```
    
### Run the solution using Docker
⚠️  _Not yet implemented_
