-- macros/apply_row_access_policy.sql
{% macro apply_row_access_policy() %}
  
  {# Get RLS configuration from model config #}
  {% set rap_name = config.get('row_access_policy', none) %}
  {% set rap_columns = config.get('row_access_policy_columns', []) %}
  
  {% if rap_name and rap_columns %}
    
    {{ log("Applying row access policy '" ~ rap_name ~ "' to " ~ this, info=true) }}
    
    {# Determine database and schema for policy creation #}
    {% set policy_database = var('row_access_policy_database', this.database) %}
    {% set policy_schema = var('row_access_policy_schema', this.schema) %}
    
    {# Create the policy in the specified database.schema #}
    {{ create_row_access_policy(rap_name, policy_database, policy_schema, rap_columns) }}
    
    {# Apply the policy to the current table #}
    {% set apply_sql %}
      alter table {{ this }}
        add row access policy {{ policy_database }}.{{ policy_schema }}.{{ rap_name }}
        on ({{ rap_columns | join(', ') }});
    {% endset %}
    
    {% do run_query(apply_sql) %}
    {{ log("Successfully applied policy '" ~ rap_name ~ "' to " ~ this, info=true) }}
    
  {% endif %}
  
{% endmacro %}
