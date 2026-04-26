DROP FUNCTION IF EXISTS update_learner_count_on_members_change();

-- Trigger function to auto-update learner_count
CREATE OR REPLACE FUNCTION update_learner_count_on_members_change()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'UPDATE' THEN
    IF NEW.join_status = 'joined' AND OLD.join_status != 'joined' THEN
      UPDATE classrooms SET learner_count = learner_count + 1 WHERE id = NEW.classroom_id;
    ELSIF NEW.join_status != 'joined' AND OLD.join_status = 'joined' THEN
      UPDATE classrooms SET learner_count = learner_count - 1 WHERE id = NEW.classroom_id;
    END IF;

  ELSIF TG_OP = 'INSERT' THEN
    IF NEW.join_status = 'joined' THEN
      UPDATE classrooms SET learner_count = learner_count + 1 WHERE id = NEW.classroom_id;
    END IF;

  ELSIF TG_OP = 'DELETE' THEN
    IF OLD.join_status = 'joined' THEN
      UPDATE classrooms SET learner_count = learner_count - 1 WHERE id = OLD.classroom_id;
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_learner_count
AFTER INSERT OR UPDATE OR DELETE ON classroom_members
FOR EACH ROW
EXECUTE FUNCTION update_learner_count_on_members_change();

-- Function to get assignments for a learner in a specific classroom
DROP FUNCTION IF EXISTS get_learner_assignments_by_classroom;

CREATE OR REPLACE FUNCTION get_learner_assignments_by_classroom(
  p_classroom_id UUID,
  p_learner_id UUID
)
RETURNS TABLE (assignment_id UUID)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT la.assignment_id
  FROM learner_assignments la
  INNER JOIN assignments a ON la.assignment_id = a.id
  WHERE la.learner_id = p_learner_id
    AND a.classroom_id = p_classroom_id;
END;
$$;
SET search_path = public, extensions;
