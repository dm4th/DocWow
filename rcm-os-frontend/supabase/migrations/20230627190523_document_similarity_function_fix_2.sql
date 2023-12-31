CREATE OR REPLACE FUNCTION "public"."document_similarity_citation"("embedding" vector(1536), "record_id" uuid, "match_threshold" double precision, "match_count" integer)
RETURNS TABLE (
    "type" text,
    "page" integer,
    "title" text,
    "summary" text,
    "left" float,
    "top" float,
    "right" float,
    "bottom" float,
    "similarity" double precision
) 
    LANGUAGE "plpgsql"
    AS $$
#variable_conflict use_variable
begin
  return query
  select
    page_summaries.section_type AS "type",
    page_summaries.page_number as "page",
    page_summaries.title,
    page_summaries.summary,
    page_summaries.left,
    page_summaries."top",
    page_summaries.right,
    page_summaries.bottom,
    (page_summaries.summary_embedding <#> embedding) * -1 as similarity
  from page_summaries 

  -- The dot product is negative because of a Postgres limitation, so we negate it
  where (page_summaries.summary_embedding <#> embedding) * -1 > match_threshold
    and page_summaries.record_id = record_id
  
  order by page_embedding.summary_embedding <#> embedding

  limit match_count;
end;
$$;

ALTER FUNCTION "public"."document_similarity_citation"("embedding" vector(1536), "record_id" uuid, "match_threshold" double precision, "match_count" integer) OWNER TO "postgres";