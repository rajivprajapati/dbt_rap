{% macro check_row_access_policy_exists(policy_name, policy_database, policy_schema, columns) %}

  {% set check_sql %}
    SELECT 
      POLICY_NAME,
      POLICY_SIGNATURE
    FROM {{ policy_database }}.INFORMATION_SCHEMA.ROW_ACCESS_POLICIES
    WHERE POLICY_NAME = UPPER('{{ policy_name }}')
      AND POLICY_SCHEMA = UPPER('{{ policy_schema }}')
  {% endset %}

  {% set results = run_query(check_sql) %}

  {% if execute %}

    {% if results.rows | length == 0 %}
      {{ return({"exists": false, "match": false}) }}
    {% endif %}

    {% set existing_signature = results.rows[0][1] %}

    {# --- Parse column names from Snowflake signature string --- #}
    {# Input:  "(user_id VARCHAR, region VARCHAR)"                #}
    {# Output: ["REGION", "USER_ID"]                             #}

    {% set existing_cols = [] %}
    {% set cleaned = existing_signature.strip("()").strip() %}
    {% for part in cleaned.split(",") %}
      {% do existing_cols.append(part.strip().split()[0] | upper) %}
    {% endfor %}
    {% set existing_cols_sorted = existing_cols | sort %}

    {# --- Sort incoming column names --- #}
    {# Input:  ["user_id", "region"]      #}
    {# Output: ["REGION", "USER_ID"]      #}

    {% set expected_cols_sorted = columns | map("upper") | sort | list %}

    {# --- Compare --- #}

    {% if existing_cols_sorted == expected_cols_sorted %}
      {{ return({"exists": true, "match": true}) }}
    {% else %}
      {{ exceptions.raise_compiler_error(
        "Row access policy '" ~ policy_name ~ "' already exists in " ~
        policy_database ~ "." ~ policy_schema ~
        " but columns do not match.\n" ~
        "Existing : " ~ existing_cols_sorted | join(", ") ~ "\n" ~
        "Expected : " ~ expected_cols_sorted | join(", ") ~ "\n" ~
        "Drop the policy manually and re-run, or align your columns definition."
      ) }}
    {% endif %}

  {% endif %}

{% endmacro %}
