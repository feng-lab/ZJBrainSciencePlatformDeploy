ARG POETRY_IMAGE_TAG
FROM ${POETRY_IMAGE_TAG}

WORKDIR /code
ENV PYTHONPATH "${PYTHONPATH}:/code"

COPY algorithm/poetry.lock algorithm/pyproject.toml /code/
RUN poetry install --only=main --no-interaction --no-cache

COPY algorithm/app /code/app
CMD /bin/bash -c "python /code/app/main.py |& tee -a /root/log/ZJBrainSciencePlatformAlgorithm/app/stdout_stderr.log"
