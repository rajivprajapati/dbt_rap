-- macros/unapply_row_access_policy.sql
{% macro unapply_row_access_policy() %}
  
  {# Get RLS configuration from model config #}
  {% set rap_name = config.get('row_access_policy', none) %}
  
  {% if rap_name %}
    
    {{ log("Removing row access policy '" ~ rap_name ~ "' from " ~ this, info=true) }}
    
    {# Determine database and schema for policy #}
    {% set policy_database = var('row_access_policy_database', this.database) %}
    {% set policy_schema = var('row_access_policy_schema', this.schema) %}
    
    {% set unapply_sql %}
      alter table {{ this }}
        drop row access policy {{ policy_database }}.{{ policy_schema }}.{{ rap_name }};
    {% endset %}
    
    {% do run_query(unapply_sql) %}
    {{ log("Successfully removed policy '" ~ rap_name ~ "' from " ~ this, info=true) }}
    
  {% endif %}
  
{% endmacro %}
