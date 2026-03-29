-- macros/policies/check_row_access_policy_exists.sql

{% macro check_row_access_policy_exists(policy_name, policy_database, policy_schema, columns) %}

  {# Query Snowflake's INFORMATION_SCHEMA to check if policy exists #}
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

    {# Policy does not exist — safe to create #}
    {% if results.rows | length == 0 %}
      {{ return({"exists": false, "match": false}) }}
    {% endif %}

    {# Policy exists — now check signature match #}
    {% set existing_signature = results.rows[0][1] %}

    {# Build expected signature from columns arg #}
    {# columns = [{"name": "user_id", "type": "STRING"}, ...] #}
    {% set expected_signature %}
      ({% for col in columns %}{{ col.name }} {{ col.type }}{% if not loop.last %}, {% endif %}{% endfor %})
    {% endset %}

    {% if existing_signature | upper == expected_signature | upper | trim %}
      {# Exact match — safe to apply directly #}
      {{ return({"exists": true, "match": true}) }}
    {% else %}
      {# Signature mismatch — block and raise #}
      {{ exceptions.raise_compiler_error(
        "Row access policy '" ~ policy_name ~ "' already exists in " ~
        policy_database ~ "." ~ policy_schema ~
        " but with a different signature.\n" ~
        "Existing : " ~ existing_signature ~ "\n" ~
        "Expected : " ~ expected_signature ~ "\n" ~
        "Drop the policy manually and re-run, or align your columns definition."
      ) }}
    {% endif %}

  {% endif %}

{% endmacro %}
