FROM python:3.10-slim-buster

# Update apt and install necessary packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    unixodbc \
    unixodbc-dev \
    gcc \
    g++ \
    libpq-dev \
    curl \
    gnupg2 \
    ca-certificates \
    && apt-get clean

# Add the Microsoft repository and install the ODBC Driver for SQL Server
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql18 \
    && apt-get clean

# Copy the dbt_project folder into the container
COPY dbt_project /usr/src/dbt/dbt_project

# Set the working directory for the DBT project
WORKDIR /usr/src/dbt/dbt_project

# Install the dbt Postgres adapter (along with dbt-core)
RUN pip install --upgrade pip
RUN pip install dbt-sqlserver

# Build the DBT project (install dependencies, seeds, models, etc.)
CMD dbt deps && dbt build --profiles-dir profiles && sleep infinity
