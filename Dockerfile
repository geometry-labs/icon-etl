FROM python:3.6 as compile
MAINTAINER Richard Mah <richard@geometrylabs.io>
ENV PROJECT_DIR=icon-etl

RUN mkdir /$PROJECT_DIR
WORKDIR /$PROJECT_DIR
COPY . .
RUN pip install --upgrade pip && pip install --user -e /$PROJECT_DIR/[streaming]

FROM python:3.6-slim AS base
ENV PROJECT_DIR=icon-etl
COPY --from=compile /root/.local /root/.local
RUN mkdir /$PROJECT_DIR
WORKDIR /$PROJECT_DIR
COPY . .
ENV PATH=/root/.local/bin:$PATH

# Add Tini
ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

FROM base as prod
ENTRYPOINT ["/tini", "--", "python", "iconetl"]

FROM base as test
COPY requirements_dev.txt .
RUN pip3 install -r requirements_dev.txt
RUN python3 -m pytest
