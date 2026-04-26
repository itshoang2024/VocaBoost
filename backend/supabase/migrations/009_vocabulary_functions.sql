-- =================================================================
--  MODIFIED FUNCTION 2: Create a List and its Tags Atomically (Select-Only)
--  This version will FAIL if a non-existent tag is provided.
-- =================================================================
CREATE OR REPLACE FUNCTION public.create_list_with_tags(
    p_title TEXT,
    p_description TEXT,
    p_privacy_setting public.privacy_setting,
    p_creator_id UUID,
    p_tags TEXT[] -- An array of EXISTING tag names
)
RETURNS SETOF public.vocab_lists
LANGUAGE plpgsql
AS $$
DECLARE
    new_list_id UUID;
    tag_name TEXT;
    tag_id INT;
BEGIN
    -- Insert the new list and get its ID
    INSERT INTO public.vocab_lists (title, description, privacy_setting, creator_id)
    VALUES (p_title, p_description, p_privacy_setting, p_creator_id)
    RETURNING id INTO new_list_id;

    -- Loop through the provided tag names
    IF array_length(p_tags, 1) > 0 THEN
        FOREACH tag_name IN ARRAY p_tags
        LOOP
            -- Step 1: Find the tag's ID.
            -- This will be NULL if the tag doesn't exist.
            SELECT t.id INTO tag_id FROM public.tags t WHERE t.name = tag_name;

            -- Step 2: If the tag was not found, raise an error.
            -- This will cause the entire transaction to roll back safely.
            IF tag_id IS NULL THEN
                RAISE EXCEPTION 'Tag "%" does not exist.', tag_name;
            END IF;

            -- Step 3: Associate the existing tag with the new list.
            INSERT INTO public.list_tags (list_id, tag_id)
            VALUES (new_list_id, tag_id);
        END LOOP;
    END IF;
    
    -- Return the newly created list record
    RETURN QUERY SELECT * FROM public.vocab_lists WHERE id = new_list_id;
END;
$$;
SET search_path = public, extensions;
