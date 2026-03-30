{% if check.exists and check.match %}

    {# Policy exists with matching columns — apply directly, skip creation #}
    {{ log("Policy '" ~ policy_name ~ "' already exists with matching columns. Applying directly.", info=true) }}

    ALTER TABLE {{ policy_database }}.{{ policy_schema }}.{{ this.name }}
      ADD ROW ACCESS POLICY {{ policy_database }}.{{ policy_schema }}.{{ policy_name }}
      ON ({{ columns | join(", ") }});

  {% elif not check.exists %}

    {# Policy does not exist — create first, then apply #}
    {{ log("Policy '" ~ policy_name ~ "' not found. Creating...", info=true) }}

    {{ create_row_access_policy(
        policy_name     = policy_name,
        policy_database = policy_database,
        policy_schema   = policy_schema,
        columns         = columns
    ) }}
