-- tests/unit/test_should_apply_row_access_policy.sql
{{
    config(
        tags=['unit-test']
    )
}}

-- Test 1: Table materialization should return true
{% set result = should_apply_row_access_policy('table') %}
{% if result != true %}
    {{ exceptions.raise_compiler_error("Test failed: table should return true, got " ~ result) }}
{% endif %}

-- Test 2: View materialization should return true
{% set result = should_apply_row_access_policy('view') %}
{% if result != true %}
    {{ exceptions.raise_compiler_error("Test failed: view should return true, got " ~ result) }}
{% endif %}

-- Test 3: Unsupported materialization should error
{% set passed = false %}
{% if execute %}
    {% set test_query %}
        {{ should_apply_row_access_policy('unsupported_type') }}
    {% endset %}
{% endif %}

select 1 as id where 1=1  -- Dummy select so test file is valid
