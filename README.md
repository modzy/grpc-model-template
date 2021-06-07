# gRPC Python Model Template

## About this Template

### gRPC and Modzy Container Specification

This is a gRPC + HTTP/2 template that can be used to easily produce machine learning models that can be deployed to the
Modzy platform.

### Template Overview

Description of top-level contents
```
.
├── Dockerfile           # Used to run and release your model in a docker container
├── README.md            # Documentation for the template repository
├── asset_bundle         # Metadata for each version of your model used to package and release your model
├── grpc_model           # Library for the gRPC server
├── model_lib            # Library for your machine learning model and its Modzy Wrapper
├── poetry.lock          # Poetry lock file [don't modify directly]
├── protos               # Protocol buffer used by the gRPC server and client
├── pyproject.toml       # Example of a Poetry project file with minimum dependencies
├── requirements.txt     # Example of a Python Requirements file with minimum dependencies
└── scripts              # Location to store shell scripts
```

## Usage

### Requirements for Developing your own model from the template

1. **Migrate your existing Model Library or Develop a Model Library from Scratch**
   
    Use `model_lib/src` to store your model library and use `model_lib/tests` in order to store its associated test 
    suite. Your existing model library can be directly imported into this repository with any structure, however, you
    are required to expose functionality to instantiate and perform inference using your model at a minimum. For
    developers, it is recommended that the complete training code as well as the model architecture be included and 
    documented within your model library in order to ensure full reproducibility and traceability.


2. **Integrate your Model into the Modzy Model Wrapper Class**
   
    Navigate to the `model_lib/src/model.py` file within the repository, which contains the Modzy Model Wrapper Class.
    Proceed to fill out the `__init__()` and `handle_discrete_input()` by following the instructions provided in the 
    comments for this module.
   
    Optional: 
     - Complete the `handle_discrete_input_batch()` method  in order to enable custom batch processing for your model.
     - Refactor the `ExampleModel` class name in order to give your model a custom name.


3. **Provide model Metadata**

    Create a new version of your model using semantic versioning, `x.x.x`, and create a new directory for this version
    under `asset bundle`. Fill out a `model.yaml` and `docker_metadata.yaml` file under `asset_bundle/x.x.x/` according
    to the proper specification and then update the `__VERSION__ = x.x.x` variable located in `grpc_model/__init__.py`
    prior to performing the release for your new version of the model. Also, you must update the following line in the
    `Dockerfile`: `COPY asset_bundle/x.x.x ./asset_bundle/x.x.x/`

   
4. **Generate functional test cases**

    Generate functional test case cases for your model under `asset_bundle/<version>/test_cases`. For each test
    case, create a directory with a unique name that describes your test, and contains a complete set of input files,
    as specified in your `model.yaml` file as well as all the corresponding output files with the expected results for
    running the model on those input files.


### Model Testing and Deployment

This section expands on the minimum requirements to leverage the model template to develop your own Modzy compatible
model and provides users with a recommended procedure for phased testing in order to provide a pathway to deployment.

1. **Run Model Library Test Suite**

As recommended in the previous section, in order to ensure your model is functioning as expected, you should build
your own test suite, and run it in your environment of choice before proceeding to wrap your model.
       
For example, you could run these tests in the project's virtual environment

```
poetry run pytest --cov=model_lib/src model_lib/tests
```


2. **Run Functional Test Suite to Test Model Wrapper**

Once you have created your model wrapper as well as provided one or more functional tests for your model, you can
use the `TestModzyModelWrapper` in `grpc/tests/test_model` in order to sure that you successfully wrapped your
model using the Modzy Model Wrapper Class.

To run these tests within the project's virtual environment
```
poetry run pytest grpc_model/tests/test_model.py::TestModzyModelWrapper
```
    
To test just initialization of the model
```
poetry run pytest grpc_model/tests/test_model.py::TestModzyModelWrapper::test_model_initialization
```

To test just reproducible inference for the model
```
poetry run pytest grpc_model/tests/test_model.py::TestModzyModelWrapper::test_handle_discrete_inputs
```

If these tests pass, this means that you have successfully wrapped the functionality of your model library with the
Modzy Model Wrapper Class. Specifically, this means that your model can be instantiated and used to reproducibly
perform inference against the inputs and outputs provided.


