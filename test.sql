-- macros/apply_row_access_policy.sql (WITH SECURITY CHECKS)
{% macro apply_row_access_policy() %}
  
  {% set rap_name = config.get('row_access_policy', none) %}
  {% set rap_columns = config.get('row_access_policy_columns', []) %}
  
  {% if rap_name and rap_columns %}
    
    {% set materialization = config.get('materialized', 'view') %}
    
    {{ log("═══════════════════════════════════════", info=true) }}
    {{ log("RLS Check for: " ~ this, info=true) }}
    {{ log("Materialization: " ~ materialization, info=true) }}
    {{ log("Policy: " ~ rap_name, info=true) }}
    
    {# Ephemeral models cannot have RLS (they're CTEs) #}
    {% if materialization == 'ephemeral' %}
      {{ exceptions.raise_compiler_error(
        "Model " ~ this ~ " is configured with row_access_policy but uses ephemeral materialization. " ~
        "Ephemeral models are CTEs and cannot have row access policies. " ~
        "Change materialization to 'view' or 'table', or remove row_access_policy config."
      ) }}
    {% endif %}
    
    {# Check if materialization is supported - will error if unknown #}
    {% set should_apply = should_apply_row_access_policy(materialization) %}
    
    {{ log("Should apply policy: " ~ should_apply, info=true) }}
    
    {% if should_apply %}
      
      {% set policy_database = config.get('row_access_policy_database', 
                               var('row_access_policy_database', this.database)) %}
      {% set policy_schema = config.get('row_access_policy_schema', 
                             var('row_access_policy_schema', this.schema)) %}
      
      {{ log("Policy location: " ~ policy_database ~ "." ~ policy_schema, info=true) }}
      
      {# Validate columns are not empty #}
      {% if rap_columns | length == 0 %}
        {{ exceptions.raise_compiler_error(
          "Model " ~ this ~ " has row_access_policy '" ~ rap_name ~ 
          "' but row_access_policy_columns is empty. Provide at least one column."
        ) }}
      {% endif %}
      
      {# Create the policy #}
      {{ create_row_access_policy(rap_name, policy_database, policy_schema, rap_columns) }}
      
      {# Check if already applied #}
      {% set policy_exists = check_policy_on_object(this, rap_name, policy_database, policy_schema) %}
      {{ log("Policy exists on object: " ~ policy_exists, info=true) }}
      
      {% if not policy_exists %}
        {# Determine object type for ALTER statement #}
        {% set object_type = 'table' if materialization in ['table', 'incremental', 'snapshot'] else 'view' %}
        
        {% set apply_sql %}
          alter {{ object_type }} {{ this }}
            add row access policy {{ policy_database }}.{{ policy_schema }}.{{ rap_name }}
            on ({{ rap_columns | join(', ') }});
        {% endset %}
        
        {% do run_query(apply_sql) %}
        {{ log("✓ Policy applied successfully", info=true) }}
      {% else %}
        {{ log("✓ Policy already exists, skipped", info=true) }}
      {% endif %}
      
    {% else %}
      {{ log("✓ Skipped - incremental run with existing table", info=true) }}
    {% endif %}
    
    {{ log("═══════════════════════════════════════", info=true) }}
    
  {% endif %}
  
{% endmacro %}
