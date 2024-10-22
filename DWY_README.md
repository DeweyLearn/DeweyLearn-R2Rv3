# R2R for DeweyLearn
R2R has a good website and AI helper bot. For questions start here [R2R](https://r2r-docs.sciphi.ai/documentation/installation/light/local-system#postgres-pgvector).


## Pre-requisites
- `supabase ^15.6`
- [.env](py/.env)
- [custom.toml](py/my_r2r.toml)

## Build & Deploy Steps

1. Clone latest R2R repo.
2. cd /py
3. poetry install
4. poetry shell (make sure to run Python 3.12)

## For use with supabase make the follwing change in the file [relational.py](py/r2r/database/relational.py)
```
    async def initialize(self):
        try:
            self.pool = await asyncpg.create_pool(
                self.connection_string,
                max_size=self.postgres_configuration_settings.max_connections,

                # TODO: required to work with supabase
                statement_cache_size=0,
            )
```

5. Now build the custom docker image
```
docker build -t r2r/deweylearn-r2r .
```

6. Add/Update `r2r/deweylearn-r2r:latest` in the compose file to reflect the new image name.
```
r2r:
image: r2r/deweylearn-r2r:latest
build:
    context: .
```

7. Optional but recommended: change the `r2r-network` to `deweylearn`.


**Execute:**
1. `source .env`   
2. `poetry run r2r serve --docker --exclude-postgres --config-path=my_r2r.toml`


### Troubleshooting
Answer ` Unset it? [Y/n]: n` with n. We want to keep the env settings

### Alternatively for full deployment
3. `poetry run r2r serve --docker --full --exclude-postgres --config-name=my_r2.toml`

## Maintance
- run `docker system prune -a` every once in a while to remove unused images and containers
- If required one can delete all R2R tables from the db using `DROP schema "deweylearn_main" cascade;` Schema name is based on the `R2R_PROJECT_NAME` in the `.env` file.


## Customization
- make sure to create unique name for `vecs_collection` = "deweylearn_v2_vecs"
- this is the name of the table in the database: `R2R_PROJECT_NAME=deweylearn_r2r_main`

my_r2r.toml
```
[completion]
provider = "litellm"
concurrent_request_limit = 16

    [completion.generation_config]
    model = "openai/gpt-4o"
    temperature = 0.1
    top_p = 1
    max_tokens_to_sample = 1_024
    stream = false
    add_generation_kwargs = {}

[embedding]
provider = "litellm"
base_model = "text-embedding-3-small"
base_dimension = 1536

[database]
provider = "postgres"
user = "postgres.wwsgmwylkhzowrfagkuf"
password = "live-learn-summer-happiness"
host = "aws-0-us-east-1.pooler.supabase.com"
port = "6543"
db_name = "postgres"
vecs_collection = "deweylearn_v2_vecs"

[chunking]
provider = "unstructured_local"  # or "unstructured_api"
strategy = "auto"  # "auto", "fast", or "hi_res"
chunking_strategy = "by_title"  # "by_title" or "basic"

# Core chunking parameters
combine_under_n_chars = 128
max_characters = 500
new_after_n_chars = 1500
overlap = 20
```

## Usage

### Setup one or more users. Still unclear as to where to manager users and how to sync.

```
from r2r import R2RClient, UserCreate

client = R2RClient("http://localhost:7272")

result = client.register(user@example.com, secure_password123)
print(f"Registration Result: {result}")
```

### Login and Refresh Token
```
login_result = client.login("user@example.com", "secure_password123")
client.access_token = login_result['results']['access_token']['token']
client.refresh_token = login_result['results']['refresh_token']['token']

```

```
refresh_result = client.refresh_access_token()

client.access_token = refresh_result['results']['access_token']['token']
```
