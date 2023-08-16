-- Create Table to store document chats

CREATE TABLE "public"."document_chats" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "record_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "title" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);

ALTER TABLE "public"."document_chats" OWNER TO "postgres";

ALTER TABLE ONLY "public"."document_chats"
    ADD CONSTRAINT "document_chats_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."document_chats"
    ADD CONSTRAINT "document_chats_record_fkey" FOREIGN KEY ("record_id") REFERENCES "public"."medical_records"("id");

ALTER TABLE ONLY "public"."document_chats"
    ADD CONSTRAINT "document_chats_user_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id");

ALTER TABLE "public"."document_chats" ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enable CRUD for authenticated users only" ON "public"."document_chats" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));

GRANT ALL ON TABLE "public"."document_chats" TO "anon";
GRANT ALL ON TABLE "public"."document_chats" TO "authenticated";
GRANT ALL ON TABLE "public"."document_chats" TO "service_role";

-- Create Table to store document chat history

CREATE TABLE "public"."document_chat_history" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "chat_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "record_id" "uuid" NOT NULL,
    "prompt" "text" NOT NULL,
    "response" "text" NOT NULL,
    "citation_page" "int4",
    "citation_left" "int4",
    "citation_top" "int4",
    "citation_right" "int4",
    "citation_bottom" "int4",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);

ALTER TABLE "public"."document_chat_history" OWNER TO "postgres";

ALTER TABLE ONLY "public"."document_chat_history"
    ADD CONSTRAINT "document_chat_history_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."document_chat_history"
    ADD CONSTRAINT "document_chat_history_chat_fkey" FOREIGN KEY ("chat_id") REFERENCES "public"."document_chats"("id");

ALTER TABLE ONLY "public"."document_chat_history"
    ADD CONSTRAINT "document_chat_history_user_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id");

ALTER TABLE ONLY "public"."document_chat_history"
    ADD CONSTRAINT "document_chat_history_record_fkey" FOREIGN KEY ("record_id") REFERENCES "public"."medical_records"("id");

ALTER TABLE "public"."document_chat_history" ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enable CRUD for authenticated users only" ON "public"."document_chat_history" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));

GRANT ALL ON TABLE "public"."document_chat_history" TO "anon";
GRANT ALL ON TABLE "public"."document_chat_history" TO "authenticated";
GRANT ALL ON TABLE "public"."document_chat_history" TO "service_role";

-- Change records table to include id of the user that uploaded the record

ALTER TABLE "public"."medical_records" ADD COLUMN "user_id" "uuid" NOT NULL;

ALTER TABLE "public"."medical_records" ADD CONSTRAINT "medical_records_user_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id");

-- Remove current row level security policies for the records table

CREATE POLICY "Enable CRUD for authenticated users only" ON "public"."medical_records" TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));

GRANT ALL ON TABLE "public"."medical_records" TO "anon";
GRANT ALL ON TABLE "public"."medical_records" TO "authenticated";
GRANT ALL ON TABLE "public"."medical_records" TO "service_role";

-- Create policies for storage upload and read for authenticated users

CREATE POLICY "Authenticated to Upload Read Medical Records" 
ON storage.objects for INSERT
TO authenticated
WITH CHECK ( bucket_id = 'records' AND auth.uid() IS NOT NULL );

CREATE POLICY "Authenticated to Read Medical Records"
ON storage.objects for SELECT
TO authenticated
USING ( bucket_id = 'records' AND auth.uid() = SPLIT_PART(name, '/', 1)::uuid);

