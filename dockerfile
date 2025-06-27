# Use the official Python base image
FROM python:3.12-slim-bullseye

# Install system dependencies, including the MS ODBC Driver
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    apt-transport-https \
    ca-certificates \
    gcc \
    g++ \
    unixodbc \
    unixodbc-dev \
    libpq-dev \
    libsasl2-dev \
    libssl-dev \
    libffi-dev \
    libodbc1 \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/11/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql17 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create the ODBC driver configuration file directly.
RUN printf "[ODBC Driver 17 for SQL Server]\nDescription=Microsoft ODBC Driver 17 for SQL Server\nDriver=/opt/microsoft/msodbcsql17/lib64/libmsodbcsql-17.so\n" > /etc/odbcinst.ini

# --- DIAGNOSTIC COMMANDS ---
# We will now check the state of the system and print it to the build log.
RUN echo "--- Verifying driver file location ---" \
    && ls -l /opt/microsoft/msodbcsql17/lib64/ \
    && echo "--- Verifying odbcinst.ini content ---" \
    && cat /etc/odbcinst.ini \
    && echo "--- Querying installed ODBC drivers ---" \
    && odbcinst -q -d \
    && echo "--- Diagnostics Complete ---"
# -----------------------------

# Set up the application environment
WORKDIR /app

# Copy and install Python dependencies
COPY requirements.txt .
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Copy the rest of the application code
COPY . .

# Expose the port your app will run on inside the container
EXPOSE 10000

# The command to run your app. Render will use the command from its UI.
CMD ["gunicorn", "-k", "uvicorn.workers.UvicornWorker", "main:app", "--bind", "0.0.0.0:10000"]