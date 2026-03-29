-- macros/should_apply_row_access_policy.sql (UPDATED)
{% macro should_apply_row_access_policy(materialization) %}
  
  {% if materialization == 'view' %}
    {# Views are CREATE OR REPLACE = always reapply policy #}
    {{ return(true) }}
    
  {% elif materialization == 'table' %}
    {# Table = always CTAS, always apply #}
    {{ return(true) }}
    
  {% elif materialization == 'incremental' %}
    {# Incremental: only apply if full refresh or table doesn't exist #}
    {% set is_full_refresh = flags.FULL_REFRESH %}
    
    {% if is_full_refresh %}
      {{ return(true) }}
    {% else %}
      {% set relation_exists = load_relation(this) is not none %}
      {{ return(not relation_exists) }}
    {% endif %}
    
  {% elif materialization == 'snapshot' %}
    {# Snapshot: check if table exists #}
    {% set relation_exists = load_relation(this) is not none %}
    {{ return(not relation_exists) }}
    
  {% else %}
    {# Other materializations - default to applying #}
    {{ return(true) }}
    
  {% endif %}
  
{% endmacro %}
