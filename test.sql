{% if materialization not in supported_materializations %}
    {{ exceptions.raise_compiler_error(
      "Row access policy configured for materialization '" ~ materialization ~ 
      "' which is not in the supported list: " ~ supported_materializations | join(', ') ~ ". " ~
      "If this materialization should support RLS, update the should_apply_row_access_policy() macro. " ~
      "If RLS is not needed, remove row_access_policy config from the model."
    ) }}
  {% endif %}
