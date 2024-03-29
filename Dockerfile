FROM python:3.7-stretch

LABEL maintainer="Hironori Yamamoto <mr.nikoru918@gmail.com>"

RUN apt-get update && \
    apt-get install -y \
        curl && \ 
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV ROOTHOME /root
ENV WORKSPACE /var/www

RUN mkdir -p $WORKSPACE
WORKDIR $WORKSPACE
 
RUN curl -sSL https://raw.githubusercontent.com/sdispater/poetry/master/get-poetry.py | python

# set poetry's path
ENV PATH $ROOTHOME/.poetry/bin:$PATH

COPY pyproject.toml $WORKSPACE
COPY poetry.lock $WORKSPACE

RUN poetry config settings.virtualenvs.create false && \
    pip install --upgrade pip && \
    pip install -U setuptools && \
    poetry install -n

ENV USERNAME python
RUN groupadd -r $USERNAME && \
 useradd -r -g $USERNAME $USERNAME && \
 chown $USERNAME:$USERNAME -R $ROOTHOME

USER $USERNAME
ENV PATH $ROOTHOME/.poetry/bin:$PATH

CMD ["python"]