3. **Run Functional Test Suite to Test gRPC Server**

Next, you will test to ensure that your functional test suite works for your Wrapped Model when it is being hosted
on a gRPC Server.

In order to run these tests within the project's virtual environment
```
poetry run pytest grpc_model/tests/test_model.py::test_example_model_grpc_integration
```

Note: If you would like to run the entire test suite from steps 2 and 3 in one step you can run
```
poetry run pytest grpc_model/tests
```

At this point, you can be confident that your wrapped model is functioning properly from behind the gRPC server.


4. **Testing model from a Custom Client in Virtual Environment**

If you would like to run example inputs against your model for inference, you can now set up a gRPC server hosting
your model, and use a gRPC client to send inputs. You can write your own gRPC client, or use the example Python
gRPC client provided in `grpc_model/src/model_client.py`. In order to set the client up to run for your specific
model, all that you need to do is follow the documentation provided in this module to update the `__main__` section
to load and use your specific input files.

Once this is complete you can perform the two following commands in sequence in separate terminals in order to set
up a local grpc server that is hosting your model and then use the client to perform some example inferences.

```
poetry run python -m grpc_model.src.model_server
poetry run python -m grpc_model.src.model_client
```

This provides additional information to ensure the gRPC client-server interaction is happening as expected and can
be helpful for debugging. You can also optionally extend this client for your particular method to perform more
extensive testing.


5. **Testing model from a Custom Client in Virtual Environment**
    
Next, you can perform the same sequence of tests that were performed in step 4, while hosting the gRPC server for
your model inside a docker container to ensure that you set up the Dockerfile correctly.

To start your model inside a container
```
docker build --rm --label user=<your-username> -t example-model .
docker run --rm --label user=<your-username> --name model-template -it -p 45000:45000 example-model
```

Then, test the containerized server from a local client
```
poetry run python -m grpc_model.src.model_client        
```

For your convenience these steps are captured in a single complete integration test that can be found within the 
`grpc_model/tests` directory
```
./integration_test.sh
```


## Additional Resources

### Managing Dependencies Via a Virtual Environment

This project template uses [Poetry](https://python-poetry.org/) in order to manage the Python dependencies that you 
use within the project. If this is your first time using this tool, you can follow the instructions provided
[here](https://python-poetry.org/docs/#installation) to install it.

There are two types of dependencies: core dependencies and development dependencies. Core dependencies are those that
are required to be installed for the main, production release of your project or package. Development dependencies are
auxiliary packages that are useful in aiding in providing functionality such as formatting, documentation or
type-checking, but are non-essential for the production release.

For each dependency you come across, make a determination on whether it is a core or development dependency, and add it
to the pyproject.toml file from the command line using the following command, where the `-D` flag is to be used only for
development dependencies.
```
poetry add [-D] <name-of-dependency>
```

When you are ready to run your code and have added all your dependencies, you can perform a `poetry lock` in order to
reproducibly fix your dependency versions. This will use the pyproject.toml file to crease a poetry.lock file. Then, in
order to run your code, you can use the following commands to set up a virtual environment and then run your code
within the virtual envrionment. The optional `--no-dev` flag indicates that you only wish to install core dependencies.
```
poetry install [--no-dev]
poetry run <your-command>
```

### Initializing Pre-Commit Hooks

This repository uses pre-commit hooks in order to assist you in maintaining a uniform and idiomatic code style.
If this is your first time using pre-commit hooks you can install the framework [here](https://pre-commit.com/#installation).
Once pre-commit is installed, all you need to do is execute the following command from the repository root:
```
pre-commit install
```

If you want to execute the pre-commit hooks at a time other than during the actual git commit, you can run:
```
pre-commit run --all-files
```


### Exporting current dependencies when ready to release

If you are developing within a virtual environment for convenience and reproducibility but would like to run directly
on top of pip inside of your docker container to have a very lightweight image, you can use the following instructions
in order to extract a `requirements.txt` from your virtual environment.

```
poetry export -f requirements.txt --output requirements.txt
```
OR
```
poetry export -f requirements.txt --output requirements.txt --without-hashes

```


### Compiling the protocol buffers (WARNING: only intended for template authors)

```
./scripts/compile_protocol_buffers.sh
```

