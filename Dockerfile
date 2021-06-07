# Please consult the README if you need help in selecting a base image
FROM python:3 as application


# Create the application working directory
WORKDIR /opt/app

# create a system group and user with no login shell and access restricted
# to the application
RUN groupadd --system modzy-group && \
    useradd --system --shell /bin/false --group modzy-group modzy-user && \
    mkdir /home/modzy-user && \
    chown --recursive modzy-user:modzy-group /opt/app /home/modzy-user
USER modzy-user

# copy application files into the container image
# NOTE: to avoid overly large container size, only copy the files actually needed by
#       explicitly specifying the needed files with the `COPY` command or adjusting
#       the `.dockerignore` file to ignore unneeded files
COPY grpc_model ./grpc_model
COPY model_lib ./model_lib
COPY asset_bundle/0.1.0 ./asset_bundle/0.1.0

# environment variable to specify model server port
ENV PSC_MODEL_PORT=45000 \
    PATH=${PATH}:/home/modzy-user/.local/bin/


ARG CIRCLE_REPOSITORY_URL
LABEL com.modzy.git.source="${CIRCLE_REPOSITORY_URL}"

# Please select one of the following methods for installing your python dependencies within the model container

# 1. Use pip directly
COPY requirements.txt ./
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

CMD ["python", "-m", "grpc_model.src.model_server"]

# 2. Use a virtual envrionment
#ADD pyproject.toml poetry.lock ./
#RUN pip install --no-cache-dir --upgrade pip && \
#    pip install poetry && \
#    poetry install --no-dev
#
#ENTRYPOINT ["poetry", "run", "python", "-m", "grpc_model.src.model_server"]
