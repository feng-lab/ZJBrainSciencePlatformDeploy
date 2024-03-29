ARG PYTHON_VERSION
FROM python:${PYTHON_VERSION}

ARG POETRY_VERSION
ARG PIP_INDEX_URL=""
RUN pip install --no-cache-dir ${PIP_INDEX_URL} "poetry==${POETRY_VERSION}" && \
    poetry config virtualenvs.create false
