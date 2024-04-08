FROM python:3.10.0-slim

WORKDIR /app/

COPY src/ /app/src/

COPY requirements.txt requirements.txt

RUN pip install -r requirements.txt

ENV PATH="/app/src:$PATH"

ARG ARG_SERVER
ARG API_PORT
ENV SERVER=${ARG_SERVER}
ENV API_PORT=${API_PORT}

EXPOSE ${API_PORT}

CMD cd /app/src && python -m ${SERVER} | tee /tmp/server.logs