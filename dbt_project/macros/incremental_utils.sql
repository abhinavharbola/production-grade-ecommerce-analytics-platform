{% macro incremental_filter(ts_column, lookback_days=7) %}
    {% if is_incremental() %}
        WHERE {{ ts_column }} > (
            SELECT MAX({{ ts_column }}) FROM {{ this }}
        )
    {% endif %}
{% endmacro %}