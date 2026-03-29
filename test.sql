{% if execute %}

    {% if results.rows | length == 0 %}
      {{ return({"exists": false, "match": false}) }}
    {% endif %}

    {# --- results.rows[0][0] is already a list like ['cola', 'colb'] --- #}
    {% set existing_cols_sorted = results.rows[0][0] | map("upper") | sort | list %}

    {# --- Sort incoming column names --- #}
    {% set expected_cols_sorted = columns | map("upper") | sort | list %}

    {# --- Compare --- #}
    {% if existing_cols_sorted == expected_cols_sorted %}
      {{ return({"exists": true, "match": true}) }}
    {% else %}
      {{ exceptions.raise_compiler_error(
        "Row access policy '" ~ policy_name ~ "' already exists but columns do not match.\n" ~
        "Existing : " ~ existing_cols_sorted | join(", ") ~ "\n" ~
        "Expected : " ~ expected_cols_sorted | join(", ") ~ "\n" ~
        "Drop the policy manually and re-run, or align your columns definition."
      ) }}
    {% endif %}

{% endif %}
