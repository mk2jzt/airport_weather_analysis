with source_data as (

    select
        source,
        airport_iata,
        loaded_at,
        payload::jsonb as payload
    from {{ source('raw', 'weather_raw') }}

),

exploded as (

    select
        source,
        airport_iata,
        loaded_at,

        jsonb_array_elements_text(payload -> 'hourly' -> 'time')            as weather_time,

        jsonb_array_elements(payload -> 'hourly' -> 'temperature_2m')       as temperature_2m,
        jsonb_array_elements(payload -> 'hourly' -> 'apparent_temperature') as apparent_temperature,
        jsonb_array_elements(payload -> 'hourly' -> 'dewpoint_2m')          as dewpoint_2m,

        jsonb_array_elements(payload -> 'hourly' -> 'relativehumidity_2m')  as relative_humidity_2m,

        jsonb_array_elements(payload -> 'hourly' -> 'precipitation')        as precipitation_mm,
        jsonb_array_elements(payload -> 'hourly' -> 'rain')                 as rain_mm,
        jsonb_array_elements(payload -> 'hourly' -> 'snowfall')             as snowfall_cm,

        jsonb_array_elements(payload -> 'hourly' -> 'cloudcover')           as cloudcover_pct,
        jsonb_array_elements(payload -> 'hourly' -> 'cloudcover_low')       as cloudcover_low_pct,
        jsonb_array_elements(payload -> 'hourly' -> 'cloudcover_mid')       as cloudcover_mid_pct,
        jsonb_array_elements(payload -> 'hourly' -> 'cloudcover_high')      as cloudcover_high_pct,

        jsonb_array_elements(payload -> 'hourly' -> 'surface_pressure')     as surface_pressure_hpa,
        jsonb_array_elements(payload -> 'hourly' -> 'pressure_msl')         as pressure_msl_hpa,

        jsonb_array_elements(payload -> 'hourly' -> 'visibility')           as visibility_m,

        jsonb_array_elements(payload -> 'hourly' -> 'windspeed_10m')        as windspeed_10m_ms,
        jsonb_array_elements(payload -> 'hourly' -> 'windgusts_10m')        as windgusts_10m_ms,
        jsonb_array_elements(payload -> 'hourly' -> 'winddirection_10m')    as winddirection_10m_deg,

        jsonb_array_elements(payload -> 'hourly' -> 'weathercode')          as weathercode

    from source_data

),

typed as (

    select
        source,
        airport_iata,
        loaded_at::timestamp,

        weather_time::timestamp                            as weather_time_utc,

        temperature_2m::float                              as temperature_2m_c,
        apparent_temperature::float                        as apparent_temperature_c,
        dewpoint_2m::float                                 as dewpoint_2m_c,

        nullif(relative_humidity_2m::text, 'null')::int     as relative_humidity_2m_pct,

        precipitation_mm::float                            as precipitation_mm,
        rain_mm::float                                     as rain_mm,
        snowfall_cm::float                                 as snowfall_cm,

        nullif(cloudcover_pct::text, 'null')::int           as cloudcover_pct,
        nullif(cloudcover_low_pct::text, 'null')::int       as cloudcover_low_pct,
        nullif(cloudcover_mid_pct::text, 'null')::int       as cloudcover_mid_pct,
        nullif(cloudcover_high_pct::text, 'null')::int      as cloudcover_high_pct,

        surface_pressure_hpa::float                         as surface_pressure_hpa,
        pressure_msl_hpa::float                             as pressure_msl_hpa,

        nullif(visibility_m::text, 'null')::float           as visibility_m,

        windspeed_10m_ms::float                             as windspeed_10m_ms,
        windgusts_10m_ms::float                             as windgusts_10m_ms,
        nullif(winddirection_10m_deg::text, 'null')::int    as winddirection_10m_deg,

        nullif(weathercode::text, 'null')::int              as weathercode

    from exploded

),

final as (
    select
        t.*,
        coalesce(wc.description, 'Unknown') as weather_description
    from typed t
    left join {{ ref('wmo_weather_codes') }} wc
        on wc.weathercode = t.weathercode
)

select *
from final