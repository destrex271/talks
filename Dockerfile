# FROM ubuntu:24.04
FROM pgduckdb/pgduckdb:16-main 

# Download Data set
USER root
RUN apt-get install wget unzip curl -y


USER postgres
WORKDIR /var/lib/postgresql
RUN pwd
RUN wget -O iceberg_data.zip https://duckdb.org/data/iceberg_data.zip 
RUN unzip iceberg_data.zip -d iceberg_data && rm -rf iceberg_data.zip

# Also install duckdb
RUN curl https://install.duckdb.org | sh
RUN export PATH='/root/.duckdb/cli/latest':$PATH
RUN echo 'export PATH="$PATH:/root/.duckdb/cli/latest"' >> ~/.bashrc
RUN echo 'export motherduck_token="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImRlc3RyZXgyNzFAZ21haWwuY29tIiwic2Vzc2lvbiI6ImRlc3RyZXgyNzEuZ21haWwuY29tIiwicGF0IjoieUhLZmFHRWR6R0l1LW5DU2JiMm9WcG5ZRGN3ZnR2UlhlYzB2Q3ljVFNUMCIsInVzZXJJZCI6IjQ2NmUyZDk0LWVhOWUtNDZmNS05Mzg1LThhMjljNzQ0MmI1YSIsImlzcyI6Im1kX3BhdCIsInJlYWRPbmx5IjpmYWxzZSwidG9rZW5UeXBlIjoicmVhZF93cml0ZSIsImlhdCI6MTc0NDM0MzgwMiwiZXhwIjoxNzQ0NTE2NjAyfQ.7euzgSMRzS0gWuggx_SxG5an-tyGQ3XInCO40SNzhk8"'

USER postgres

