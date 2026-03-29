-- macros/create_row_access_policy.sql
{% macro create_row_access_policy(policy_name, policy_database, policy_schema, columns) %}
  
  {# Check if the specific policy creation macro exists #}
  {% set policy_macro_name = 'create_row_access_policy_' ~ policy_name %}
  
  {% if policy_macro_name not in context %}
    {{ exceptions.raise_compiler_error(
      "Policy creation macro '" ~ policy_macro_name ~ "' not found. " ~
      "Please create a macro named '" ~ policy_macro_name ~ "' that defines the policy logic."
    ) }}
  {% endif %}
  
  {# Call the specific policy creation macro with db, schema, and columns #}
  {{ context[policy_macro_name](policy_database, policy_schema, columns) }}
  
{% endmacro %}
