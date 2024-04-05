FROM python:3.10.0-slim AS build

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
    curl \
    build-essential

ENV POETRY_HOME="/opt/poetry" \
    POETRY_VERSION="1.3.2"
RUN curl -sSL https://install.python-poetry.org/ | python

ENV PATH="$POETRY_HOME/bin:$PATH"

COPY pyproject.toml ./

RUN poetry config virtualenvs.in-project true \
    && poetry install --no-root --only main

COPY src/ src/

SHELL ["/bin/bash", "-c"]
RUN source .venv/bin/activate && pip install --upgrade pip \
    && source .venv/bin/activate && pip install . --no-deps

FROM python:3.10.0-slim AS runtime
COPY --from=build .venv .venv

ENV PATH=".venv/bin:$PATH"

ARG ARG_SERVER
ARG API_PORT
ENV SERVER=${ARG_SERVER}
ENV API_PORT=${API_PORT}

EXPOSE ${API_PORT}

CMD python -m ${SERVER} | tee /tmp/server.logs